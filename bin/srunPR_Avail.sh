#!/bin/bash

P=-7d
P=-4d

DTS=$(date +%Y%m%d%H%M)
#exec 3>&1 4>&2 > srunPR_avail_${DTS}.log 2>&1
LOG=srunPR_avail_${DTS}.log

source srunPRHOSTS.sh

DOHOSTS=" $AR_HOSTS $C_SMSC_HOSTS $M_SMSC_HOSTS $C_CARE_HOSTS $M_CARE_HOSTS"
#DOHOSTS="10.109.6.13 10.109.22.13 10.109.6.4 10.109.22.4"

for h in $DOHOSTS; do
   echo h=$h;
   #ssh omn@$h -i ${SSHPR} "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bin/bci -listals"
   #ssh omn@$h -i ${SSHPR} 'corefiles=$(ls -tr core-dumps/*core*); bin/bci -listals; ls -alstr *core*; for c in $corefiles; do echo h=$h c=$c; b=$(echo $c |sed "s/^core-dumps\/core\.//;s/\-.*//;s/\..*//"); echo b=$b; ls -al $c bin/$b; echo "bt" |gdb -c $c bin/$b; done'
   #ssh omn@$h -i ${SSHPR} 'echo h=$h; ls -alstr *core*; echo ALARMS:; bin/bci -listals; bin/clex -ch 2 -s '"${P}"' |grep Availab'
   ssh omn@$h -i ${SSHPR} 'echo h=$h; ls -alstr *core*; echo ALARMS:; bin/bci -listals; bin/clex -ch 2 -s '"${P}"' |grep Availab; bin/clex -ch 0 -s '"${P}"' |grep -vP "shep|TRON field exi"; '
done 2>&1 |tee -a $LOG

