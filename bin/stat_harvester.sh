#! /bin/bash

# A script to convert short-term stats into plaintext format and those those in windstat user's directory for QoS team to download

DEST_DIR=/logs/stats
LOG_FILE=$DEST_DIR/stat_harvester.log
DTS=$(date +%Y%m%d%H -d "1 hour ago")
PREFIX=$DEST_DIR/$DTS
OLDEST_DAYS=100

# save stdout and stderr to file descriptors 3 and 4, then redirect them to log file
exec 3>&1 4>&2 >>${LOG_FILE} 2>&1

log(){
    echo "$(date +%d/%m/%Y-%H:%M:%S) $*" >> $LOG_FILE;
}

# if you raise alarm scate process hangs around until alarms cleared.
send_alarm(){ 
    log "ALARM STAT harvester warning $*"
    /apps/omn/bin/scate -alarm 8006 -1 "STAT harvester warning" -2 `hostname` -3 "$*"
}

clear_alarms(){
    SCATE_PROCS=`ps -ef | grep scate | grep 8006 | awk '{print $2}'`
    for i in $SCATE_PROCS; 
        do kill $i;
    done;
}

# clear all alarms before script runs again
clear_alarms

if [ ! -d $DEST_DIR ]; then
    mkdir -p $DEST_DIR
    if [ ! -d $DEST_DIR ]; then
        send_alarm "Stat directory doesn't exist."
        exit 1
    fi
fi

log "BEGIN $PREFIX"

log "Short term stats"
# format of cstat file: 10/9/2015-15:00:28 38
# date +%D-%T
ERROR=
cstat_ci -get "minni.fsm_req_in" -abs -1h -changes_only > ${PREFIX}_minni.fsm_req_in
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "minni.fsm_err_out" -abs -1h -changes_only > ${PREFIX}_minni.fsm_err_out
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.mt_fsm_msc_req_out" -abs -1h -changes_only > ${PREFIX}_dinni.mt_fsm_msc_req_out
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.mt_fsm_rsp_in" -abs -1h -changes_only > ${PREFIX}_dinni.mt_fsm_rsp_in
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.mt_fsm_uerror_in" -abs -1h -changes_only > ${PREFIX}_dinni.mt_fsm_uerror_in
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.sri_req_out" -abs -1h -changes_only > ${PREFIX}_dinni.sri_req_out
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.sri_cnf_in" -abs -1h -changes_only > ${PREFIX}_dinni.sri_cnf_in
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "dinni.sri_uerror_in" -abs -1h -changes_only > ${PREFIX}_dinni.sri_uerror_in
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "qsr.delivery_attempts" -abs -1h -changes_only > ${PREFIX}_qsr.delivery_attempts
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "qsr.delivery_retries" -abs -1h -changes_only > ${PREFIX}_qsr.delivery_retries
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "qsr.messages" -abs -1h -changes_only > ${PREFIX}_qsr.messages
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "qsr.receipts" -abs -1h -changes_only > ${PREFIX}_qsr.receipts
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "reafer.total_msgs_in_requests" -abs -1h -changes_only > ${PREFIX}_reafer.total_msgs_in_requests
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
cstat_ci -get "reafer.total_msgs_out_requests" -abs -1h -changes_only > ${PREFIX}_reafer.total_msgs_out_requests
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
[[ ! -z $ERROR ]] && send_alarm "Short term stat error"


make_count_statfile(){
    name=$1; shift
    ZERROR=0
    ERROR=0
    for stat in $*; do 
        #echo $stat;
        bin/cstat_ci -get $stat -1h > ${PREFIX}_${stat}; 
        test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "$name cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
        count=$(cat ${PREFIX}_${stat} | awk '{ SUM += $2} END { print SUM }')
        echo $count > ${PREFIX}_COUNT_${stat}
        echo $stat $count
        rm -f ${PREFIX}_${stat};
        ((ZERROR+=ERROR)) 
    done
    (( ZERROR != 0 )) && send_alarm "Short term stat error: $name"
}

# TELSTAR MCN
make_count_statfile "MCN/telstar" `bin/cstat_ci -list | grep telstar`

# SPUTNIK
make_count_statfile "SIP/sputnik" `bin/cstat_ci -list | grep sputnik`

#ZERROR=0
#ERROR=0
#bin/cstat_ci -list | grep sputnik > /tmp/sputnik.stats
#for stat in `cat /tmp/sputnik.stats`; do 
#    bin/cstat_ci -get $stat -1h > ${PREFIX}_${stat}; 
#    count=$(cat ${PREFIX}_${stat} | awk '{ SUM += $2} END { print SUM }')
#    echo $count > ${PREFIX}_COUNT_${stat}
#    echo $stat $count;
#    rm -f ${PREFIX}_${stat}; 
#    ((ZERROR+=ERROR)) 
#done
#(( ZERROR != 0 )) && send_alarm "Short term stat error: SIP/sputnik"


log "Long term stats"
ERROR=
# absent subscriber
psx -x -n "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_SM_006" -s -1h -e -0h -total |sed "s/Stat not found/0/" > ${PREFIX}_absent_subscriber_sm
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
psx -x -n "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_027" -s -1h -e -0h -total |sed "s/Stat not found/0/" > ${PREFIX}_absent_subscriber
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

# unknown subscriber
psx -x -n "GSM MAP DELIVERY error response/UNKNOWN_SUBSCRIBER_001" -s -1h -e -0h -total |sed "s/Stat not found/0/" > ${PREFIX}_unknown_subscriber
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

# ESME
psx -l -n "Incoming Normal Message Requests Received" | while read stat; do echo ; psx -x -n "Incoming Normal Message Requests Received"/"$stat" -s -1h -e 0h -total; done > ${PREFIX}_esme_in_req_received
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

psx -l -n "Incoming Normal Message Requests Accepted" | while read stat; do echo ; psx -x -n "Incoming Normal Message Requests Accepted"/"$stat" -s -1h -e 0h -total; done > ${PREFIX}_esme_in_req_accepted
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

psx -l -n "Incoming Normal Message Requests Rejected" | while read stat; do echo ; psx -x -n "Incoming Normal Message Requests Rejected"/"$stat" -s -1h -e 0h -total; done > ${PREFIX}_esme_in_req_rejected
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

psx -l -n "Outgoing Normal Message Requests Sent" | while read stat; do echo ; psx -x -n "Outgoing Normal Message Requests Sent"/"$stat" -s -1h -e 0h -total; done > ${PREFIX}_esme_out_req_sent
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

psx -l -n "Outgoing Normal Message Requests Accepted" | while read stat; do echo ; psx -x -n "Outgoing Normal Message Requests Accepted"/"" -s -1h -e 0h -total; done > ${PREFIX}_esme_out_req_accepted
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

psx -l -n "Outgoing Normal Message Requests Rejected" | while read stat; do echo ; psx -x -n "Outgoing Normal Message Requests Rejected"/"$stat" -s -1h -e 0h -total; done > ${PREFIX}_esme_out_req_rejected
test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"

[[ ! -z $ERROR ]] && send_alarm "Long term stat error"

#$ scripts/pstat_ci.pl -p "Outgoing Normal Message Requests Accepted","Incoming Total Message Requests Received","Incoming Normal Message Requests Accepted","Outgoing Total Message Requests Sent","Call Attempts"
#<pstat_ci.pl> no output file specified (-o),will default to stdout
#3/9/2015-12:15,"Incoming Total Message Requests Received",CDMA_Notify,0
#3/9/2015-12:15,"Outgoing Total Message Requests Sent",CDMA_Notify,0
#3/9/2015-12:15,"Outgoing Normal Message Requests Accepted",CDMA_Notify,0


log "operations CDRs"
ERROR=

# from operations_cdrs count by END_POINT.
# count for each day . . . e.g. 
# $ grep END_POINT: operations_cdrs/OPS_CDR_310815* |sed "s/.*END_POINT://;s/[ \\t].*//" |sort |uniq -c
#      5 
#    117 BLOCKED
#    579 ESME
#    108 Mobile
#    756 STORAGE
i=1
while ((i<2)); do
    # count hour by hour
    ODTS=$(date +%d%m%y%H -d "$i hour ago")
    CSTATDTS=$(date +%D-%T -d "$i hour ago")
    grep END_POINT: operations_cdrs/OPS_CDR_${ODTS}* |sed "s/.*END_POINT://;s/[ \\t].*//" |sort |uniq -c >${DEST_DIR}/ODTS.log
    while read -r count EP; do LOG=${PREFIX}_CDRS_${EP}; echo "$CSTATDTS $count" >$LOG; done <${DEST_DIR}/ODTS.log
    rm -rf ${DEST_DIR}/ODTS.log
    # ls -alstr ${PREFIX}_CDRS_*
    ((i++))
done


log "Housekeeping"
ERROR=
if [[ ! -z $OLDEST_DAYS ]] ; then
    # find stat files and exclude logfile
    COUNT=$(find $DEST_DIR -type f -mtime +${OLDEST_DAYS} ! -iname "*.log"  |wc -l)
    if ((COUNT>0)); then
        # alarm(optional - comment in or out) and remove old files
        log "Warning: stat files were not collected/removed from stat directory. Houskeeping is removing $COUNT files."
        #send_alarm "Warning: stat files were not collected/removed from stat directory. Houskeeping is removing $COUNT files."
        find $DEST_DIR -type f -mtime +${OLDEST_DAYS} -exec rm -rf +
    fi
fi

log "END $PREFIX"

exit 0
