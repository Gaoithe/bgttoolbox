#!/bin/bash

[[ $(whoami) != 'root' ]] && { echo "ERROR: must be run as root"; exit -1; }

# as root user, install rpms
#cd rpms_james

if [[ -z $RPMNDIR ]] ; then
    RPMNDIR=rpms_care
    RPMNDIR=rpms_cobwebs
    [[ "$1" != "" ]] && RPMNDIR=$1
fi

cd /scratch/james/RPMS/$RPMNDIR/
#/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist2_local.txt
#grep TOMCAT deploylist_local.txt
# cobwebs is in corrib_router rpm
# e.g. rpm -qlp OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm  |grep cobweb
#grep -i corrib.router deploylist_local.txt

/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_local.txt
#/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_SLINGSHOT.txt

# as omn user:
# take backup of clean cconf dir
su - omn -c "tar -jcvf cconf-dir_CLEAN_001.tbz  cconf-dir"

# as root user:
echo $CAS_JMX_PORT
grep CAS_JMX_PORT ~/.bash_profile
#edit .bashrc and set cassandra port s/9999/9128/ (for vb28) 

# as root user:
# start samson
HOST=$(cat /VHOST)
echo SAMSON_HOST=$HOST > /apps/omn/etc/samson.hostname


#[root@vb-28]# ulimit -c unlimited; 
cat /apps/omn/etc/samson.hostname
cd /apps/omn

mkdir -p oldlog
DTS=$(date +%Y%m%d_%H%M); 
mv samson.stderr oldlog/samson.stderr_${DTS} 
mv samson.stdout oldlog/samson.stdout_${DTS} 

nohup ./scripts/samson.sh  &


# after this sci in run_solo_start_TC.sh and run_rejoin_TC.sh
# as omn user:   START hygiene processes  solo_start on first node and rejoin on others
