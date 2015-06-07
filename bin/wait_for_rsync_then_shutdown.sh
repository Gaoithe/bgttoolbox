#!/bin/bash

GREP="kdenlive_render|inigo"
GREP=rsync
[[ ! -z $1 ]] && GREP="$1"

ME=`whoami`
if [[ $ME != root ]] ; then
    echo "Need to run this as root. ME=$ME"
    exit 0;
fi

while [[ 1 == 1 ]]; do 
    P=`ps -elf |egrep "$GREP"|egrep -v "grep|wait_"`; 
    echo foo$P; 
    ls -alstr kdenlive/ |tail -1
    if [[ -z "$P" ]] ; then 
        shutdown -h now; 
    fi 
    sleep 5
done

