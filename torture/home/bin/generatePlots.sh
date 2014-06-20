#!/bin/bash

# plot scripts require gnuplot and Image Magick

#TEST1=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_2012_emilia/rpslog/log
#TEST1=~/test/PRE_REL_1_2_0.0_2012_emilia/log
#TEST2=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_2012/netledge/rps/build/solaris/status.log
#TEST3=~/tmp/IupsNlAssert.log 

#TEST1=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1001_bianca/status.log
#TEST2=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1001_emilia/log
#TEST3=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1001_othello/status.log
#TEST4=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1001_iago/status.log

#TESTDIR=/store/testing/users/emoynihan/PRE_REL_1_2_0.0_1201
#TEST1=${TESTDIR}_deadlock/status.log
#TEST2=${TESTDIR}_emilia/log
#TEST3=${TESTDIR}_bianca/status.log
#TEST4=${TESTDIR}_iago/status.log
#TEST5=${TESTDIR}_othello/status.log

TESTDIR=/store/testing/users/emoynihan/

TEST1=$TESTDIR/PRE_REL_1_2_1.2_2401_iago
TEST1MEM=$TESTDIR/PRE_REL_1_2_1.2_2401_iago/MEM_USAGE
TEST2=$TESTDIR/PRE_REL_1_2_1.2_2401_othello
TEST2MEM=/store/testing/users/emoynihan/MEM_USAGE
TEST3=$TESTDIR/PRE_REL_1_2_0.0_1201_bianca
TEST3MEM=$TESTDIR/PRE_REL_1_2_0.0_1201_bianca/MEM_OUT
TEST4=$TESTDIR/PRE_REL_1_2_0.0_2301_desdemona
TEST4MEM=$TEST4/MEM_OUT
TEST5=$TESTDIR/PRE_REL_1_2_1.2_2401_emilia
TEST5MEM=$TEST5/MEM_USAGE

TEST1LOG=$TEST1/status.log
TEST2LOG=$TEST2/status.log
TEST3LOG=$TEST3/status.log
TEST4LOG=$TEST4/status.log
TEST5LOG=$TEST5/log

TESTDIRS="$TEST1 $TEST2 $TEST3 $TEST4 $TEST5"
TESTS="$TEST1LOG $TEST2LOG $TEST3LOG $TEST4LOG $TEST5LOG"


INDEX="newindex.html"
FINALINDEX="index.html"
PLOTSUM="plotsummary.html"
PLOTSUMCOUNT=0

# oh dear. 
# a library of cgi functions
# shoot me for not doing this in perl! :(

write-head () {
  lTITLE=$1
  lINDEX=$2
  lLINK=$3
  lLINKTEXT=$4
  mv $lINDEX old$lINDEX
  echo "<html><head>" > $lINDEX
  echo "<META HTTP-EQUIV=Refresh Content=300;URL=index.html>" >> $lINDEX
  echo "<title>$lTITLE</title>" >> $lINDEX
  echo "</head>" >> $lINDEX
  echo "<body>" >> $lINDEX
  echo "<h2>$lTITLE</h2>" >> $lINDEX
  echo "<p>Time: "`date +"%d-%m-%Y %H:%M:%S"`"</p>">> $lINDEX
  echo "<p><a href=$lLINK>$lLINKTEXT</a></p>" >> $lINDEX
  echo "<table>" >> $lINDEX
}

writeindex-head () {
  write-head "Test Monitor status index" "$INDEX" "$PLOTSUM" "Plot Summary"
}

writesum-head () {
  write-head "Test Monitor plot summary" "$PLOTSUM" "$INDEX" "Test Monitor index"
}

writedetail-head () {
  write-head "Test detail" "$INDEX" "../$INDEX" "Test Monitor index"
}

write-itemhead1 () {
  lINDEX=$1
  lMOD=$2
  echo "<tr><th $lMOD>$3</th></tr>" >> $lINDEX
}

write-itemhead3 () {
  lINDEX=$1
  echo "<tr><th>$2</th><th>$3</th><th>$4</th></tr>" >> $lINDEX
}

write-item3 () {
  lINDEX=$1
  echo "<tr><td>$2</td><td>$3</td><td>$4</td></tr>" >> $lINDEX
}

write-tail () {
  lINDEX=$1
  echo "</table>" >> $lINDEX
  echo "</body></html>" >> $lINDEX
}


testname-setup () { 

  if [[ -f "$1" ]] ; then
    lLOGFILE=$1
  else
    echo "usage: $0 <logfile> [<testname>]"
    echo plot scripts require gnuplot and Image Magick
    return -1
  fi

  TESTNAMEONLY=`echo $lLOGFILE |sed "s/\(.*\)\/\([^\.]*\)\(\..*\)*/LOGDIR=\1;LOGFILENAME=\2;LOGFILEEXT=\3;/"`
  eval $TESTNAMEONLY

  if [[ "$2" == "" ]] ; then
    TESTNAME=`echo $LOGDIR |sed "s/\//-/g"`-$LOGFILENAME-$LOGFILEEXT 
    TESTNAME=`echo $TESTNAME |sed "s/^\-*//"|sed "s/\-*$//"`
    TMPTESTDIR=$TESTNAME
  else
    TESTNAME=$2
    TMPTESTDIR=`echo $TESTNAME |sed "s/ /_/g"`
  fi

  TESTFILETIME=`ls -al $lLOGFILE |sed "s/  */ /g" |cut -f 6-8  '-d '`

  echo "$TESTNAMEONLY TESTNAME=$TESTNAME;TMPTESTDIR=$TMPTESTDIR;TESTFILETIME=\"$TESTFILETIME\";"
}

testprocess () {
  TESTDIR=$1
  TESTMEM=$2
  TESTLOG=$3
  echo LOG $TESTLOG DIR $TESTDIR 
  TESTSETUP=`testname-setup "$TESTLOG"`
  eval $TESTSETUP
  echo TEST NAME $TESTNAME

  if [[ "$TESTNAME" == "" ]] ; then
    echo ERROR processing $1 $2 $3
    write-item3 "$INDEX" "ERROR $TESTFILETIME" "$TESTLOG" "ERROR $TESTDIR $TESTMEM"
    return -1
  fi

  mkdir -p $TMPTESTDIR
  pushd .
  cd $TMPTESTDIR

  echo $TESTSETUP > testsetup.sh  
  touch logfilels.txt
  mv logfilels.txt logfilels.old
  ls -al "$TESTLOG" >logfilels.txt
  DIFF=`diff logfilels.txt logfilels.old`  
  if [[ "$DIFF" == "" ]] ; then
    echo STALE data. LOGFILE $TESTLOG time/size same as last time.
    INDEXTIME="<font color=brown>STALE $TESTFILETIME</font>"
  else
    INDEXTIME="<font color=green>$TESTFILETIME</font>"
  fi

  plotPDUrate.sh "$TESTLOG" "$TESTNAME" "BATCH"

  #rm *Thumb.*
  #genthumbs.sh .
  #PDUrate.dat.png
  #PDUrate.dat-last600.png
  #PDUrate.dat-last100.png
  #convert -scale 100 $1 $thumbnail

  writedetail-head  
  IMG=PDURate.png
  THUMB=PDURateThumb.png
  convert -scale 100 $IMG $THUMB

  IMG600=PDURate-last600.png
  THUMB600=PDURate-last600Thumb.png
  convert -scale 100 $IMG600 $THUMB600
  IMG100=PDURate-last100.png
  THUMB100=PDURateThumb-last100.png
  convert -scale 100 $IMG100 $THUMB100

  IMGR=PDUsRead.png
  THUMBR=PDUsReadThumb.png
  convert -scale 100 $IMGR $THUMBR
  IMGO=PDUsOOS.png
  THUMBO=PDUsOOSThumb.png
  convert -scale 100 $IMGO $THUMBO

  write-itemhead1 "$INDEX" "span=3" "PDU rate"
  write-item3 "$INDEX" "<a href=$IMG><img src=$THUMB></a><br>full detail" \
    "<a href=$IMG600><img src=$THUMB600></a><br>last 600" \
    "<a href=$IMG100><img src=$THUMB100></a><br>last 100"

  write-itemhead1 "$INDEX" "span=3" "PDU count and out of sequence (OOS)"
  write-item3 "$INDEX" "<a href=$IMGR><img src=$THUMBR></a><br>PDUs read" \
    "<a href=$IMGO><img src=$THUMBO></a><br>PDUs OOS" \
    ""

  # memory plot
  plotMem.sh "$TESTMEM" "$TESTNAME" "BATCH"
  IMGM1=CPUandMEM.png
  THUMBM1=CPUandMEMThumb.png
  convert -scale 100 $IMGM1 $THUMBM1
  IMGM2=CPUandMEM-MEM.png
  THUMBM2=CPUandMEM-MEMThumb.png
  convert -scale 100 $IMGM2 $THUMBM2
  IMGM3=CPUandMEM-CPU.png
  THUMBM3=CPUandMEM-CPUThumb.png
  convert -scale 100 $IMGM3 $THUMBM3

  write-itemhead1 "$INDEX" "span=3" "Process Memory and CPU"
  write-item3 "$INDEX" "<a href=$IMGM1><img src=$THUMBM1></a><br>Memory and CPU" \
    "<a href=$IMGM2><img src=$THUMBM2></a><br>Mem" \
    "<a href=$IMGM3><img src=$THUMBM3></a><br>CPU"

  write-tail "$INDEX"
  # replace page user sees shuffle
  cp $INDEX $FINALINDEX

  popd

  write-item3 "$INDEX" "$INDEXTIME" "<a href=$TMPTESTDIR>$TESTLOG</a>" ""

}

TMP=/tmp/$USER
mkdir -p $TMP
TESTMONDIR=$TMP
TESTMONDIR=$HOME/public_html/testmon
echo "Test Monitor files in $TESTMONDIR"
pushd .
mkdir -p $TESTMONDIR
cd $TESTMONDIR

writeindex-head
write-itemhead3 "$INDEX" "Time" "Logfile" "Other"
writesum-head
write-itemhead3 "$PLOTSUM" "Time" "Logfile" "Other"

testprocess $TEST1 $TEST1MEM $TEST1LOG
testprocess $TEST2 $TEST2MEM $TEST2LOG
testprocess $TEST3 $TEST3MEM $TEST3LOG
testprocess $TEST4 $TEST4MEM $TEST4LOG
testprocess $TEST5 $TEST5MEM $TEST5LOG

write-tail "$INDEX"
# replace page user sees shuffle
cp $INDEX $FINALINDEX

popd

exit

plotPDUrate.sh $TEST1LOG
plotPDUrate.sh $TEST2LOG
plotPDUrate.sh $TEST3LOG
plotPDUrate.sh $TEST4LOG
plotPDUrate.sh $TEST5LOG
# only test 5 is "normal" ALL OTHER STATS BEING weird or zeroed
#gnuplot> save "test5zoomPDUspersec.gplot"
#gnuplot> load "test5zoomPDUspersec.gplot" 


# bad PDUs
egrep -Hni "^(SSCOP|MTP3B|SCCP|RANAP)" $TESTS |egrep -v "\b0$" |tail -50
# PDU rate drops
grep -Hni "PDUs per second" $TESTS |grep -v [789][0-9][0-9] |tail -50

#egrep "Now time|PDUs per|^(SSCOP|MTP3B|SCCP|RANAP)" log  |grep -C11 "[ 12345].. PDUs"  
# before and after to make sure rate drops are associated exactly when bad PDUs are received

~/bin/FileListMon.pl -s screept $TESTS

#grep "PDUs per second" $TEST2 |grep -v [789][0-9][0-9]

