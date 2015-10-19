#!/bin/bash

#mauritania_tunnel down && mauritania_tunnel up

DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/snapMR_ch0andcoreandch2_${DTS}.log
date |tee -a ${LOG}

PERIOD=1d
#PERIOD=1h
#PERIOD=40m
#PERIOD=20m
EPERIOD=8h
EPERIOD=1d

HOSMCN="192.168.102.21 192.168.102.22"

iTryTunnelUp=0

for h in $HOSMCN; do
 echo HOST=$h |tee -a ${LOG}
 echo h=$h |tee -a ${LOG}
 # log locally and in /tmp/ on host
 notdone=255
 iTryHost=0
 while [[ $notdone == 255 && $iTryHost < 1 ]] ; do
    ((iTryHost++))
    ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; bin/clex -ch 0 -s -${PERIOD}; } |tee -a /dev/null" >> ${LOG}

    ssh omn@$h 'corefiles=$(ls -tr core-dumps/*core*); bin/bci -listals; ls -alstr *core*; for c in $corefiles; do echo h=$h c=$c; b=$(echo $c |sed "s/^core-dumps\/core\.//;s/\-.*//;s/\..*//"); echo b=$b; ls -al $c bin/$b; echo "bt" |gdb -c $c bin/$b; done' >> ${LOG}

    # The ch2 logs are full with parse error on response from CDMA ESME so grepping to remove that:
    ssh omn@$h 'bin/clex -ch 2 -s -'"$EPERIOD"' |grep -vP \'SCCP Addr::|BER Data|RoutingInfoForSM_Res{|IMSI{|^19/10/2015-\d\d:\d\d:\d\d\.\d\d\d *(}|FAILED|$)\' |grep -vP "CDMA_Notify has failed|CDMA_Notify attempting|CConf Replication" |tee /tmp/8hgv.ch2' >> ${LOG}

    # |tee -a /tmp/$LOG for local copy
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

