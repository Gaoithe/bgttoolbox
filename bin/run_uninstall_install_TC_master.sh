#!/bin/bash

HOST=$1
[[ "$HOST" == "" ]] && HOST=vb-28

ROOTUSER=vroot
[[ "${HOST:0:2}" != "vb" ]] && ROOTUSER=root

echo ==============================================
echo ========== RE-INSTALLING HOST=$HOST ==========
echo ==============================================
sleep 1

## SETUP .ssh keys as vroot and omn user on each vbox and place in your authorized keys 
#[omn@vb-28] ssh-keygen -t rsa
#[omn@vb-28] cat ~/.ssh/id_rsa.pub     # place this pub key into ~james/.ssh/authorized_keys
#[omn@vb-28] vi ~/.ssh/authorized_keys #place local pub key(by ssh-keygen) and remote pub key in here 


scp ~/bin/run_uninstall_TC.sh omn@${HOST}:scripts/
scp ~/bin/run_install_TC.sh omn@${HOST}:scripts/
#scp ~/bin/run_rejoin_TC.sh omn@${HOST}:scripts/
scp ~/bin/run_solo_start_TC.sh omn@${HOST}:scripts/
scp ~/bin/run_provision_TC.sh omn@${HOST}:scripts/

ssh ${ROOTUSER}@${HOST} /apps/omn/scripts/run_uninstall_TC.sh |tee -a TC_uninstall.log; 

monmemu_plot.sh stop -host omn@${HOST}

# TODO, how to run these in parallel ?
echo -n INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT 
$INSTALL_FROM_SLINGSHOT && echo -n " INSTALL_LATEST=$INSTALL_LATEST REL=$REL PLAT=$PLAT "
echo ssh ${ROOTUSER}@${HOST} run_install_TC.sh $HOST 
ssh ${ROOTUSER}@${HOST} "INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT INSTALL_LATEST=$INSTALL_LATEST PLAT=$PLAT REL=$REL /apps/omn/scripts/run_install_TC.sh" |tee -a TC_install_${HOST}.log; 

#ssh omn@${HOST} /apps/omn/scripts/run_solo_start_TC.sh |tee -a TC_solo_start.log; 
#ssh omn@vb-48 /apps/omn/scripts/run_rejoin_TC.sh |tee -a TC_rejoin.log; 
#ssh omn@${HOST} /apps/omn/scripts/run_provision_TC.sh |tee -a TC_provision.log; 


