#!/bin/bash

HOST1=$1
[[ "$HOST1" == "" ]] && HOST1=vb-28

HOST2=$2
[[ "$HOST2" == "" ]] && HOST2=vb-48

## SETUP .ssh keys as vroot and omn user on each vbox and place in your authorized keys 
#[omn@vb-28] ssh-keygen -t rsa
#[omn@vb-28] cat ~/.ssh/id_rsa.pub     # place this pub key into ~james/.ssh/authorized_keys
#[omn@vb-28] vi ~/.ssh/authorized_keys #place local pub key(by ssh-keygen) and remote pub key in here 


#scp ~/bin/run_uninstall_TC.sh omn@${HOST1}:scripts/
#scp ~/bin/run_uninstall_TC.sh omn@${HOST2}:scripts/
#scp ~/bin/run_install_TC.sh omn@${HOST1}:scripts/
#scp ~/bin/run_install_TC.sh omn@${HOST2}:scripts/
scp ~/bin/run_solo_start_TC.sh omn@${HOST1}:scripts/
scp ~/bin/run_rejoin_TC.sh omn@${HOST2}:scripts/
scp ~/bin/run_provision_TC.sh omn@${HOST1}:scripts/

#ssh vroot@${HOST1} /apps/omn/scripts/run_uninstall_TC.sh |tee -a TC_uninstall.log; 
#ssh vroot@${HOST2} /apps/omn/scripts/run_uninstall_TC.sh |tee -a TC_uninstall.log; 

# TODO, how to run these in parallel ?
#ssh vroot@${HOST1} /apps/omn/scripts/run_install_TC.sh |tee -a TC_install.log; 
#ssh vroot@${HOST2} /apps/omn/scripts/run_install_TC.sh |tee -a TC_install.log; 

ssh omn@${HOST1} /apps/omn/scripts/run_solo_start_TC.sh |tee -a TC_solo_start.log; 
ssh omn@${HOST2} /apps/omn/scripts/run_rejoin_TC.sh |tee -a TC_rejoin.log; 
ssh omn@${HOST1} /apps/omn/scripts/run_provision_TC.sh |tee -a TC_provision.log; 


