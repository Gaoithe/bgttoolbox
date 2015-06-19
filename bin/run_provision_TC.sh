#!/bin/bash

[[ $(whoami) != 'omn' ]] && { echo "ERROR: must be run as omn"; exit -1; }

#######
# once samson running all nodes . . . 

## fiddle with traffic_control_provision.pl   -  just on one node  -  NOT NEEDED after cobwebs release 5/1/2015
#grep cobwebs scripts/traffic_control_provision.pl
#cp -p scripts/traffic_control_provision{,.orig}.pl
#diff -u {,scripts/}traffic_control_provision.pl
#cp -fp {,scripts/}traffic_control_provision.pl

#run ddp script - calls traffic control provision and calls perl scripts - ext to provision different items
#  /scratch/garvan/DDP/ddp.pl /scratch/garvan/DDP/tc.james.ddp
DDPFILE=~/bin/tc.james_garson_and_songa.ddp
DDPFILE=~/bin/tc.james.ddp
DDPFILE=/scratch/garvan/DDP/tc.james.ddp
#DDPFILE=/scratch/james/DDP/tc.james.ddp
/scratch/garvan/DDP/ddp.pl -force -tld /slingshot/deployments/OMN-Traffic-Control/LATEST $DDPFILE
DDPFILE_COBWEBS=/scratch/james/DDP/tc.james.cob.ddp
#/scratch/garvan/DDP/ddp.pl -force -tld /scratch/james/work/TCBBUILD/deployments/OMN-Traffic-Control $DDPFILE_COBWEBS
#/scratch/garvan/DDP/ddp.pl -force -tld /home/james/work/TCHOD3/deployments/OMN-Traffic-Control  $DDPFILE_COBWEBS
#/scratch/garvan/DDP/ddp.pl -force -tld /homes/james/work/TCHOD3/deployments/OMN-Traffic-Control $DDPFILE_COBWEBS
#/scratch/james/DDP/ddp.pl -force -tld  /slingshot/deployments/OMN-Traffic-Control/LATEST -xclude cobwebs  -dir /scratch/james/DDP/cobwebs  $DDPFILE_COBWEBS 2>&1 |tee -a ddp.log
/scratch/james/DDP/ddp.pl -force -dir /scratch/james/DDP/cobwebs $DDPFILE_COBWEBS 2>&1 |tee -a ddp.log

#if you log on to vb-27 you should see lots of useless rubbish in the command history


# Things like local dirs should be created by deptron . . . but sometimes are not . . . 
# deptron/OMN-Traffic-Control/tron_deployment_prov_make_ccd.py:
#  log_directory = "/data/FINGERPRINTING", 
mkdir -p /data/BMS-Reports /data/BMS-MSG
ls -al /data/BMS-Reports /data/BMS-MSG


# as omn user, just on one node:
echo "creating omn gui user"
/slingshot/wing/server/LATEST/scripts/create_user_all_perms.sh --user omn --group omn --passwd omn

echo "running mci start all"
mci start all

mci list

# do SBUG again here . . . to try and get it all turned on
#sleep 10 && sbug_session -cmd enable -path corrib_router/cobwebs -level 3 -verbose
#sleep 10 && sbug_session -cmd enable -path hammer-x/drill/ipdip/server -level 3 -verbose
sleep 10 && sbug_session -cmd enable -path hammer-x/drill/custard/server -level 3 -verbose

#(if needed later stop samson, restore clean cconf dir, restart samson, run ddp again, mci start all, . . . )

#### cobwebs binary is missing ???? TODO: fix
#cp -p cobwebs bin/
