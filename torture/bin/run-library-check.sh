#!/bin/bash

BORROWER=D2000000204552
PIN=2323
MAILTO="jamesc@dspsrv.com,fionnuala@callan.de"
MAILPROG="mail -r jamesc@dspsrv.com"
# my qmail is configured not-so-goodly :-7

#library-check.pl -M -m "$MAILPROG" $BORROWER $PIN $MAILTO
RETVAL=77

export PATH=$PATH:/usr/local/bin

while [[ $RETVAL != 0 ]] ; do
  library-check.pl -m "$MAILPROG" $BORROWER $PIN $MAILTO
  RETVAL=$?
  if [[ $RETVAL != 0 ]] ; then
     echo Failed to run. :-7 RETVAL is $RETVAL. Sleep 600 and try again. 
     sleep 600
     echo Here we go again ...
  fi
done

echo Success. I think.
date

