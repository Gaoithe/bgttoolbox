#!/bin/bash

#mauritania_tunnel down && mauritania_tunnel up

DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/snapMR_${DTS}.log
date |tee -a ${LOG}

PERIOD=1d
PERIOD=1h
PERIOD=40m
PERIOD=20m
EPERIOD=2m
SPERIOD=10m
SPERIOD=20s

HOSMCN="192.168.102.21 192.168.102.22"

iTryTunnelUp=0

for h in $HOSMCN; do
 echo HOST=$h |tee -a ${LOG}
 # log locally and in /tmp/ on host
 notdone=255
 iTryHost=0
 while [[ $notdone == 255 && $iTryHost < 1 ]] ; do
    ((iTryHost++))
    ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; bin/sci -list; bin/mci list; scripts/cstat_telstar.sh; bin/clex -ch 0 -s -${PERIOD}; bin/clex -ch 2 -s -${EPERIOD}; bin/clex -ch 3 -s -${SPERIOD} >/tmp/3.log; cat /tmp/3.log |bin/reafer_pdu_parse -pdus; cat /tmp/3.log |bin/clog_parse|grep -v \"  .*\.\..*$\"; bin/clex -ch 4 -s -${SPERIOD}; bin/clex -ch 7 -s -${SPERIOD}; } |tee -a /tmp/$LOG" |tee -a ${LOG}
    #echo ${PIPESTATUS[@]}
    #notdone=$?
    notdone=${PIPESTATUS[0]}
    # ssh exits with the exit status of the remote command or with 255 if an error occurred.
    echo error=$notdone iTryHost=$iTryHost iTryTunnelUp=$iTryTunnelUp
    if [[ $notdone == 255 && $iTryTunnelUp < 2 ]] ; then
        # # the annoying thing is that if password prompt and we are too slow it fails, falls in here and restarts tunnel
        mauritania_tunnel down && mauritania_tunnel up
        ((iTryTunnelUp++))
        ((iTryHost--))
    fi
 done
done

