

# UNINSTALL RPMs and clear out stuff (if needed)
# see also notes_bluesky_gandhi, notes_building.txt, notes_garv_vb-27..., ~/notes_gui_crash

#as omn user:
ps -fu omn
#mci list; mci stop all; mci list; 
sci -list; sci -stop; sleep 30; sci -check; sci -quit
#sudo -c stop samson

DTS=$(date +%Y%m%d_%H%M); 

#optionally BACKUP cconf-dir
true && tar -jcvf cconf-dir_${DTS}.tbz cconf-dir




#rpm -qg OMN
# as root
rpm -e `rpm -qg OMN`




#as omn user, optionally backup and clear out stuff
false && mv cconf-dir cconf-dir_${DTS}
false && mv bin bin_${DTS}

rm -rf cassandra cconf-dir certs clog-dir core-dumps dfl-dir etc java snmp tomcat webserver
mkdir dfl-dir
touch dfl-dir/.ACTIVE

rm -rf operations_cdrs pstat-dir  qsr-journal  qsr-storage


ls



# as root user, install rpms
#cd rpms_james

if [[ -z $RPMNDIR ]] ; then
    RPMNDIR=rpms_care
    RPMNDIR=rpms_cobwebs
    [[ "$1" != "" ]] && RPMNDIR=$1
fi

cd /scratch/james/RPMS/$RPMNDIR/
#/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist2_local.txt
grep TOMCAT deploylist_local.txt
# cobwebs is in corrib_router rpm
# e.g. rpm -qlp OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686.rpm  |grep cobweb
grep -i corrib.router deploylist_local.txt
/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_local.txt
#/slingshot/MOS-base/LATEST/scripts/rpmturbo.sh deploylist_SLINGSHOT.txt

# as omn user:
# take backup of clean cconf dir
tar -jcvf cconf-dir_CLEAN_001.tbz  cconf-dir

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
./scripts/samson.sh 



# as omn user:   START hygiene processes  solo_start on first node and rejoin on others
sci -solo_start
# or rm -rf cconf-dir.old dfl-dir.old; sci -rejoin
## PROBLEM on rejoin vb-48 is picking up JMX_PORT=7128 in cassandra-evn.sh script ???

# after/during sci -start:
grep JMX_PORT cassandra/dsc-cassandra-1.2.10/conf/cassandra-env.sh
tail samson.stderr
tail -f samson.stdout

# after is started:
./scripts/clogwatch.pl 0

# ripley error => touch dfl-dir/.ACTIVE (see above, should already be done)

#touch dfl-dir/.ACTIVE



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
/scratch/garvan/DDP/ddp.pl -force -tld /slingshot/deployments/OMN-Traffic-Control/LATEST $DDPFILE
#if you log on to vb-27 you should see lots of useless rubbish in the command history


# as omn user, just on one node:
# create omn gui user
/slingshot/wing/server/LATEST/scripts/create_user_all_perms.sh --user omn --group omn --passwd omn

mci start all

(if needed later stop samson, restore clean cconf dir, restart samson, run ddp again, mci start all, . . . )


#### cobwebs binary is missing ???? TODO: fix
cp -p cobwebs bin/
