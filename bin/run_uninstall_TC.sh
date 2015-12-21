#!/bin/bash

[[ $(whoami) != 'root' ]] && { echo "ERROR: must be run as root"; exit -1; }

# UNINSTALL RPMs and clear out stuff (if needed)
# see also notes_bluesky_gandhi, notes_building.txt, notes_garv_vb-27..., ~/notes_gui_crash

#as omn user:
su - omn -c "ps -fu omn"
#mci list; mci stop all; mci list; 
su - omn -c "sci -list; sci -stop; sleep 30; sci -check; sci -quit"
#sudo -c stop samson

DTS=$(date +%Y%m%d_%H%M); 
cd /apps/omn
mkdir -p oldlog
#optionally BACKUP cconf-dir
true && su - omn -c "tar -jcvf oldlog/cconf-dir_${DTS}.tbz cconf-dir"


#### when scripts/rpm install goes wrong it's really awkward. :-P
PIDS=$(pstree -anp |grep -A1 run_uninstall |grep -v grep|sed s/.*,// |grep -v -P "^(--|//|grep)$" |cut -d" " -f 1)
if [[ ! -z $PIDS ]] ; then
   echo "WARNING: old run install script(s) hanging around, killing it/them . . . "
   kill $PIDS
   kill -9 $PIDS
fi

#PIDS=$(ps -elf |grep rpm |grep Nov |awk '{print $4}')
#kill $PIDS
PIDS=$(ps -fu root |grep rpm |grep -v grep |awk '{print $2}')
PPIDS=$(ps -fu root |grep rpm |grep -v grep |awk '{print $3}')
if [[ ! -z $PIDS ]] ; then
   echo ERROR: funny rpm processes hanging around
   ps -fu root |grep rpm |grep -v grep
   echo ERROR: funny rpm processes hanging around
   kill $PIDS
   kill -9 $PIDS
   sleep 1
   PIDS=$(ps -fu root |grep rpm |grep -v grep |awk '{print $2}')
   if [[ ! -z $PIDS ]] ; then
       echo ERROR: funny rpm processes still there.
   else
       echo GOOD: funny rpm processes all gone.
   fi
fi

if [[ ! -z $(ls /var/lib/rpm/__db.* 2>/dev/null) ]] ; then
   echo WARNING: rpm locks hanging around, . . . removing them . . . 
   rm -rf /var/lib/rpm/__db.*
   echo "cd /var/lib/rpm && rpm -v --rebuilddb"
   cd /var/lib/rpm && rpm -v --rebuilddb
   if [[ ! -z $(ls /var/lib/rpm/__db.* 2>/dev/null) ]] ; then
       echo ERROR: rpm locks still there.
   else
       echo GOOD: rpm locks all gone.
   fi
   cd /apps/omn
fi

# as root
echo "UN-INSTALLING OMN rpms"
# rm -rf /var/lib/rpm/__db.000 # remove rpm transaction lock

############## Check is df hanging, rpm -e is hanging because mounts are hanging ? because df is hanging ?
echo "check is df hanging, mounts problems, can cause problem with rpm"
mount
df -h

rpm -e `rpm -qg OMN`
### sometimes rpm -e just hangs . . . when rermoving any package - TOMCAT ? Traffic Control ?
#for p in `rpm -qg OMN`; do echo $p; rpm -e $p; done
#rpm -e --force `rpm -qg OMN`
#rpm: only installation, upgrading, rmsource and rmspec may be forced


#as omn user, optionally backup and clear out stuff
su - omn -c "
false && mv cconf-dir oldlog/cconf-dir_${DTS}
false && mv bin oldlog/bin_${DTS}

rm -rf cassandra cconf-dir certs clog-dir core-dumps dfl-dir etc java snmp tomcat webserver
[[ -e monmemu ]] && rm -rf monmemu.older && mv monmemu{,.older} && mkdir monmemu
rm -rf dfl-dir dfl-dir.old/

rm -rf operations_cdrs pstat-dir  qsr-journal  qsr-storage
rm -rf cstat-dir META-INF com
rm -rf .tomcat-assure

#rm -rf .cassandra .cassandra_partitioner .ccache .cconf_repl
rm -rf .wassail-port .shep-stats .patch*

mkdir dfl-dir
touch dfl-dir/.ACTIVE


### some problem files in /tmp for machines sharing build and running a TC node
# as builder owner i.e. james@...  OR root:
rm -rf /tmp/pooky.cvp /tmp/.cas-batch

ls
ls -al lib bin scripts
# mv lib lib.old
# mv bin bin.old

"
