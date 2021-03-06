#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

[[ $(whoami) != 'omn' ]] && { echo "ERROR: must be run as omn"; exit -1; }

# as omn user:   START hygiene processes  solo_start on first node and rejoin on others
## USER needs to answer "Y" on solo_start
#sci -solo_start
rm -rf cconf-dir.old dfl-dir.old; 
sci -rejoin


## PROBLEM on rejoin vb-48 is picking up JMX_PORT=7128 in cassandra-evn.sh script ???
# after/during sci -start:
#grep CAS_JMX_PORT /root/.bash_profile
#grep JMX_PORT cassandra/dsc-cassandra-1.2.10/conf/cassandra-env.sh
MY_JMX_PORT=$(grep CAS_JMX_PORT /root/.bash_profile |sed s/.*=//)
#CASENVFILE=cassandra/dsc-cassandra-1.2.10/conf/cassandra-env.sh
#CASENVFILE=cassandra/dsc-cassandra-2.0.14/conf/cassandra-env.sh # april 2015 change java 1.6 -> 1.7 cassandra 1.2.10 -> 2.0.14
CASENVFILE=$(find cassandra -name cassandra-env.sh |tail -1)
CA_JMX_PORT=$(grep JMX_PORT= $CASENVFILE |sed 's/.*=//;s/"//g')
echo MY_JMX_PORT=$MY_JMX_PORT CASENVFILE=$CASENVFILE CA_JMX_PORT=$CA_JMX_PORT
[[ -n $MY_JMX_PORT && "$MY_JMX_PORT" != "$CA_JMX_PORT" ]] && perl -pi -e s/$CA_JMX_PORT/$MY_JMX_PORT/ $CASENVFILE
grep JMX_PORT $CASENVFILE
CA_JMX_PORT=$(grep JMX_PORT= $CASENVFILE |sed 's/.*=//;s/"//g')
[[ "$MY_JMX_PORT" != "$CA_JMX_PORT" ]] && echo "MAUGH frurggggh ERROR: cassandra port WRONG in $CASENVFILE file, it is $CA_JMX_PORT, it should be $MY_JMX_PORT"
echo MY_JMX_PORT=$MY_JMX_PORT CASENVFILE=$CASENVFILE CA_JMX_PORT=$CA_JMX_PORT

ls -alstr samson.stderr 
./bin/bci -listals
tail samson.stderr
#tail -f samson.stdout
tail samson.stdout

LASTONE=
while [[ "$LASTONE" == "" ]] ; do
  LINFO="$INFO"
  INFO=$(tail -1 samson.stdout)
  [[ "$INFO" != "$LINFO" ]] && echo $INFO
  LASTONE=$(tail samson.stdout |grep cumulus_mediator.sh)
  sleep 1
done
# Are processes really started?
date
sci -list

date
echo "RUN $THISNODE sci really started"


# after is started:
#./scripts/clogwatch.pl 0
./bin/clex -ch 0 -s -2m

sbug_session -cmd enable -path corrib_router/cobwebs -level 3 -verbose

# ripley error => touch dfl-dir/.ACTIVE (see above, should already be done)

#touch dfl-dir/.ACTIVE




