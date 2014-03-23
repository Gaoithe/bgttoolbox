#!/bin/bash

ME=`whoami`
if [[ $ME != root ]] ; then
    echo "Need to run this as root. ME=$ME"
    exit 0;
fi

while [[ 1 == 1 ]]; do 
    P=`ps -elf |egrep "kdenlive_render|inigo"|egrep -v "grep|wait_"`; 
    echo foo$P; 
    ls -alstr kdenlive/ |tail -1
    if [[ -z "$P" ]] ; then 
        shutdown -h now; 
    fi 
    sleep 5
done

