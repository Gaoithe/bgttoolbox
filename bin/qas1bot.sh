#!/bin/bash

# run me (qas1bot.sh) from anywhere or e.g. s1 smsc1 kudos, e.g. 
# watch -n 60 ~/bin/qas1bot.sh
# see also my friend monitor_job_and_speak.sh and run_monitor_job_and_speak.sh

#TODO: automate more our monitoring of QA and S1 on chatbot
#Run on one S1 - where workflow-trigger runs 24/7 - monitor events db to track all of S1
#we want it to tell us:
# .. limited to in Quorum ?
#"New build v1.18.31 dir exists but not ready yet ..."
#"New build v1.18.31 available but S1 Proxy has not taken it"
#"New build v1.18.31 on S1 test systems passed:x failed:y(n in retry) unknown:z" # optional
#"New build v1.18.31 failed on S1 test system S1 MMSC1 http://192.168.123.136:9080/" # when failed and retry not happening
#"New build v1.18.31 failed on S1 test system S1 MMSC1 http://192.168.123.136:9080/ - 1 CAT test failed: name" # more detail if login to KUDOS ?  RUP fail, cat_setup fail, clubby fail grep out console log or debug.log fails ?
#.. AFTER time ..
#"New build v1.18.31 available but S1 MEP APP, QARUPTRAFFIC have not taken it" # e.g. kudos workflow ghost upgrade

#USERHOST=$1 
#JDIR=$2
#JOB=$3
#shift 
#shift
#shift
#[[ -z $USERHOST || -z $JDIR || -z $JOB ]] && {
#  echo "usage: $0 user@host jenkinsjobsdir jobname"
#  echo " e.g. monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_Staging"
#  exit -1
#} 

function alert {
    level=$1
    shift
    # 1. grep for the message in local alert file
    # 2. send message and log if not already sent
    M="$level: $*"
    if ! grep -q "$M" /tmp/alert_msgs.txt ; then
	echo message not found
	echo "$M" >> /tmp/alert_msgs.txt
	[[ -z $JENKINS_HOME ]] && JENKINS_HOME=.
	if [[ -e ${JENKINS_HOME}/jenkins_QA_chat.py ]] ; then
	    python ${JENKINS_HOME}/jenkins_QA_chat.py "$M"
	else
	    echo "WARNING: cannot send ALERT chatbot message because ${JENKINS_HOME}/jenkins_QA_chat.py is not there"
	fi
    fi
}

function log {
    level=$1
    shift
    # LEVELS: DEBUG INFO WARNING ALERT(send alert) ERROR(?==ALERT)
    echo "$level: $*"
    [[ $level == "ALERT" || $level == "ERROR" ]] && alert $level "$*"
}

S1PILOT=omndocker@192.168.123.23
S1SMSC=omndocker@192.168.123.54
QARUPTRAFFIC=omndocker@192.168.123.115

EVENTSDB=/kudos/KUDOS/TC-6000/events.db
[[ ! -e $EVENTSDB ]] && {
    rsync -azhP $S1PILOT:/docker/tc-image/KUDOS/TC-6000/events.db /tmp/
    EVENTSDB=/tmp/events.db
}

sqlite3 $EVENTSDB 'select * from facts' > /tmp/facts.txt

LINFO1=$(ssh $QARUPTRAFFIC ls -alstr /slingshot/docker_images/traffic-control/LATEST)
LSLASH=$(echo $LINFO1 | sed 's/.*-> //')
VDOT=$(echo $LSLASH |sed 's#/#.#g')
VDASH=$(echo $LSLASH |sed 's#/#-#g')
LDATE=$(echo $LINFO1 | cut -d" " -f6,7,8,9)

GATE=/tmp/GATE1.${VDOT}.CHECKED
[[ ! -e $GATE ]] && {
    ok=true
    log DEBUG "LATEST from /slingshot is LSLASH=$LSLASH VDOT=$VDOT LDATE=$LDATE"

    #LINFO2=$(ssh $QARUPTRAFFIC ls -alstr /slingshot/docker_images/traffic-control/LATEST/misc/)
    LINFO3=$(ssh $QARUPTRAFFIC ls /slingshot/docker_images/traffic-control/LATEST/RPMS/OMN-DOCKER-HOST-TOOLS*)
    [[ -z $LINFO3 ]] && log WARNING "RPMS/OMN-DOCKER-HOST-TOOLS*.rpm not found" && ok=false
    
    LINFO4=$(ssh $QARUPTRAFFIC ls -alstr /slingshot/docker_images/traffic-control/LATEST/IMGS/)
    #echo DEBUG "$LINFO4"
    # omn-traffic-control-v1.18.32-docker.tar.gz.part10
    # omn-traffic-control-v1.18.32-docker.tar.gz.part11
    # omn-kudos-v1.18.32-docker.tar.gz.part02
    # omn-traffic-control-v1.18.32.signature
    # omn-kudos-v1.18.32.signature
    LOOKFOR=omn-traffic-control-${VDOT}-docker.tar.gz.part
    tcimgpartcount=$(echo "$LINFO4" |grep $LOOKFOR |wc -l)
    (($tcimgpartcount==0)) && log ERROR "$LOOKFOR files NOT FOUND" && ok=false
    r=
    (($tcimgpartcount<10)) && r=less
    (($tcimgpartcount>12)) && r=more
    [[ -n $r ]] && log WARNING "$LOOKFOR $tcimgpartcount files FOUND, $r than usual(12)" && ok=false
    LOOKFOR=omn-kudos-${VDOT}-docker.tar.gz.part
    kuimgpartcount=$(echo "$LINFO4" |grep $LOOKFOR |wc -l)
    (($kuimgpartcount==0)) && log ERROR "$LOOKFOR files NOT FOUND" && ok=false
    r=
    (($kuimgpartcount<2)) && r=less
    (($kuimgpartcount>3)) && r=more
    [[ -n $r ]] && log WARNING "$LOOKFOR $kuimgpartcount files FOUND, $r than usual(12)" && ok=false
    [[ "$LINFO4" != *"omn-traffic-control-${VDOT}.signature"* ]] && log ERROR "omn-traffic-control-${VDOT}.signature NOT FOUND" && ok=false
    [[ "$LINFO4" != *"omn-kudos-${VDOT}.signature"* ]] && log ERROR "omn-traffic-control-${VDOT}.signature NOT FOUND" && ok=false

    $ok && touch $GATE && log INFO "LATEST from /slingshot is LSLASH=$LSLASH VDOT=$VDOT LDATE=$LDATE HOST-TOOLS and IMGS/tc and IMGS/kudos look ok."
}

# TODO general events.db versions check
#sort -r /tmp/facts.txt |sed 's/|/ /g' |cut -f 3 -d " " |sort |uniq -c
QUORUMRE="S1-PROXY|TC-Deployment|TCX-Deploy-Test-Proxy|ANTISPAM|Insight-Care|MEPBE2|MEPDB|MMS-HUB|MMSC|MMSC2|QA-MEP-RUP|QA-RUP-SMSHUB|QA-SMSC-ACADIA|QA-SMSHUB-RL8-TRAFFIC|QARUPTRAFFIC|SMS-HUB|SMSC|SMSC-MMSC|SMSC2|SMSC3|TCX-Deploy-Test-S2|CARE|IMX|Insight|MEPAPP|MEPDB|MEPFE|MEPFE2|TCX-Deploy-Test-SMSC-L"
#grep "^$({QUORUMRE})\|" /tmp/facts.txt
#grep -E "^(${QUORUMRE})\|" /tmp/facts.txt |sort |cut -f2- -d'|' |sort -r |uniq -c
QLIST=$(grep -E "^(${QUORUMRE})\|" /tmp/facts.txt |sort)
QSDV=$(echo "$QLIST" |grep download |cut -f3- -d'|' |sort -r |uniq -c)
QSTV=$(echo "$QLIST" |grep tested |cut -f3- -d'|' |sort -r |uniq -c)
QSSV=$(echo "$QLIST" |cut -f3- -d'|' |sort -r |uniq -c)
#NOTONLATEST=$(grep -E "^(${QUORUMRE})\|" /tmp/facts.txt |sort |grep -v $VDASH)
#NOTONLATESTCOUNT=$(echo "$NOTONLATEST" |wc -l)
#[[ $NOTONLATESTCOUNT != 0 ]] &&
QUORUMCOUNTSINFO=$(echo "Quorum Site Version counts download:"$QSDV" tested:"$QSTV " states:"$QSSV)
log INFO "$QUORUMCOUNTSINFO"
#NOTONLATESTCOUNT=$NOTONLATESTCOUNT 

#ssh $S1PILOT ls -alstr /docker/tc-image/KUDOS/TC-6000

#/usr/local/bin/kudos.py --cmd=list_available
#/usr/local/bin/kudos.py --cmd=check_new

ok=true
LEVEL=WARNING
test $(find $GATE -mmin +60) && LEVEL=ALERT
GATE2=/tmp/GATE2.${VDOT}.S1-PROXYandTCX-Deployment.CHECKED

[[ ! -e $GATE2 ]] && {
    # TC-Deployment takes longer than 60mins ...
    QUORUMSITES="
    S1-PROXY
    TCX-Deploy-Test-Proxy
    "
    log DEBUG "GATE2 check"
    for s in $QUORUMSITES; do
	grep ^$s\|tested_v.*$VDASH /tmp/facts.txt || {
	    # warning becomes error if $GATE is much older than current time
	    ok=false
	    log $LEVEL "tested_version for $VDASH not found for site:$s"
	    grep ^$s\| /tmp/facts.txt
	}
    done
    $ok && touch $GATE2 && log INFO "GATE2=$GATE2 passed."
}

ok=true
LEVEL=WARNING
test $(find $GATE2 -mmin +120) && LEVEL=ALERT
GATE3=/tmp/GATE3.${VDOT}.S1-PROXY_downstream.CHECKED

[[ ! -e $GATE3 ]] && {
    # S1-PROXY is upstream ... not sure about TC-Deployment, TCX-Deploy-Test-Proxy
    # take longer: SMSC 4hrs+ SMSC2 SMSC3 MMSC SMS-HUB
    # takes much longer: QA-RUP-SMSHUB QA-SMSC-ACADIA
    QUORUMSITES="
    ANTISPAM
    Insight-Care
    MEPBE2
    MEPDB
    MMS-HUB
    MMSC2
    QA-MEP-RUP
    QA-SMSHUB-RL8-TRAFFIC
    QARUPTRAFFIC
    SMSC-MMSC
    TC-Deployment
    TCX-Deploy-Test-S2"
 
    log DEBUG "GATE3 check"
    for s in $QUORUMSITES; do
	grep ^$s\|tested_v.*$VDASH /tmp/facts.txt || {
	    # warning becomes error if $GATE is much older than current time
	    ok=false
	    log $LEVEL "tested_version for $VDASH not found for site:$s"
	    grep ^$s\| /tmp/facts.txt
	}
    done
    $ok && touch $GATE3 && log INFO "GATE3=$GATE3 passed."
}

# TODO checks by downstream ..
# TCX-Deploy-Test-Proxy
#  TCX-Deploy-Test-S2
#   TCX-Deploy-Test-SMSC-L
# MEPDB
#  MEPBE
#   MEPAPP
#    MEPFE
# MEPBE2
#  MEPFE2
# SMSC
#  IMX
# Insight-Care
#  Insight
#   CARE

ok=true
LEVEL=WARNING
test $(find $GATE3 -mmin +180) && LEVEL=ALERT
GATE4=/tmp/GATE4.${VDOT}.S1-2ndlevel-downstream.CHECKED

[[ ! -e $GATE4 ]] && {

    # S1-PROXY is upstream ... not sure about TC-Deployment, TCX-Deploy-Test-Proxy
    QUORUMSITES="
    SMSC
    SMSC2
    SMSC3
    SMS-HUB
    MMSC
    CARE
    IMX
    Insight
    MEPAPP
    MEPDB
    MEPFE
    MEPFE2
    TCX-Deploy-Test-SMSC-L"
 
    log DEBUG "GATE4 check"
    for s in $QUORUMSITES; do
	grep ^$s\|tested_v.*$VDASH /tmp/facts.txt || {
	    # warning becomes error if $GATE is much older than current time
	    ok=false
	    log $LEVEL "tested_version for $VDASH not found for site:$s"
	    grep ^$s\| /tmp/facts.txt
	}
    done
    $ok && touch $GATE4 && log INFO "GATE4=$GATE4 passed."
}



ok=true
LEVEL=WARNING
test $(find $GATE -mmin +6000) && LEVEL=ALERT
GATE5=/tmp/GATE5.${VDOT}.QAlonger.CHECKED

[[ ! -e $GATE5 ]] && {

    # 7hrs for SMSHUB 8hrs for ACADIA ... 9/10hrs to allow for myeh
    QUORUMSITES="
    QA-RUP-SMSHUB
    QA-SMSC-ACADIA"
 
    log DEBUG "GATE5 check"
    for s in $QUORUMSITES; do
	grep ^$s\|tested_v.*$VDASH /tmp/facts.txt || {
	    # warning becomes error if $GATE is much older than current time
	    ok=false
	    log $LEVEL "tested_version for $VDASH not found for site:$s"
	    grep ^$s\| /tmp/facts.txt
	}
    done
    $ok && touch $GATE5 && log INFO "GATE5=$GATE5 passed."
}


NONQ="
A1BY-MMSC-S2
MS-QA-1
UNIT-APPRTR-S2
UNIT-MMSC-S2
UNIT-SMSC-S2
VV-SMSC-S2
ua-nfv-dev1
TCX-Deploy-Test-S2-2
"


### TODO: next level S1 Published and QA Published Quorum met
### automatic or manual published view
### published to https server and gdrive
### https download successful

# http://192.168.123.133/build_status "Automatic publishing is disabled"
# Candidate, QA Quorum, S1 Quorum, Ready, S1 Published

### look in kudos.py for https server details
#    https_api_url = "https://etph.o17g.com"
#bash-5.1$ watch -n 45 'cat $(ls -tr jobs/qas1chatbot/builds/*/log |tail -1)'
#bash-5.1$ scp omndocker@192.168.123.23:qas1bot.sh ./
