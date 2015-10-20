#!/bin/bash

DTS=$(date +%Y%m%d%H%M)
#exec 3>&1 4>&2 > srunNG_avail_${DTS}.log 2>&1
LOG=snapLOG/srunNG_${DTS}.log
PERIOD=1d
SPERIOD=1m
SPERIOD=1s

source srunNGHOSTS.sh
#NG_USSD_HOSTS="10.159.50.81 10.159.50.82 10.159.50.83"
#NG_CARE_HOSTS="10.159.50.41"

for h in $NG_USSD_HOSTS $NG_CARE_HOSTS; do
   echo h=$h
   ssh omn@$h 'bin/clex -ch 0 -s -3h grep -Pv "shep|TRON field"'
   #ssh omn@$h "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bin/bci -listals"
   ssh omn@$h 'corefiles=$(ls -tr core-dumps/*core*); bin/bci -listals; ls -alstr *core*; for c in $corefiles; do echo h=$h c=$c; b=$(echo $c |sed "s/^core-dumps\/core\.//;s/\-.*//;s/\..*//"); echo b=$b; ls -al $c bin/$b; echo "bt" |gdb -c $c bin/$b; done'
   #ssh omn@$h 'echo h=$h; ls -alstr *core*; bin/bci -listals; bin/clex -ch 2 -s -10d |grep Availab'

   #ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; bin/sci -list; bin/mci list; scripts/cstat_telstar.sh; bin/clex -ch 0 -s -${PERIOD}; bin/clex -ch 2 -s -${EPERIOD}; bin/clex -ch 3 -s -${SPERIOD} >/tmp/3.log; cat /tmp/3.log |bin/reafer_pdu_parse -pdus; cat /tmp/3.log |bin/clog_parse|grep -v \"  .*\.\..*$\"; bin/clex -ch 4 -s -${SPERIOD}; bin/clex -ch 7 -s -${SPERIOD}; tail -350 /logs/stats/stat_harvester.log; } |tee -a /dev/null"
   ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; bin/sci -list; bin/mci list; bin/clex -ch 0 -s -${PERIOD}; bin/clex -ch 2 -s -${EPERIOD}; bin/clex -ch 3 -s -${SPERIOD} >/tmp/3.log; cat /tmp/3.log |bin/reafer_pdu_parse -pdus; cat /tmp/3.log |bin/clog_parse|grep -v \"  .*\.\..*$\"; bin/clex -ch 4 -s -${SPERIOD}; bin/clex -ch 7 -s -${SPERIOD}; } |tee -a /dev/null" 

done 2>&1 |tee -a $LOG

