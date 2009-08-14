#!/bin/bash

# march 2009 new card for Daire and 3,$s/fionnuala.callan@s3group.com/fionnuala.callan@s3group.com/g
# BORROWER=D2000000204552
BORROWER=D2000000219515
PIN=2323
MAILTO="jamesc@dspsrv.com,fionnuala.callan@s3group.com"
#MAILTO="jamesc@dspsrv.com"
MAILPROG="mail -r jamesc@dspsrv.com"
# my qmail is configured not-so-goodly :-7

LOGROTATEBIN="/usr/sbin/logrotate -s /tmp/mic-logrotate-status.log"
LOGFILE=/tmp/run-library-check.log
#LOGFILE=/tmp/run-library-check-`date +"%Y%m%d%H%M%S"`.log
echo logrotate $LOGROTATEBIN $LOGFILE
$LOGROTATEBIN $LOGFILE

RETVAL=77

export PATH=$PATH:/usr/local/bin

#need half hour for sleep 600 retry an MAX_RETRY
MAX_RETRY=6
TRY_COUNT=0

while [[ $RETVAL != 0 ]] ; do
   TRY_COUNT=$(( $TRY_COUNT + 1 ))
   library-check.pl -m "$MAILPROG" $BORROWER $PIN $MAILTO 2>&1 >$LOGFILE
   RETVAL=$?
   if [[ $RETVAL != 0 ]] ; then
      if (( $TRY_COUNT > $MAX_RETRY )) ; then 
	  echo Tried $TRY_COUNT times. Give up.
	  echo Tried $TRY_COUNT times. Give up. >> $LOGFILE
	  echo Sending fail email: $MAILPROG $MAILTO -s \"$0 failed\" -a $LOGFILE 
	  $MAILPROG $MAILTO -s "$0 failed" -a $LOGFILE </dev/null
      fi
      echo Failed to run. :-7 RETVAL is $RETVAL. Sleep 600 and try again. 
      sleep 600
      echo Here we go again ... $TRY_COUNT
   fi
done

if [[ $RETVAL != 0 ]] ; then
   echo Failed.
else
   echo Success. I think.
fi
date

