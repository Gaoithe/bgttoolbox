#!/bin/bash

BORROWER=D2000000204552
PIN=2323
MAILTO="jamesc@dspsrv.com"
MAILPROG="mail -r jamesc@dspsrv.com"
# my qmail is configured not-so-goodly :-7

library-check.pl -m "$MAILPROG" $BORROWER $PIN $MAILTO
