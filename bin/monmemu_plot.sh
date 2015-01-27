#!/bin/bash

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

### START:
#h=<user>@<host>
#ssh $h "mkdir -p ~/bin/; ls ~/bin/monmemu.sh;
#scp ~/bin/monmemu.sh $h:bin/
#ssh $h "chmod 755 ~/bin/monmemu.sh
#PSINFO=$(ssh $h "ps -fu omn |grep monmemu.sh |grep -v grep")
#if [[ -z "$PSINFO" ]]; then 
#  mkdir -p ~/monmemu;
#  nohup ~/bin/monmemu.sh > ~/monmemu/nohup.out &
#fi


HOSTS="omn@vb-28 omn@vb-48"
for h in $HOSTS; do 

mkdir ~/monmemu-${h}
cd ~/monmemu-${h}

ssh $h tar -jcvf monmemu.tbz monmemu/
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
 [[ "$FIRSTCOMMA" != 0 ]] && echo -n ", " >>monmemu.gnuplot;
 [[ "$FIRSTCOMMA" == 0 ]] && FIRSTCOMMA=1;
 make_plot_entry $line >>monmemu.gnuplot; 
done < mem.log
echo "" >> monmemu.gnuplot

gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-key.png\";" monmemu.gnuplot
display mem-graph-${h}-key.png &
gnuplot -e "set term png small size 1024,800; set output \"mem-graph-${h}-nokey.png\";set key off" monmemu.gnuplot ; 
display mem-graph-${h}-nokey.png &
# interactive
gnuplot monmemu.gnuplot -e "pause 60";

done
