#!/bin/bash

#mauritania_tunnel down && mauritania_tunnel up

DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/sshMR_${DTS}.log
date |tee -a ${LOG}

HOSMCN="192.168.102.21 192.168.102.22"

iTryTunnelUp=0

for h in $HOSMCN; do
 echo HOST=$h |tee -a ${LOG}
 # log locally and in /tmp/ on host
 notdone=255
 iTryHost=0
 while [[ $notdone == 255 && $iTryHost < 1 ]] ; do
    ((iTryHost++))
    ssh omn@$h |tee -a ${LOG}
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
    else 
        # one success so we exit
        exit
    fi
 done
done

