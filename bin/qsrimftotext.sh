#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

FILE=$1
[[ ! -e $FILE ]] && echo "error: file:$FILE Doesn't Exist." && echo "usage: $0 <file.ch13>" && exit
NEWFILE=${FILE%%.*}_text.${FILE##*.}

cat $FILE | sed -r 's/(.*text.*: \[)([0-9a-fA-F]*)\]/\1$(echo \2|xxd -r -p)]/;s/^(.*)$/echo "\1"/g' |bash > $NEWFILE
ls -alstr $NEWFILE
echo "Please see file:$NEWFILE"


