#!/bin/bash

function pstreewatch {
 PIDS=$(ps -elf |grep $1 |grep -v grep |awk '{print $4}')
 echo "MONITOR PIDS=$PIDS"
 while true; do
    for PID in $PIDS; do
       OUTPUT=$(pstree -p $PIDS -a); 
       echo "$OUTPUT"; 
       TO+="$OUTUT" 
    done; 
    [ "$TO" == "" ] && {
       echo "Nothing to do."
       break;
    }      
    sleep 2; 
 done
}

pstreewatch $*
