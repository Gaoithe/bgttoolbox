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
#optionally BACKUP cconf-dir
true && su - omn -c "tar -jcvf cconf-dir_${DTS}.tbz cconf-dir"

# as root
echo "UN-INSTALLING OMN rpms"
rpm -e `rpm -qg OMN`

#as omn user, optionally backup and clear out stuff
su - omn -c "
false && mv cconf-dir cconf-dir_${DTS}
false && mv bin bin_${DTS}

rm -rf cassandra cconf-dir certs clog-dir core-dumps dfl-dir etc java snmp tomcat webserver
[[ -e monmemu ]] && rm -rf monmemu.older && mv monmemu{,.older} && mkdir monmemu

mkdir dfl-dir
touch dfl-dir/.ACTIVE

rm -rf operations_cdrs pstat-dir  qsr-journal  qsr-storage

ls"
