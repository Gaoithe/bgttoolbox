#!/bin/bash

exec 3>&1 4>&2 >> srunPR.log 2>&1

source srunPRHOSTS.sh

for h in $AR_HOSTS $C_SMSC_HOSTS $M_SMSC_HOSTS; do
   echo h=$h;
   ssh omn@$h "lsblk; ls -al /dev/mapper/; ls -alstr *core*; bci -listals"
done

