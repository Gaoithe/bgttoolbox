#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

[[ $(whoami) != 'omn' ]] && { echo "ERROR: must be run as omn."; exit -1; }

SCISTATE=$(./bin/sci -check)
[[ "$SCISTATE" != "Started" ]] && { echo "ERROR: SCISTATE:$SCISTATE sci state must be Started, need manual intervention."; exit -1; }

./bin/bci -listals
CLUSTERSPLIT=$(./bin/bci -listals |grep "has disappeared from the cluster")
[[ "$CLUSTERSPLIT" == "" ]] && { echo "ERROR: No cluster split alarm, need manual intervention."; exit -1; }
# 19/12/2015-19:40:48.604 lsvprdmmsc02/delilah-2: Node lsvprdmmsc01 has disappeared from the cluster

source /apps/omn/etc/samson.hostname; echo $SAMSON_HOST; 
THISNODE=$SAMSON_HOST;
OTHERNODES=$(mci list |grep -v $THISNODE |awk '{print $2}'|sort |uniq)
echo THISNODE=$THISNODE OTHERNODES=$OTHERNODES

date
#mci list
# if the other node(s) is(are) not all in "UNKNOWN" state then don't do anything
MCICHECK1=$(mci list |grep $THISNODE |grep -v Running)
if [[ -n "$MCICHECK1" ]] ; then
  echo MCI processes on THIS node not all in Running state, need manual intervention. MCICHECK1=$MCICHECK1
  exit -1
fi
MCICHECK2=$(mci list |grep -v $THISNODE |grep -v UNKNOWN)
if [[ -n "$MCICHECK2" ]] ; then
  echo MCI processes on other nodes not all in UNKNOWN state, need manual intervention. MCICHECK2=$MCICHECK2
  exit -1
fi

#ps -fu omn
#mci list; mci stop all; mci list; 
#sci -list; sci -stop; sleep 30; sci -check; sci -quit

#################################################################
date
echo "RUN $THISNODE Doing stop"
sci -stop
OCOUNT=0
LASTONE=
while [[ "$LASTONE" == "" ]] ; do
  LASTONE=$(tail samson.stdout |grep sysstat.sh)
  echo -n .
  sleep 1

  OLASTONE=$(tail samson.stdout |grep personality.sh)
  if [[ "$OLASTONE" != "" ]] ; then
    ((OCOUNT++))
    if (( $OCOUNT > 5 )) ; then 
      echo "ERROR: PROBLEM: sci -stop stuck and didn't stop something . . . sysstat.sh usually. KILL KILL KILL"
      ps -fu omn
      PSINFO=$(ps -fu omn |grep sysstat.sh |grep -v grep)
      echo $PSINFO
      PID=$(echo $PSINFO |awk '{print $2}')
      #omn      17849 24961  0 15:39 ?        00:00:00 /bin/sh scripts/sysstat.sh -wdogfd 3 -tbx_rejoin -procname sysstat.sh-8 -cvp_port 29999 -tbx_hostname vb-28
      kill $PID
      kill -9 $PID
    fi
  fi
done


# as omn user:   START hygiene processes  solo_start on first node and rejoin on others
## USER needs to answer "Y" on solo_start
#sci -solo_start
#################################################################
date
echo "RUN $THISNODE Doing rejoin"
rm -rf cconf-dir.old dfl-dir.old; 
sci -rejoin
sci -check
sci -list

#################### vbox JMX_PORT fiddling needs to be done here ########################
### PROBLEM on rejoin vb-48 is picking up JMX_PORT=7128 in cassandra-evn.sh script ???
## after/during sci -start:
##grep CAS_JMX_PORT /root/.bash_profile
##grep JMX_PORT cassandra/dsc-cassandra-1.2.10/conf/cassandra-env.sh
#MY_JMX_PORT=$(grep CAS_JMX_PORT /root/.bash_profile |sed s/.*=//)
##CASENVFILE=cassandra/dsc-cassandra-1.2.10/conf/cassandra-env.sh
##CASENVFILE=cassandra/dsc-cassandra-2.0.14/conf/cassandra-env.sh # april 2015 change java 1.6 -> 1.7 cassandra 1.2.10 -> 2.0.14
#CASENVFILE=$(find cassandra -name cassandra-env.sh |tail -1)
#CA_JMX_PORT=$(grep JMX_PORT= $CASENVFILE |sed 's/.*=//;s/"//g')
#echo MY_JMX_PORT=$MY_JMX_PORT CASENVFILE=$CASENVFILE CA_JMX_PORT=$CA_JMX_PORT
#[[ -n $MY_JMX_PORT && "$MY_JMX_PORT" != "$CA_JMX_PORT" ]] && perl -pi -e s/$CA_JMX_PORT/$MY_JMX_PORT/ $CASENVFILE
#grep JMX_PORT $CASENVFILE
#CA_JMX_PORT=$(grep JMX_PORT= $CASENVFILE |sed 's/.*=//;s/"//g')
#[[ "$MY_JMX_PORT" != "$CA_JMX_PORT" ]] && echo "MAUGH frurggggh ERROR: cassandra port WRONG in $CASENVFILE file, it is $CA_JMX_PORT, it should be $MY_JMX_PORT"
#echo MY_JMX_PORT=$MY_JMX_PORT CASENVFILE=$CASENVFILE CA_JMX_PORT=$CA_JMX_PORT

ls -alstr samson.stderr 
tail samson.stderr
#tail -f samson.stdout
tail samson.stdout

LASTONE=
while [[ "$LASTONE" == "" ]] ; do
  LINFO="$INFO"
  INFO=$(tail -1 samson.stdout)
  [[ "$INFO" != "$LINFO" ]] && echo $INFO
  LASTONE=$(tail samson.stdout |grep cumulus_mediator.sh)
  echo -n .
  sleep 1
done
# Are processes really started?
date
sci -list

date
echo "RUN $THISNODE sci really started"

./bin/bci -listals

# after is started:
#./scripts/clogwatch.pl 0

# ripley error => touch dfl-dir/.ACTIVE (see above, should already be done)
#touch dfl-dir/.ACTIVE




