#!/bin/bash

function make_mem_entry { mem=$1; vsz=$2; c=$3; pid=$4; echo "$mem $vsz ${c}_${pid}" >> mem_${c}_${pid}.log; } 

mkdir -p /apps/omn/monmemu
cd /apps/omn/monmemu

date >>start.log

while true; do
 date >>last.log
 ps -u omn -o "%mem=,vsz=,comm=,pid=" |grep -Ev "grep|sleep|\bps\b|\bls\b" > mem.log
 while read line; do make_mem_entry $line; done < mem.log
 sleep 10;
done

