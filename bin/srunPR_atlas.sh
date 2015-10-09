#!/bin/bash

DTS=$(date +%Y%m%d%H%M)
#exec 3>&1 4>&2 > srunPR_avail_${DTS}.log 2>&1
LOG=srunPR_atlas_${DTS}.log

source srunPRHOSTS.sh

for h in $AR_HOSTS  $C_SMSC_HOSTS $M_SMSC_HOSTS $C_CARE_HOSTS $M_CARE_HOSTS ; do
   echo h=$h;
   ssh omn@$h -i ${SSHPR} 'bin/aci |grep rip; netstat -anp |grep ripley; bin/aci; netstat -anp'
done 2>&1 |tee $LOG

