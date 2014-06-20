
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

#LOGFILE=~/tmp/IuPSLog.txt
echo LOGFILE $LOGFILE

if [[ $BATCH == "" ]] ; then
  TMP=/tmp/$USER
  mkdir -p $TMP
  TESTNAME=$LOGFILE
else
  TMP=.
fi

#RATEFILE=${LOGFILE}-PDUrate.dat
RATEFILE=$TMP/PDUrate.dat
GNUPLOTFILE=$TMP/pdurateplot.gnuplot

#Data in:
#Uptime: 1
#Rate of Processing PDUs:           6840 PDUs per second
#Ratefile:
#1 6840

echo set label \"$TESTNAME\" >$GNUPLOTFILE
echo set xlabel \"uptime\" >>$GNUPLOTFILE
echo set ylabel \"PDUs\" >>$GNUPLOTFILE


# sed label a: and ta; #take branch a
egrep "^(Uptime|Rate of Process|PDUs Read|Out of sequence)" $LOGFILE |grep -v Threads |sed -e :a -e '/Uptime.*$/N; /Uptime: .*$/N; /Uptime: .*$/N; s/Uptime\(.*\)\n\(.*\)\n\(.*\)\n/\1 \2 \3/; s/[^0-9 ]//g; ta;'| sed "s/  */ /g" >$RATEFILE
ls -al $RATEFILE
tail -600 $RATEFILE >$RATEFILE-last600
tail -100 $RATEFILE >$RATEFILE-last100


if [[ $BATCH == "" ]] ; then

  GNUPLOTCMD="plot \"$RATEFILE\" using 1:4 title 'PDUs per sec' with linespoints,
    \"$RATEFILE\" using 1:2 title 'PDUs Read' with linespoints,
    \"$RATEFILE\" using 1:3 title 'PDUs Out Of Seq' with linespoints"
  echo $GNUPLOTCMD
  echo $GNUPLOTCMD >>$GNUPLOTFILE
  echo pause -1  \"Hit return to continue\" >> $GNUPLOTFILE
  
  GNUPLOTCMD="plot \"$RATEFILE-last600\" using 1:4 title 'PDUs per sec' with linespoints,
    \"$RATEFILE-last600\" using 1:2 title 'PDUs Read' with linespoints,
    \"$RATEFILE-last600\" using 1:3 title 'PDUs Out Of Seq' with linespoints"
  echo $GNUPLOTCMD
  echo $GNUPLOTCMD >>$GNUPLOTFILE
  echo pause -1  \"Hit return to continue\" >> $GNUPLOTFILE

fi

OUTRATENAME=PDURate
echo set terminal png >>$GNUPLOTFILE
echo set output \"$OUTRATENAME.png\" >>$GNUPLOTFILE

GNUPLOTCMD="plot \"$RATEFILE\" using 1:4 title 'PDUs per sec' with linespoints,
    \"$RATEFILE\" using 1:2 title 'PDUs Read' with linespoints,
    \"$RATEFILE\" using 1:3 title 'PDUs Out Of Seq' with linespoints"
echo $GNUPLOTCMD
echo $GNUPLOTCMD >>$GNUPLOTFILE

echo set output \"PDUsRead.png\" >>$GNUPLOTFILE
GNUPLOTCMD="plot \"$RATEFILE\" using 1:2 title 'PDUs Read' with linespoints"
echo $GNUPLOTCMD
echo $GNUPLOTCMD >>$GNUPLOTFILE

echo set output \"PDUsOOS.png\" >>$GNUPLOTFILE
GNUPLOTCMD="plot \"$RATEFILE\" using 1:3 title 'PDUs Out of Seq' with linespoints"
echo $GNUPLOTCMD
echo $GNUPLOTCMD >>$GNUPLOTFILE

GNUPLOTCMD="plot \"$RATEFILE-last600\" using 1:2 title 'PDUs Read' with linespoints"
echo $GNUPLOTCMD
#echo $GNUPLOTCMD >>$GNUPLOTFILE
#echo pause -1  \"Hit return to continue\" >> $GNUPLOTFILE
echo set output \"$OUTRATENAME-last600.png\" >>$GNUPLOTFILE
echo $GNUPLOTCMD >>$GNUPLOTFILE

GNUPLOTCMD="plot \"$RATEFILE-last100\" using 1:2 title 'PDUs Read' with linespoints"
echo $GNUPLOTCMD
echo set output \"$OUTRATENAME-last100.png\" >>$GNUPLOTFILE
echo $GNUPLOTCMD >>$GNUPLOTFILE

if [[ $BATCH == "" ]] ; then
  ls -al $GNUPLOTFILE
  cat $GNUPLOTFILE
  gnuplot $GNUPLOTFILE -
else
  gnuplot $GNUPLOTFILE
fi

# Ranges:
#show all
#This sets xmax and ymin only:
#     plot [:200] [-pi:]  exp(sin(x))
#This sets the x range for a timeseries:
#     set timefmt "%d/%m/%y %H:%M"
#     plot ["1/6/93 12:00":"5/6/93 12:00"] 'timedata.dat'

#show xrange                                                               
#        set xrange [ * : * ] noreverse nowriteback  # (currently [485583.:505746.] )
#set xrange [485583.:]  
# Fit http://gnuplot.sourceforge.net/docs_4.1/node69.html#1329
# "by making y a 'pseudo-variable', e.g., the dataline number" (column -1 for line of file)
# http://gnuplot.sourceforge.net/docs_4.1/node78.html#fit_multi-branch

# old: egrep "^(Uptime|Rate of Processing PDUs)" $LOGFILE |sed -e :a -e '/Uptime: .*$/N; s/Uptime: \(.*\)\n/\1/; ta' |sed "s/Rate of Processing PDUs: */ /" | sed "s/PDUs per second//" >$RATEFILE

#egrep "^(Uptime|Rate of Process|PDUs Read|Out of sequence)" $LOGFILE |sed -e :a -e '/Uptime.*$/N; /Uptime: .*$/N; /Uptime: .*$/N; /Uptime: .*$/N; s/Uptime\(.*\)\n\(.*\)\n\(.*\)\n/\1 \2 \3/; ta;" >$RATEFILE
#sed -e :a -e '/Uptime: .*$/N; /Uptime: .*$/N; /Uptime: .*$/N; /Uptime: .*$/N; s/Uptime\(.*\)\n\(.*\)\n\(.*\)\n/\1 \2 \3/; ta;



# see ~/notes-octave on cygwin

#multi-line: (for log file combinations + grap statsplot)
#perl -00ne 'print "$1 $2\n" while m#(message type 0x11.*)\n(RANAP.*)\n#gm;' ~/tmp/perltest

#egrep "RANAP|message type" $LOGFILE |perl -00ne 'print "$1 $2\n" while m#(message type 0x11.*)\n(RANAP.*)\n#gm;'            

#perl -e 'print $1 if "This is my\nmulti-line string" =~ /^(.*)$/m' 
#perl -e 'print $1 if "This is my\nmulti-line string" =~ /^(.*)$mu/m' 
# cat ~/tmp/foo |perl -p -e "s/^(SCCP: message type 0x01)\$/foo \$1 foo\n/m"


# cat ~/tmp/foo |perl -p -e "s/^(SCCP: message type 0x01)\$(.*)\$(.*)\$(.*)\$/foo \$1 foo \$2 foo $3 bar\n/s"
#http://www.perl.com/pub/a/2003/06/06/regexps.html


# cat ~/tmp/foo |perl -p -i -e 's/^(SCCP: message type 0x01)$(..*)$/foo $1 foo $2 foo $3 bar\n/s'
#cat ~/tmp/foo |perl -ple 's/^(SCCP: message type 0x01)$(.*)$(.*)$/foo $1 foo $2 foo $3 bar\n/msg'


# join pairs of lines side-by-side (like "paste")
#sed '$!N;s/\n/ /'

# if a line ends with a backslash, append the next line to it
#sed -e :a -e '/\\$/N; s/\\\n//; ta'


#cat ~/tmp/foo |sed -e :a -e '/type 0x01$/N; s/\n//; ta'



#http://www.duke.edu/~hpgavin/gnuplot.html
      # This file is called   force.dat
      # Deflection    Col-Force       Beam-Force 
#      0.000              0              0    
#      0.001            104             51
#      0.002            202            101




# egrep "Uptime|PDUs per" $LOGFILE |sed -e :a -e '/Uptime: .*$/N; s/Uptime: \(.*\)\n/\1/; ta' |sed "s/Rate of Processing PDUs: */ /" | sed "s/PDUs per second//" >~/tmp/PDUrate.dat

#gnuplot> plot "../../../../../tmp/PDUrate.dat" using 1:2 title 'PDUs per sec' 
