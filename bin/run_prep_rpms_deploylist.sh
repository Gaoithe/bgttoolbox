#!/bin/bash 

# in build area prepare deploylist.txt and copy rpms to 

# see also notes_bluesky_gandhi, notes_building.txt, notes_garv_vb-27..., ~/notes_gui_crash

TCBASE=.
TCBASE=~/work/TCHOD3
TCBASE=/home/james/work/TCHOD3
TCBASE=/home/james/work/TCHOD7

if [[ -z $RPMNDIR ]] ; then
    RPMNDIR=rpms_HOD_Nov21
    RPMNDIR=rpms_care
    RPMNDIR=rpms_cobwebs
    [[ "$1" != "" ]] && RPMNDIR=$1
fi

mkdir -p /scratch/james/RPMS/$RPMNDIR

cd $TCBASE

DTS=$(date +%d%m%Y_%H%M)
mv deploylist2{,_${DTS}}.txt
if [[ ! -e deploylist2.txt ]]; then
    #perl $TCBASE/MOS-base/scripts/deploylist.pl -fc9 $TCBASE/deployments/OMN-Traffic-Control >deploylist.txt
    #FILES=$(cat deploylist.txt)
    perl $TCBASE/MOS-base/scripts/deploylist.pl -fc9 $TCBASE/deployments/OMN-Traffic-Control >deploylist2.txt
    #miaow
    #ls /slingshot/TOMCAT/v*/*/*/RPMS/OMN-TOMCAT-v1.02.43-1.FC9.i386.rpm >>deploylist2.txt   #:8090
    #ls /slingshot/TOMCAT/v*/*/*/RPMS/OMN-TOMCAT-v1.02.48-1.FC9.i386.rpm >>deploylist2.txt   #:8888 I think.
    ls /slingshot/TOMCAT/LATEST/RPMS/*FC9*.rpm >>deploylist2.txt

    diff -u deploylist{,2}.txt
    FILES=$(cat deploylist2.txt)
fi

mv /scratch/james/RPMS/$RPMNDIR/deploylist_local{,_${DTS}}.txt
if [[ ! -e /scratch/james/RPMS/$RPMNDIR/deploylist_local.txt ]]; then
    #rm deploylist_local.txt
    #for f in $FILES; do echo $(basename $f >>deploylist_local.txt); done
    rm -f deploylist2_local.txt
    for f in $FILES; do echo $(basename $f >>deploylist2_local.txt); done
    scp deploylist2_local.txt /scratch/james/RPMS/$RPMNDIR/
    scp deploylist2_local.txt /scratch/james/RPMS/$RPMNDIR/deploylist_local.txt
    scp deploylist2.txt /scratch/james/RPMS/$RPMNDIR/
fi

FILES=$(cat deploylist2.txt)

for f in $FILES; do rsync -avz $f /scratch/james/RPMS/$RPMNDIR/; done
#for f in $FILES; do cp -p $f /scratch/james/RPMS/$RPMNDIR/; done
#[james@nebraska TCHOD3]$ for f in $FILES; do cp -p $f /scratch/james/RPMS/$RPMNDIR/; done
#cp: cannot create regular file ‘/scratch/james/RPMS/rpms_cobwebs/OMN-MOS-WEB-v1.13.01-1.FC9.i386.rpm’: Permission denied
#cp: cannot create regular file ‘/scratch/james/RPMS/rpms_cobwebs/OMN-JBOSS-v1.01.11-1.FC9.i386.rpm’: Permission denied
#cp: cannot create regular file ‘/scratch/james/RPMS/rpms_cobwebs/OMN-OpenLDAP-v1.05.06-1.FC9.i386.rpm’: Permission denied
#[james@nebraska TCHOD3]$ ls -alstr /scratch/james/RPMS/rpms_cobwebs/OMN-MOS-WEB-v1.13.01-1.FC9.i386.rpm /scratch/james/RPMS/rpms_cobwebs/OMN-JBOSS-v1.01.11-1.FC9.i386.rpm /scr#atch/james/RPMS/rpms_cobwebs/OMN-OpenLDAP-v1.05.06-1.FC9.i386.rpm
# 21096 -r--r--r-- 1 james users  21552140 Apr 29  2011 /scratch/james/RPMS/rpms_cobwebs/OMN-MOS-WEB-v1.13.01-1.FC9.i386.rpm
#  3548 -r--r--r-- 1 james users   3624079 Aug 27  2013 /scratch/james/RPMS/rpms_cobwebs/OMN-OpenLDAP-v1.05.06-1.FC9.i386.rpm
#113664 -r--r--r-- 1 james users 116155021 Oct 20 13:04 /scratch/james/RPMS/rpms_cobwebs/OMN-JBOSS-v1.01.11-1.FC9.i386.rpm
#[james@nebraska TCHOD3]$ chmod 666 /scratch/james/RPMS/rpms_cobwebs/OMN-MOS-WEB-v1.13.01-1.FC9.i386.rpm /scratch/james/RPMS/rpms_cobwebs/OMN-JBOSS-v1.01.11-1.FC9.i386.rpm /scratch/james/RPMS/rpms_cobwebs/OMN-OpenLDAP-v1.05.06-1.FC9.i386.rpm
#[james@nebraska TCHOD3]$ for f in $(grep -E "OMN-MOS-WEB-|OMN-OpenLDAP-|OMN-JBOSS-" deploylist2.txt ); do cp -p $f /scratch/james/RPMS/$RPMNDIR/; done


false && {
FILES="$FILES /slingshot/TOMCAT/v1/02/38/RPMS/OMN-TOMCAT-v1.02.38-1.FC9.i386.rpm /slingshot/TOMCAT/v*/*/*/RPMS/OMN-TOMCAT-v1.02.43-1.FC9.i386.rpm"
for f in $FILES; do bn=$(basename $f); scf=/scratch/james/RPMS/$RPMNDIR/$bn; ls -alstr $f $scf; diff -u $f $scf; done
}

#75936 -rw-r--r-- 1 james users 77595992 Dec  3 13:34 /scratch/james/RPMS/rpms_cobwebs/OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm
#75780 -rw-r--r-- 1 james users 77595476 Dec  4 15:03 /home/james/work/TCHOD3/corrib_router/META/FAKE_RELEASE_AREA/RPMS/OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm
#Binary files /home/james/work/TCHOD3/corrib_router/META/FAKE_RELEASE_AREA/RPMS/OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm and /scratch/james/RPMS/rpms_cobwebs/OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm differ
#[root@vb-48]# rpm -ivh --force /scratch/james/RPMS/rpms_cobwebs/OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm

diff -u /scratch/james/RPMS/$RPMNDIR/deploylist_local{,_${DTS}}.txt
