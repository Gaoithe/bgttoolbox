
if [[ "$1" == "" ]] ; then
  echo "usage: $0 <logfile>"
  exit
fi

#LOGFILE=~/tmp/IuPSLog.txt
LOGFILE=$1
echo LOGFILE $LOGFILE

TMP=/tmp/$USER
mkdir -p $TMP
#RATEFILE=${LOGFILE}-PDUrate.dat
RATEFILE=$TMP/PDUrate.dat
GNUPLOTFILE=$TMP/pdurateplot.gnuplot

#Data in:
#Uptime: 1123
#Uptime: 1134
#MEM_DUMP: Thu Oct 20 16:31:45 2005   Sys Mem: 2.0G  Free Mem: 867.2M  Proc Size: 394.1M  Resonent Set Size: 389.8M  %MEM: 19.99%  %CPU: 0.00%
#Ratefile:

#|sed "s/^.*MEM_DUMP/MEM_DUMP/"|sed "s/^.*Uptime/Uptime/"
egrep "^(Uptime|MEM_DUMP)" $LOGFILE |grep -v Threads|sed -e :a -e '/Uptime: .*$/N; s/Uptime: \(.*\)\n/up\1 /; ta' |sed "s/MEM_DUMP.*Sys Mem://"|sed "s/^up[0-9][0-9]* up/up/g"|sed "s/\([^0-9\.]\)[^0-9\.][^0-9]*/\1 /g" | sed "s/  */ /g" |sed "s/^u //"|sed "s/ \([0-9][0-9]*\\).\([0-9][0-9]*\)G/ \1000000000/g" |sed "s/ \([0-9][0-9]*\\).\([0-9][0-9]*\)M/ \1000000/g" >$RATEFILE
ls -al $RATEFILE
GNUPLOTCMD="plot \"$RATEFILE\" using 1:3 title 'Free Mem',
  \"$RATEFILE\" using 1:4 title 'Proc size'"

echo $GNUPLOTCMD
echo $GNUPLOTCMD >$GNUPLOTFILE
echo pause -1  \"Hit return to continue\" >> $GNUPLOTFILE
ls -al $GNUPLOTFILE
cat $GNUPLOTFILE
gnuplot $GNUPLOTFILE


#LOGFILE=~/tmp/IuPSDecodeIupsRewrite.txt-Uptime-MemDump-IupsChannelMgr
#grep -i mem ~/tmp/IuPSDecodeIupsRewrite.txt-Uptime-MemDump-IupsChannelMgr 

#egrep "^(Uptime|MEM_DUMP)" $LOGFILE |grep -v Threads|sed -e :a -e '/Uptime: .*$/N; s/Uptime: \(.*\)\n/up\1 /; ta' |sed "s/MEM_DUMP.*Sys Mem://"|sed "s/^up[0-9][0-9]* up/up/g"|sed "s/[^0-9\.]/ /g" | sed "s/  */ /g" >$RATEFILE

#1134 2.0 867.2 394.1 389.8 19.99 0.00
