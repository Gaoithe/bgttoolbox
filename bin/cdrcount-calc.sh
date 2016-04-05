#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

echo e.g. usage cdrcount-calc.sh countcdrs_150316_*.txt |tee countcdrs_150316Calculations.txt

for FILE in $*; do 
    #  FILE=countcdrs_150316_0011223345.txt
    echo
    echo FILE=$FILE
    
    # sanity check 
    NOT_HANDLED=$(grep -vE "358,|869," $FILE)
    [[ ! -z $NOT_HANDLED ]] && echo "WARNING: DID NOT HANDLE $NOT_HANDLED"
    
    SOURCE_SUCCESS=$(grep 358, $FILE | grep -E ",DELIVERED,|,DELIVERED$|,USER_CANCEL_HANDSET")
    if [[ ! -z $SOURCE_SUCCESS ]] ; then 
      SUM=$(echo "$SOURCE_SUCCESS" |awk '{print $1}' |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo "$SOURCE_SUCCESS"
      echo SOURCE DELIVERED SUM=$SUM tot=$(($SUM))
    fi
    SOURCE_FAIL=$(grep 358, $FILE | grep -vE ",DELIVERED,|,DELIVERED$|,USER_CANCEL_HANDSET")
    if [[ ! -z $SOURCE_FAIL ]] ; then 
      SUM=$(echo "$SOURCE_FAIL" |awk '{print $1}' |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo "$SOURCE_FAIL"
      echo SOURCE FAILED SUM=$SUM tot=$(($SUM))
    fi

    echo SOURCE END DEST BEGIN
    
    DEST_SUCCESS=$(grep 869, $FILE | grep -E ",DELIVERED,|,DELIVERED$|,USER_CANCEL_HANDSET")
    if [[ ! -z $DEST_SUCCESS ]] ; then 
      SUM=$(echo "$DEST_SUCCESS" |awk '{print $1}' |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo "$DEST_SUCCESS"
      echo DEST DELIVERED SUM=$SUM tot=$(($SUM))
    fi
    DEST_FAIL=$(grep 869, $FILE | grep -vE ",DELIVERED,|,DELIVERED$|,USER_CANCEL_HANDSET")
    if [[ ! -z $DEST_FAIL ]] ; then 
      SUM=$(echo "$DEST_FAIL" |awk '{print $1}' |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo "$DEST_FAIL"
      echo DEST FAILED SUM=$SUM tot=$(($SUM))
    fi

done

