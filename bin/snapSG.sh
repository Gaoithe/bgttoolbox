#!/bin/bash

#senegal_tunnel down && senegal_tunnel up

DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/snapSG_${DTS}.log
date |tee -a ${LOG}

PERIOD=1d
PERIOD=1h
PERIOD=40m
PERIOD=20m
EPERIOD=2m
SPERIOD=10m
SPERIOD=20s

HOSMCNSG="10.71.171.3 10.71.171.2"
HOSMCNSG="10.71.171.2 10.71.171.3"

iTryTunnelUp=0

for h in $HOSMCNSG; do
 echo HOST=$h |tee -a ${LOG}
 # log locally and in /tmp/ on host
 notdone=42
 while [[ $notdone != 0 && $iTryTunnelUp < 2 ]] ; do
    ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; scripts/cstat_telstar.sh; bin/clex -ch 0 -s -${PERIOD}; bin/clex -ch 2 -s -${EPERIOD}; bin/clex -ch 3 -s -${SPERIOD} >/tmp/3.log; cat /tmp/3.log |bin/reafer_pdu_parse -pdus; cat /tmp/3.log |bin/clog_parse|grep -v \"  .*\.\..*$\"; bin/clex -ch 4 -s -${SPERIOD}; bin/clex -ch 7 -s -${SPERIOD}; } |tee -a /tmp/$LOG" |tee -a ${LOG}
    #echo ${PIPESTATUS[@]}
    #notdone=$?
    notdone=${PIPESTATUS[0]}
    echo error=$notdone iTryTunnelUp=$iTryTunnelUp
    if [[ $notdone != 0 ]] ; then
        senegal_tunnel down && senegal_tunnel up
        ((iTryTunnelUp++))
    fi
 done
done

