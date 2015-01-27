#!/bin/bash

echo
echo ================================================================
echo RUN TEST START
date

#set -x


source /apps/omn/etc/samson.hostname; echo $SAMSON_HOST; 
THISNODE=$SAMSON_HOST;
OTHERNODES=$(mci list |grep -v $THISNODE |awk '{print $2}'|sort |uniq)
echo THISNODE=$THISNODE OTHERNODES=$OTHERNODES


date
mci list
# if the other node is stopped or rejoining - then don't do anything
MCICHECK=Flubbly
while [[ "$MCICHECK" != "" ]] ; do
  MCICHECK=$(mci list |grep -v $THISNODE |grep -v Running)
  sleep 1
done

date
CHECK=
while [[ "$CHECK" != "Started" ]] ; do
  CHECK=$(sci -check)
  sleep 1
done

date

sci -list

echo "RUN $THISNODE Doing stop"
sci -stop

OCOUNT=0
LASTONE=
while [[ "$LASTONE" == "" ]] ; do
  LASTONE=$(tail samson.stdout |grep sysstat.sh)
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
#21-Nov-14 17:30:55.757               sysstat.sh: exit status 0

date
echo "RUN $THISNODE Doing rejoin"
rm -rf cconf-dir.old  dfl-dir.old
sci -rejoin

sci -check
sci -list
tail samson.stdout

LASTONE=
while [[ "$LASTONE" == "" ]] ; do
  tail -1 samson.stdout
  LASTONE=$(tail samson.stdout |grep cumulus_mediator.sh)
  sleep 1
done
# Are processes really started?
date
sci -list

date
echo "RUN $THISNODE sci really started"

# If wassail_port is 8085 in this file then we have a problem:
ls -al tomcat/conf/omn.properties 
cat tomcat/conf/omn.properties 

###
# turn on some sbug
bin/sbug_session -cmd enable -level 3 -path wassail
bin/sbug_session -cmd enable -level 3 -path libnice

####
# HIT GUI and check can get login // wget or curl
GUI=$(wget http://$THISNODE:8888/Wing/#rootroot.monitor.omn_mntr_alarms 2>&1 |grep "Saving to")
echo GUI=$GUI
LOGINFILE=$(ls -tr Login.jsp* |tail -1)
grep -E "<title|<form" $LOGINFILE
clex -ch 0 -s 1m >1.ch0
clex -ch 1 -s 1m >1.ch1

wget --user-agent=Mozilla/5.0 --save-cookies cookies.txt  --keep-session-cookies --post-data 'j_username=omn&j_password=omn&submit' --no-check-certificate http://$THISNODE:8888/Wing/j_spring_security_check
WINGFILE=$(ls -tr Wing.jsp* |tail -1)
grep -E "<title|MainWind" $WINGFILE
clex -ch 0 -s 1m >2.ch0
clex -ch 1 -s 1m >2.ch1

wget --user-agent=Mozilla/5.0 --load-cookies cookies.txt http://$THISNODE:8888/Wing/Wing.jsp#rootroot.monitor.omn_mntr_alarms
WINGFILE=$(ls -tr Wing.jsp* |tail -1)
grep -E "<title|MainWind" $WINGFILE
clex -ch 0 -s 1m >3.ch0
clex -ch 1 -s 1m >3.ch1

# LIST alarms
bci -listals
bci -listsev1s
# LIST Atlas services (wassail/libnice/... ?)
bin/aci |grep -E "WASS|NICE"
bin/aci

####
# grep webserver logs 
tail  webserver/httpd/logs/error_log 
tail tomcat/logs/localhost.*.log
tail tomcat/logs/wing.log 
grep -i exception tomcat/logs/*.log 

#WOAH=$(grep -i exception tomcat/logs/*.log)
WOAH=$(grep exception tomcat/logs/*)
if [[ "$WOAH" != "" ]] ; then
  echo WOAH. we got an exception. WOAH=$WOAH
  echo RUN $THISNODE test STOPPED
  while true; do
    echo WOAH. we got an exception.
    echo RUN $THISNODE test STOPPED
    sleep 360
  done
fi
