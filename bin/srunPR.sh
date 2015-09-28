#!/bin/bash

DTS=$(date +%Y%m%d%H%M)
#exec 3>&1 4>&2 > srunPR_avail_${DTS}.log 2>&1
LOG=srunPR_${DTS}.log

AR_HOSTS="10.109.6.13 10.109.6.14 10.109.22.13 10.109.22.14"
C_SMSC_HOSTS="10.109.6.4 10.109.6.5 10.109.6.6 10.109.6.7 10.109.6.8 10.109.6.9 10.109.6.10 10.109.6.11"
M_SMSC_HOSTS="10.109.22.4 10.109.22.5 10.109.22.6 10.109.22.7 10.109.22.8 10.109.22.9 10.109.22.10 10.109.22.11"

for h in $AR_HOSTS $C_SMSC_HOSTS $M_SMSC_HOSTS; do
   echo h=$h;
   #ssh omn@$h "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bin/bci -listals"
   ssh omn@$h 'corefiles=$(ls -tr core-dumps/*core*); bin/bci -listals; ls -alstr *core*; for c in $corefiles; do echo h=$h c=$c; b=$(echo $c |sed "s/^core-dumps\/core\.//;s/\-.*//;s/\..*//"); echo b=$b; ls -al $c bin/$b; echo "bt" |gdb -c $c bin/$b; done'
   #ssh omn@$h 'echo h=$h; ls -alstr *core*; bin/bci -listals; bin/clex -ch 2 -s -10d |grep Availab'
done 2>&1 |tee $LOG

