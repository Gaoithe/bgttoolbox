#!/bin/bash

#globacomgh_tunnel down && globacomgh_tunnel up
# 
DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/sshGH_${DTS}.log
date |tee -a ${LOG}

source srunGHHOSTS.sh
#GH_USSD_HOSTS="10.161.77.68 10.161.77.69"
#GH_CARE_HOSTS="10.161.77.70 10.161.77.71"

iTryTunnelUp=0

for h in $GH_USSD_HOSTS; do
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
        # an annoying thing is that if password prompt and we are too slow it fails, falls in here and restarts tunnel (IF we have not set up ssh key auth)
        globacomgh_tunnel down && globacomgh_tunnel up
        ((iTryTunnelUp++))
        ((iTryHost--))
    else 
        # one success so we exit
        exit
    fi
 done
done

