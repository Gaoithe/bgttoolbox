#!/bin/bash

DTS=$(date +%Y%m%d%H%M)
#exec 3>&1 4>&2 > srunPR_avail_${DTS}.log 2>&1
LOG=srunPR_${DTS}.log

source srunPRHOSTS.sh

for h in $AR_HOSTS $C_SMSC_HOSTS $M_SMSC_HOSTS; do
   echo h=$h;
   #ssh omn@$h -i ${SSHPR} "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bin/bci -listals"
   #ssh omn@$h -i ${SSHPR} 'corefiles=$(ls -tr core-dumps/*core*); bin/bci -listals; ls -alstr *core*; for c in $corefiles; do echo h=$h c=$c; b=$(echo $c |sed "s/^core-dumps\/core\.//;s/\-.*//;s/\..*//"); echo b=$b; ls -al $c bin/$b; echo "bt" |gdb -c $c bin/$b; done'
   #ssh omn@$h -i ${SSHPR} 'echo h=$h; ls -alstr *core*; bin/bci -listals; bin/clex -ch 2 -s -10d |grep Availab'
   ssh omn@$h -i ${SSHPR} 'echo h=$h; date'
done 2>&1 |tee $LOG

