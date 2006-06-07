if [[ -f "$1" ]] ; then
  LOGFILE=$1
else
  echo "usage: $0 <logfile> [<testname> [<batch>]]"
  echo "       in batch mode no gnuplot interactivity"
  exit
fi

TESTNAME=$2
BATCH=$3

ts=`date +"%Y%m%d-%H%M"`

#LOGFILE=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT 
echo LOGFILE $LOGFILE

if [[ $BATCH == "" ]] ; then
  TMP=/tmp/$USER
  mkdir -p $TMP
  TESTNAME=$LOGFILE
else
  TMP=.
fi

RATEFILE=$LOGFILE
GNUPLOTFILE=$TMP/plotmem.gnuplot

#Data in:
#Jan 18 128M
#Mon Jan 23 13:57:22 GMT 2006 367 emoyniha 174M 144M sleep 59 0 9:38:09 3.7% rps/6
#Mon Jan 23 13:58:23 GMT 2006 367 emoyniha 174M 144M sleep 54 0 9:38:11 3.6% rps/6
#Mon Jan 23 13:59:23 GMT 2006 367 emoyniha 174M 144M sleep 49 0 9:38:14 3.6% rps/6
#Mon Jan 23 14:00:23 GMT 2006 367 emoyniha 175M 144M run 39 0 9:38:16 3.7% rps/6

GNUPLOTSTUFF="set xdata time;
set timefmt \"%b %d %H:%M:%S GMT %Y;\"
"
echo $GNUPLOTSTUFF >$GNUPLOTFILE
echo set title \"$TESTNAME\" >>$GNUPLOTFILE
echo set xlabel \"uptime\" >>$GNUPLOTFILE
echo set ylabel \"PDUs\" >>$GNUPLOTFILE

GNUPLOTCMD="plot \"$RATEFILE\" using 2:9 title 'Proc Size',
  \"$RATEFILE\" using 2:10 title 'RSS',
  \"$RATEFILE\" using 2:14 title 'Time',
  \"$RATEFILE\" using 2:15 title 'CPU'"

if [[ $BATCH == "" ]] ; then
  echo $GNUPLOTCMD
  echo $GNUPLOTCMD >>$GNUPLOTFILE
  echo pause -1  \"Hit return to continue\" >> $GNUPLOTFILE
fi

OUTNAME=CPUandMEM
echo set terminal png >>$GNUPLOTFILE
echo set output \"$OUTNAME.png\" >>$GNUPLOTFILE
echo $GNUPLOTCMD >>$GNUPLOTFILE

echo set output \"$OUTNAME-MEM.png\" >>$GNUPLOTFILE
GNUPLOTCMD="plot \"$RATEFILE\" using 2:9 title 'Process Size'"
echo $GNUPLOTCMD >>$GNUPLOTFILE

echo set output \"$OUTNAME-CPU.png\" >>$GNUPLOTFILE
GNUPLOTCMD="plot \"$RATEFILE\" using 2:15 title 'Process CPU usage'"
echo $GNUPLOTCMD >>$GNUPLOTFILE

if [[ $BATCH == "" ]] ; then
  ls -al $GNUPLOTFILE
  cat $GNUPLOTFILE
  gnuplot $GNUPLOTFILE -
else
  gnuplot $GNUPLOTFILE
fi

#LOGFILE=~/tmp/IuPSDecodeIupsRewrite.txt-Uptime-MemDump-IupsChannelMgr
#grep -i mem ~/tmp/IuPSDecodeIupsRewrite.txt-Uptime-MemDump-IupsChannelMgr 

#egrep "^(Uptime|MEM_DUMP)" $LOGFILE |grep -v Threads|sed -e :a -e '/Uptime: .*$/N; s/Uptime: \(.*\)\n/up\1 /; ta' |sed "s/MEM_DUMP.*Sys Mem://"|sed "s/^up[0-9][0-9]* up/up/g"|sed "s/[^0-9\.]/ /g" | sed "s/  */ /g" >$RATEFILE

#1134 2.0 867.2 394.1 389.8 19.99 0.00



# plot "/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT"  using 2:9 title 'Proc Size', "/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT"  using 2:10 title 'RSS', "/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT"  using 2:14 title 'Time',"/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT" using 2:15 title 'CPU'
