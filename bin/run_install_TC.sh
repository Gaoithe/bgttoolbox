#!/bin/bash

[[ $(whoami) != 'root' ]] && { echo "ERROR: must be run as root"; exit -1; }

# as root user, install rpms
#cd rpms_james

if [[ -z $RPMNDIR ]] ; then
    RPMNDIR=rpms_care
    RPMNDIR=rpms_cobwebs
    [[ "$1" != "" ]] && RPMNDIR=$1
fi

INSTALL_FROM_SLINGSHOT=true
INSTALL_LATEST=false
INSTALL_LATEST=true
if $INSTALL_FROM_SLINGSHOT; then

    if $INSTALL_LATEST; then
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh `/slingshot/MOS-base/LATEST/scripts/deploylist.pl -fc9 /slingshot/deployments/OMN-Traffic-Control/LATEST`
    else 
        REL=13-Q1
        REL=13-Q2
        REL=14-Q1
        #REL=14-Q2
        #REL=15-Q1
        PLAT=FC9
        PUB=/slingshot/PUBLISHED/OMN-Traffic-Control/$REL
        PUB_BASE=$PUB/BASE/$PLAT
        PUB_PAT=$PUB/PATCHES/$PLAT
        cat $PUB/info
        #DESC		= Traffic Control Router Q1 2014
        #BASE		= deployments/OMN-Traffic-Control/v1/33/18
        #PATCHES		= PATCHES/OMN-Traffic-Control-14-Q1
        #BASE=deployments/OMN-Traffic-Control/v1/33/18
        BASE=$(grep BASE $PUB/info|awk '{print $3}')
        echo BASE=$BASE
        
        echo "####################### INSTALL BASE set of rpms ################################"
        ls /slingshot/$BASE
        BASE_RPMS=$(/slingshot/MOS-base/LATEST/scripts/deploylist.pl -fc9 /slingshot/$BASE)
        echo BASE_RPMS=$BASE_RPMS
        # TODO: --force is sometimes necessary
        #file /apps/omn/scripts conflicts between attempted installs of OMN-MOS-HAMMER-X-v1.10.02-1.FC9.i386 and OMN-MOS-REAFER-v1.12.08-1.FC9.i386
        #file /apps/omn/scripts conflicts between attempted installs of OMN-MOS-HILT-v1.04.76-1.FC9.i386 and OMN-MOS-HAMMER-X-v1.10.02-1.FC9.i386
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh $BASE_RPMS
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh --force $BASE_RPMS
        
        #### these are included in BASE ####
        #ls $PUB_BASE
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat $(find $PUB_BASE -name "*.rpm")
        
        echo "####################### INSTALL/APPLY each released patch one by one ################################"
        ls $PUB_PAT
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat $(find $PUB_PAT  -name "*.rpm" | sort)
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/q09-Q1-5/PATCHES/FC9 -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/14-Q2/PATCHES/FC9  -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/14-Q1/PATCHES/FC9  -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/13-Q3/PATCHES/FC9  -name "*.rpm" | sort`
    fi

else
    cd /scratch/james/RPMS/$RPMNDIR/
    #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist2_local.txt
    #grep TOMCAT deploylist_local.txt
    # cobwebs is in corrib_router rpm
    # e.g. rpm -qlp OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm  |grep cobweb
    #grep -i corrib.router deploylist_local.txt

    /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_local.txt
    #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_SLINGSHOT.txt
fi

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
