#!/bin/bash

cmd="run"
match="."
DEFAULT_HOSTS="omn@vb-28 omn@vb-48"
HOSTS=""


while [[ ! -z "$1" ]]; do

   #echo cmd=$cmd h=$h arg=$1

   case "$1" in 
    start|stop|status|run)
        cmd=$1
        shift
	;;
    -match)
        shift
        if [[ ! -z "$1" ]] ; then
            match="$1"
            shift
        else
            echo "error: -match option needs a value, extended regexp e.g. \"cobwebs|tailor\""  
            exit -1
        fi
	;;
    -host)
        shift
        if [[ ! -z "$1" ]] ; then
            HOSTS+=" $1"
            shift
        else
            echo "error: -host option needs a value, e.g. \"omn@vb-28\""  
            exit -1
        fi
	;;
    *)
        echo "error: unexpected argumenmt: $1"
        echo "usage: $0 [<cmd>] [-match <e-regexp>] [-host <user@host>] [-host <user@host>] . . . "
        echo "       cmd := start|stop|status|run"
        echo "e.g.: $0 -match \"cobwebs|cstat|cconf\" -host omn@vb-28 -host omn@vb-48"
        echo "e.g.: $0 -match \"cobwebs|cstat|cconf\" -host omn@vb-48"

        exit -1
	;;
   esac;

done

if [[ -z "$HOSTS" ]] ; then
    HOSTS="$DEFAULT_HOSTS"
fi


if [[ ! -e ~/bin/monmemu.sh ]] ; then 

echo creating ~/bin/monmemu.sh
cat >~/bin/monmemu.sh <<EOF
#!/bin/bash

function make_mem_entry {
 mem=\$1; vsz=\$2; c=\$3; pid=\$4;
 echo \"\$mem \$vsz \${c}_\${pid}\" >> mem_\${c}_\${pid}.log; 
} 

mkdir -p ~/monmemu
cd ~/monmemu

date >>start.log

while true; do
 date >>last.log
 ps -u omn -o "%mem=,vsz=,comm=,pid=" |grep -Ev \"grep|sleep|\bps\b|\bls\b\" > mem.log
 while read line; do make_mem_entry $line; done < mem.log
 sleep 10;
done

EOF

chmod 755 ~/bin/monmemu.sh

fi


case "$cmd" in 
    start)
        ### START:
        for h in $HOSTS; do 
            #h=<user>@<host>
            ssh $h "mkdir -p ~/bin/; ls ~/bin/monmemu.sh;"
            scp ~/bin/monmemu.sh $h:bin/
            ssh $h "chmod 755 ~/bin/monmemu.sh
            PSINFO=\$(ssh $h \"ps -fu omn |grep monmemu.sh |grep -v grep\")
            if [[ -z \"\$PSINFO\" ]]; then 
              mkdir -p ~/monmemu;
              nohup ~/bin/monmemu.sh > ~/monmemu/nohup.out &
              PSINFO=\$(ssh $h \"ps -fu omn |grep monmemu.sh |grep -v grep\");
              echo \"status: STARTED RUNNING \$PSINFO\";
            else 
              echo \"status: ALREADY RUNNING \$PSINFO\";
            fi
            "
        done
        exit 0
	;;
    stop)
        for h in $HOSTS; do 
            ssh $h "PSINFO=\$(ps -fu omn |grep monmemu.sh |grep -v grep);
            if [[ ! -z \"\$PSINFO\" ]]; then 
              pid=\$(echo \$PSINFO |awk '{print \$2}')
              echo \"status: RUNNING pid=\$pid \$PSINFO\";
              kill \$pid && kill -9 \$pid
              PSINFO=\$(ssh $h \"ps -fu omn |grep monmemu.sh |grep -v grep\");
              echo \"status: KILLED \$PSINFO\";
            fi
            "
        done
        exit 0
	;;
    status)
        for h in $HOSTS; do 
            echo $cmd $h
            ssh $h "PSINFO=\$(ps -fu omn |grep monmemu.sh |grep -v grep);
            if [[ ! -z \"\$PSINFO\" ]]; then 
              echo \"status: RUNNING \$PSINFO\";
            else 
              echo \"status: NOT RUNNING\";
            fi
            "
        done
        exit 0
	;;
    run|*)
        # continue below
	;;
esac;



for h in $HOSTS; do 

    mkdir ~/monmemu-${h}
    cd ~/monmemu-${h}

    if [[ -z "$match" ]] ; then 
        ssh $h tar -jcvf monmemu.tbz monmemu/
    else 
        ssh $h 'DFILES=$(ls monmemu/ |grep -E "'"$match"'"|sed s#^#monmemu/#); tar -jcvf monmemu.tbz monmemu/{last,start,mem}.log $DFILES;'
    fi
    scp ${h}:monmemu.tbz ./
    tar -jxvf monmemu.tbz
    cd monmemu

    cat >monmemu.gnuplot <<EOF
#set term png small size 1024,800
#set output "mem-graph-${h}.png"

set label "$h"
set xlabel "$h time"

set ylabel "VSZ"
set y2label "%MEM"

set ytics nomirror
set y2tics nomirror in

set yrange [0:*]
set y2range [0:*]

plot \\
EOF

    function make_plot_entry { 
        mem=$1; vsz=$2; c=$3; pid=$4; 
        echo "\"mem_${c}_${pid}.log\" using 2 with lines axes x1y1 title \"VSZ_${c}_${pid}\", \\"; 
        echo "\"mem_${c}_${pid}.log\" using 1 with lines axes x1y2 title \"%MEM_${c}_${pid}\" \\"; 
    } 

    FIRSTCOMMA=0
    while read line; do
        if ( echo "$line"|grep -E "$match" ) ; then 
            [[ "$FIRSTCOMMA" != 0 ]] && echo -n ", " >>monmemu.gnuplot;
            [[ "$FIRSTCOMMA" == 0 ]] && FIRSTCOMMA=1;
            make_plot_entry $line >>monmemu.gnuplot; 
        fi
    done < mem.log
    echo "" >> monmemu.gnuplot

    gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-key.png\";" monmemu.gnuplot
    display mem-graph-${h}-key.png &
    gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-nokey.png\";set key off" monmemu.gnuplot ; 
    display mem-graph-${h}-nokey.png &
    # interactive
    gnuplot monmemu.gnuplot -e "pause 60";

done
