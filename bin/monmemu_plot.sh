#!/bin/bash

### TODO: should really use rsync to pull across mem log files.
### DONE: log time in process files, synchronize time together when generating plots. 
###    TODO: label log date/time of log in graph title

cmd="run"
match="."
DEFAULT_HOSTS="omn@vb-28 omn@vb-48"
HOSTS=""
STARTTIME=""
ENDTIME=""

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
    -starttime)
        shift
        if [[ ! -z "$1" ]] ; then
            STARTTIME="$1"
            shift
        else
            echo "error: -starttime option needs a value, e.g. \"yesterday\" or \"8:40\" or \"May 2\" or \"May 2 2015 9:00\" or anything unix date -d will accept"  
            exit -1
        fi
	;;
    -endtime)
        shift
        if [[ ! -z "$1" ]] ; then
            ENDTIME="$1"
            shift
        else
            echo "error: -endtime option needs a value, e.g. \"yesterday\" or \"18:40\" or \"May 2\" or \"May 7 18:00\" or anything unix date -d will accept"  
            exit -1
        fi
	;;
    help|*)
        cat <<EOF 
error: unexpected argument: $1
usage: $0 [<cmd>] [-match <e-regexp>] [-host <user@host>] [-host <user@host>] . . . 
       cmd := start|stop|status|run|help

e.g.: (NOTE: process names truncated to 15 chars e.g. reafer_pdu_pars and memcheck-x86-li)
   monmemu_plot.sh -match "cobwebs|cstat|cconf" -host omn@vb-28 -host omn@vb-48
   monmemu_plot.sh -match "reafer_pdu_pars|valgrind|memcheck-x86-li" -host omn@vb-28 -host omn@vb-48
   monmemu_plot.sh -starttime 09:00 -match "reafer_pdu_pars|reafer" -host omn@vb-28 -host omn@vb-48
   monmemu_plot.sh -starttime "11:00 May 7" -endtime "18:30 May 7" -match "reafer_pdu_pars|reafer" -host omn@vb-28 -host omn@vb-48

e.g. retrieve and plot ALL processes being watched:
   # tar up of logfiles can cause delay, also can be too many items on plot  
   monmemu_plot.sh 

e.g. CHECK STATUS or STOP/START monmemu script remotely:
   monmemu_plot.sh status -host omn@vb-28  -host omn@vb-48
   monmemu_plot.sh stop -host omn@vb-28 -host omn@vb-48
   monmemu_plot.sh start -host omn@vb-28 -host omn@vb-48

EOF
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
 mem=\$1; vsz=\$2; c=\$3; pid=\$4; ts=\$5;
 echo "\$mem \$vsz \${c}_\${pid} \$ts" >> mem_\${c}_\${pid}.log; 
} 

mkdir -p ~/monmemu
cd ~/monmemu

date >>start.log

while true; do
 date >>last.log
 ts=\$(date +%s)
 ps -u omn -o "%mem=,vsz=,comm=,pid=" |sed "s/$/ \$ts/" |grep -Ev "grep|sleep|\bps\b|\bls\b" > mem.log
 while read line; do make_mem_entry \$line; done < mem.log
 sleep 2;
done

EOF

chmod 755 ~/bin/monmemu.sh

fi

DTS=$(date +%a%d%b_%H%M)
GNUPLOT_FILE=monmemu_${DTS}.gnuplot

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
            LASTFILE=\$(ls -tr monmemu/mem*.log |tail -1)
            ls -alstr \$LASTFILE; tail -2 \$LASTFILE
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

    # setting time range - default from beginning of mem.log to current time
    # gnuplot command e.g. set xrange [ "1/6/93":"1/11/93" ], where set timefmt "%d/%m/%y\t%H%M"
    # gnuplot command e.g. set xrange [ -3000:7000 ] ?? , where set timefmt ?? 
    if [[ $ENDTIME ]]; then 
        ENDTIME_T="$ENDTIME"
    else
        ENDTIME_T="now"
    fi
    if [[ $STARTTIME ]]; then 
        #STARTTIME_D=$(date -d "$STARTTIME")
        STARTTIME_S=$(date -d "$STARTTIME" +%s)
        STARTTIME_S_NOW=$(date -d "now" +%s)
        SETXRANGECMD1="# if only it were so simple! set xrange [ $STARTTIME_S:$STARTTIME_S_NOW ]"
        SETXRANGECMD2="TIMEOFFSET=1893370441"
        SETXRANGECMD3="set xrange [(system(\"date -d '$STARTTIME' +%s\")-TIMEOFFSET):(system(\"date -d '$ENDTIME' +%s\")-TIMEOFFSET)]"
        #SETXRANGECMD3="set xrange [(${STARTTIME_S}-TIMEOFFSET):${STARTTIME_S_NOW}-TIMEOFFSET)]"

        # TIMEOFFSET=1893370441 WTF!? I hear you say. Yeah.
        # http://stackoverflow.com/questions/9464437/gnuplot-plot-data-from-one-month-ago-to-now/30106359#30106359
    fi

    # NOTE: If starttime not set endtime is not used.
    # NOTE: If starttime/edntime not set range used is min to max in terms of time
    # TODO: how show / use max/min time on xrange ?

    cat >${GNUPLOT_FILE} <<EOF
#set term png small size 1024,800
#set output "mem-graph-${h}-${DTS}.png"

set label "$h"
set xlabel "$h time"
set xdata time
set timefmt "%s"
set format x "%H:%M"

set ylabel "VSZ"
set y2label "%MEM"

set ytics nomirror
set y2tics nomirror in

set yrange [0:*]
set y2range [0:*]

$SETXRANGECMD1
$SETXRANGECMD2
$SETXRANGECMD3

plot \\
EOF

    function make_plot_entry { 
        mem=$1; vsz=$2; c=$3; pid=$4; 
        echo "\"mem_${c}_${pid}.log\" using (timecolumn(4)):2 with lines axes x1y1 title \"VSZ_${c}_${pid}\", \\"; 
        echo "\"mem_${c}_${pid}.log\" using (timecolumn(4)):1 with lines axes x1y2 title \"%MEM_${c}_${pid}\" \\"; 
    } 

    function make_plot_entry_NOTIME { 
        mem=$1; vsz=$2; c=$3; pid=$4; 
        echo "\"mem_${c}_${pid}.log\" using 2 with lines axes x1y1 title \"VSZ_${c}_${pid}\", \\"; 
        echo "\"mem_${c}_${pid}.log\" using 1 with lines axes x1y2 title \"%MEM_${c}_${pid}\" \\"; 
    } 

    # e.g. with x and y axis offsets
    # $0 is line number
    # plot "mem_cobwebs_6907.log" using ($0+50):($2+27) with lines axes x1y1 title "Voo", "mem_cobwebs_6907.log" using ($2-270000)  with lines axes x1y1 title "Shoe"

    # add new (and old+ended) processes to list (into mem.log)
    MEMLOGFILES=$(find . -name "mem*.log" -newer start.log)
    # e.g. valgrind: mem_memcheck-x86-li_31719.log
    #[james@nebraska ~]$ grep reafer  /home/james/monmemu-omn@vb-28/monmemu/mem.log
    #0.1 268376 reafer          12704

    echo "Adding new processes to list (if needed) . . . "
    for f in $MEMLOGFILES; do
        f1=${f#*mem_}
        f1=${f1%.log}
        pid=${f1##*_}
        pname=${f1%_*}
        #echo f=$f base=$f1 pid=$pid pname=$pname
        THERE=$(grep "$pname.*$pid" mem.log)
        if [[ -z $THERE ]] ; then
            ## no entry in mem.log - so we add one
            echo "Add entry for process name=$pname pid=$pid"
            echo "0.0 0 $pname $pid" >> mem.log
        fi
    done

    FIRSTCOMMA=0
    while read line; do
        if ( echo "$line"|grep -E "$match" ) ; then 
            [[ "$FIRSTCOMMA" != 0 ]] && echo -n ", " >>${GNUPLOT_FILE};
            [[ "$FIRSTCOMMA" == 0 ]] && FIRSTCOMMA=1;
            make_plot_entry $line >>${GNUPLOT_FILE}; 
        fi
    done < mem.log
    echo "" >> ${GNUPLOT_FILE}

    gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-${DTS}-key.png\";" ${GNUPLOT_FILE}
    display mem-graph-${h}-${DTS}-key.png &
    gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-${DTS}-nokey.png\";set key off" ${GNUPLOT_FILE} ; 
    display mem-graph-${h}-${DTS}-nokey.png &
    # interactive
    gnuplot ${GNUPLOT_FILE} -e "pause 60";

done
