#!/bin/bash

exec 3>&1 4>&2 >> srunPR_lsblk.log 2>&1

source srunPRHOSTS.sh

for h in $AR_HOSTS $C_SMSC_HOSTS $M_SMSC_HOSTS $C_CARE_HOSTS $M_CARE_HOSTS; do
   echo h=$h;
   ssh omn@$h -i ${SSHPR} "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bci -listals"
done
