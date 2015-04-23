#!/bin/bash

function make_mem_entry {
 mem=$1; vsz=$2; c=$3; pid=$4; ts=$5;
 echo "$mem $vsz ${c}_${pid} $ts" >> mem_${c}_${pid}.log; 
} 

mkdir -p ~/monmemu
cd ~/monmemu

date >>start.log

while true; do
 date >>last.log
 ts=$(date +%s)
 ps -u omn -o "%mem=,vsz=,comm=,pid=" |sed "s/$/ $ts/" |grep -Ev "grep|sleep|\bps\b|\bls\b" > mem.log
 while read line; do make_mem_entry $line; done < mem.log
 sleep 2;
done

