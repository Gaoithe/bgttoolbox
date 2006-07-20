#!/bin/bash

BORROWER=D2000000204552
PIN=2323
MAILTO="jamesc@dspsrv.com,fionnuala@callan.de"
MAILPROG="mail -r jamesc@dspsrv.com"
# my qmail is configured not-so-goodly :-7

export PATH=$PATH:/usr/local/bin

#library-check.pl -M -m "$MAILPROG" $BORROWER $PIN $MAILTO
library-check.pl -m "$MAILPROG" $BORROWER $PIN $MAILTO
