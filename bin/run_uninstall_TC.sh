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

# as root
echo "UN-INSTALLING OMN rpms"
# rm -rf /var/lib/rpm/__db.000 # remove rpm transaction lock
rpm -e `rpm -qg OMN`

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
