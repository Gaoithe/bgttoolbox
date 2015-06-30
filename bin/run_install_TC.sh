#!/bin/bash

[[ $(whoami) != 'root' ]] && { echo "ERROR: must be run as root"; exit -1; }

# as root user, install rpms
#cd rpms_james

if [[ -z $RPMNDIR ]] ; then
    RPMNDIR=rpms_care
    RPMNDIR=rpms_cobwebs
    [[ "$1" != "" ]] && RPMNDIR=$1
fi

if [[ -z $INSTALL_FROM_SLINGSHOT ]] ; then
    INSTALL_FROM_SLINGSHOT=true
    INSTALL_FROM_SLINGSHOT=false
fi

if [[ -z $INSTALL_LATEST ]] ; then
    INSTALL_LATEST=true
    INSTALL_LATEST=false
fi

if $INSTALL_FROM_SLINGSHOT; then

    if $INSTALL_LATEST; then
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh `/slingshot/MOS-base/LATEST/scripts/deploylist.pl -fc9 /slingshot/deployments/OMN-Traffic-Control/LATEST`
    else 

        if [[ -z $REL ]] ; then
            REL=13-Q1
            REL=13-Q2
            REL=14-Q1
            #REL=14-Q2
            REL=14-Q3
            #REL=15-Q1
        fi

        if [[ -z $PLAT ]] ; then
            PLAT=FC9
        fi

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
        
        echo "####################### INSTALL/APPLY each released & PUBLISHED patch one by one ################################"
        ls $PUB_PAT
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat $(find $PUB_PAT  -name "*.rpm" | sort)
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/q09-Q1-5/PATCHES/FC9 -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/14-Q2/PATCHES/FC9  -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/14-Q1/PATCHES/FC9  -name "*.rpm" | sort`
        #/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat `find /slingshot/PUBLISHED/OMN-Traffic-Control/13-Q3/PATCHES/FC9  -name "*.rpm" | sort`

        echo "####################### you might wish to INSTALL/APPLY locally built or UN-PUBLISHED patches ################################"
        PAT=/slingshot/PATCHES/OMN-Traffic-Control-${REL}
        /slingshot/MOS-base/LATEST/scripts/rpmturbo.sh -oaat $(find $PAT -name "*${PLAT}*.rpm")
        # scp RPMS/OMN-Traffic-Control-15-Q1-pxx-1.FC9.i386.^Cm /scratch/james/RPMS/
        # rpm -qg OMN |grep Traffic
        # rpm -ql -p /slingshot/PATCHES/OMN-Traffic-Control-15-Q1/v1/00/01/RPMS/OMN-Traffic-Control-15-Q1-p02-11.FC9.i386.rpm
        # [root@vb-48]# rpm -ivh /slingshot/PATCHES/OMN-Traffic-Control-15-Q1/v1/00/01/RPMS/OMN-Traffic-Control-15-Q1-p02-11.FC9.i386.rpm



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

# disable sca process - which always dumps cores
#[root@vb-48]# ls -alstr etc/samson.d/procs.default 
#4 -r--r--r-- 1 omn omn 3851 2015-03-30 22:38 etc/samson.d/procs.default
#[root@vb-48]# grep sca etc/samson.d/procs.default 
#    R      090     .         bin/sca
chmod o+w /apps/omn/etc/samson.d/procs.default
perl -pi -e 's/^(.*bin\/sca)/#$1/' /apps/omn/etc/samson.d/procs.default

# workaround: 
#just removing the cconf-dir/isr-*/drill_ipdip_services-*/default-* works
su - omn -c "mv cconf-dir/isr-*/drill_ipdip_services-*/default-* cconf_REMOVED_DRILL_IPDIP_THINGY"

# workaround: java classpath log4j



# as root user:
echo $CAS_JMX_PORT
grep CAS_JMX_PORT ~/.bash_profile
#edit .bashrc and set cassandra port s/9999/9128/ (for vb28) 

# as root user:
# start samson
HOST=hostname
HOST=$(cat /VHOST)
echo SAMSON_HOST=$HOST > /apps/omn/etc/samson.hostname


############################################################
# link to genlicence 
# lib/libtbx-v2-79-27.so TBXVER=v2-79-27 TBXVDIR=v2/79/27
cd /apps/omn
TBXVDIR=$(ls lib/libtbx-*.so|sed "s/[^-]*\-//;s/\..*//;s/-/\//g")
#echo TBXVER=$TBXVER
TBXSDIR=/slingshot/tbx/$TBXVDIR/lnk/linux.fc9
echo TBXVDIR=$TBXVDIR TBXSDIR=$TBXSDIR
ln -sf $TBXSDIR libtbx
HOSTID=$(/apps/omn/bin/hostid)

LICENCE=$(./libtbx/genlicence "$(head -1 cluster.info |sed 's/[^"]*"//;s/"//g')" $HOSTID 29999|cut -d"'" -f2)
grep $LICENCE cluster.info
if [[ $? != 0 ]] ; then 
   DTS=$(date +%Y%m%d_%H%M); cp -p cluster{,_${DTS}}.info
   OLDLICENCE=$(grep -P "${HOST}\s+\d+\s+omn" cluster.info|sed "s/.* //")
   echo new LICENCE=$LICENCE OLDLICENCE=$OLDLICENCE
   perl -pi -e s/$OLDLICENCE/$LICENCE/ cluster.info   
   FEATSIG=$(grep ^featsig: cluster.info)
   NEWFEATSIG=$(./libtbx/genfeaturelicence cluster.info $HOSTID)
   # TODO: can we do this? continually append feature signatures? more than the nodes we have?
   perl -pi -e "s/^featsig: /featsig: $NEWFEATSIG/" cluster.info   
fi

############################################################


#[root@vb-28]# ulimit -c unlimited; 
cat /apps/omn/etc/samson.hostname
cd /apps/omn

mkdir -p oldlog
DTS=$(date +%Y%m%d_%H%M); 
mv samson.stderr oldlog/samson.stderr_${DTS} 
mv samson.stdout oldlog/samson.stdout_${DTS} 

nohup ./scripts/samson.sh  &
cat samson.stderr

# after this sci in run_solo_start_TC.sh and run_rejoin_TC.sh
# as omn user:   START hygiene processes  solo_start on first node and rejoin on others
