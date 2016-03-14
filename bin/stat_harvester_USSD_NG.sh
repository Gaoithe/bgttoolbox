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

make_count_statfile(){
    name=$1; shift
    ZERROR=0
    ERROR=0
    for stat in $*; do 
        #echo $stat;
        # format of cstat file: 10/9/2015-15:00:28 38
        bin/cstat_ci -get $stat -1h > ${PREFIX}_${stat}; 
        test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "make_count_statfile $name cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
        count=$(cat ${PREFIX}_${stat} | awk '{ SUM += $2} END { print SUM }')
        echo $count > ${PREFIX}_COUNT_${stat}
        echo $stat $count
        # some operators may like to use the more detailed stat file
        rm -f ${PREFIX}_${stat};
        ((ZERROR+=ERROR)) 
    done
    (( ZERROR != 0 )) && send_alarm "Short term stat error: $name"
}

get_longterm_stat(){
    shortname=$1; shift
    name=$1; shift
    bin/psx -x -n "$name" -s -1h -e -0h -total |sed "s/Stat not found/0/" > ${PREFIX}_${shortname}
    test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "get_longterm_stat $name cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
    echo $shortname $name $ERROR
    ((ZERROR+=ERROR))
}

get_longterm_stat_list(){
    shortname=$1; shift
    name=$1; shift

    bin/psx -l -n "${name}" | 
        while read stat; do 
            #echo -n "$name"/"$stat ";
            bin/psx -x -n "$name"/"$stat" -s -1h -e 0h -total; 
        done > ${PREFIX}_${shortname}

    test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "get_longterm_stat_list $name cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
    echo $shortname $name $ERROR
    ((ZERROR+=ERROR))
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

#ERROR=
#cstat_ci -get "minni.fsm_err_out" -abs -1h -changes_only > ${PREFIX}_minni.fsm_err_out
#test ${PIPESTATUS[0]} -ne 0 && ERROR=${PIPESTATUS[0]} && log "cmd error:${PIPESTATUS[0]} cmd:!:0 !:*"
# format of cstat file: 10/9/2015-15:00:28 38
# date +%D-%T
#[[ ! -z $ERROR ]] && send_alarm "Short term stat error"

#make_count_statfile minni minni.fsm_req_in minni.fsm_err_out

#make_count_statfile dinni dinni.mt_fsm_msc_req_out dinni.mt_fsm_rsp_in dinni.mt_fsm_uerror_in dinni.sri_req_out dinni.sri_cnf_in dinni.sri_uerror_in

make_count_statfile storage/quasar qsr.delivery_attempts qsr.delivery_retries qsr.messages qsr.receipts

# reafer + USSD
make_count_statfile ESME/reafer reafer.total_msgs_in_requests reafer.total_msgs_out_requests reafer.ussd_pssr_out_acked  reafer.ussd_pssr_out_nacked reafer.ussd_pssr_out_requests reafer.ussd_msgs_out_acked reafer.ussd_msgs_out_nacked reafer.ussd_msgs_in_acked reafer.ussd_msgs_in_nacked reafer.ib_sessions reafer.normal_msgs_in_acked

# Licence traffic rates monitoring
#make_count_statfile Licenced-Traffic-Rates reafer.normal_msgs_in_acked gummi.pssd_cnf_out gummi.pssr_cnf_out g2c2g.mofsm_cnf_out g2c2g.mtfsm_cnf_out minni.fsm_rsp_out vinni.fsm_rsp_out h2c.m_send_conf_out_ack
make_count_statfile Licenced-Traffic-Rates reafer.normal_msgs_in_acked gummi.pssd_cnf_out gummi.pssr_cnf_out g2c2g.mofsm_cnf_out g2c2g.mtfsm_cnf_out minni.fsm_rsp_out vinni.fsm_rsp_out 

# gummi USSD
make_count_statfile USSD/gummi gummi.pssr_req_in gummi.pssr_err_out gummi.ussr_req_out gummi.ussr_err_in

# TELSTAR MCN
#make_count_statfile "MCN/telstar" `bin/cstat_ci -list | grep telstar`

# SPUTNIK
#make_count_statfile "SIP/sputnik" `bin/cstat_ci -list | grep sputnik`

#make_count_statfile "SCTP/frosti" frosti.send_ss_request frosti.send_cs_request frosti.outbound_msg_req frosti.outbound_begin frosti.outbound_continue frosti.inbound_begin frosti.inbound_continue frosti.inbound_end

log "Long term stats"
ZERROR=0

# absent_subscriber
#get_longterm_stat absent_subscriber_sm "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_SM_006" 
#get_longterm_stat absent_subscriber "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_027"
#get_longterm_stat unknown_subscriber "GSM MAP DELIVERY error response/UNKNOWN_SUBSCRIBER_001"

# ESME
#get_longterm_stat_list esme_in_req_received "Incoming Normal Message Requests Received"
#get_longterm_stat_list esme_in_req_accepted "Incoming Normal Message Requests Accepted"
#get_longterm_stat_list esme_in_req_rejected "Incoming Normal Message Requests Rejected"
get_longterm_stat_list esme_out_req_sent psx "Outgoing Normal Message Requests Sent"
get_longterm_stat_list esme_out_req_accepted "Outgoing Normal Message Requests Accepted"
get_longterm_stat_list esme_out_req_rejected "Outgoing Normal Message Requests Rejected"

# disable error check here
#[[ ! -z $ERROR ]] && send_alarm "Long term stat error"


#$ scripts/pstat_ci.pl -p "Outgoing Normal Message Requests Accepted","Incoming Total Message Requests Received","Incoming Normal Message Requests Accepted","Outgoing Total Message Requests Sent","Call Attempts"
#<pstat_ci.pl> no output file specified (-o),will default to stdout
#3/9/2015-12:15,"Incoming Total Message Requests Received",CDMA_Notify,0
#3/9/2015-12:15,"Outgoing Total Message Requests Sent",CDMA_Notify,0
#3/9/2015-12:15,"Outgoing Normal Message Requests Accepted",CDMA_Notify,0


log "operations CDRs"
#OCDRSDIR=/apps/omn/operations_cdrs
OCDRSDIR=/data/operations_cdrs

# from operations_cdrs count by END_POINT.
# count for each day . . . e.g. 
# $ grep END_POINT: ${OCDRSDIR}/OPS_CDR_310815* |sed "s/.*END_POINT://;s/[ \\t].*//" |sort |uniq -c
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
    grep END_POINT: ${OCDRSDIR}/OPS_CDR_${ODTS}* |sed "s/.*END_POINT://;s/[ \\t].*//" |sort |uniq -c >${DEST_DIR}/ODTS.log

    # grep for I_ERR:1.311 Blocking for CDMA_delay
    # MCN Chinguitel Mauretania
    C=$(grep 1.311.*END_POINT:BLOCKED ${OCDRSDIR}/OPS_CDR_${ODTS}* |wc -l)
    echo $C BLOCKED_CDMA_delay_CldPa_Notify >> ${DEST_DIR}/ODTS.log

    ## non-Mauretanian DA
    #C=$(grep -P "END_POINT:BLOCKED" ${OCDRSDIR}/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |wc -l)
    #echo $C DA_NON_222_BLOCKED >> ${DEST_DIR}/ODTS.log
    #if ((C>0)); then 
    #    grep -P "END_POINT:BLOCKED" ${OCDRSDIR}/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |sed "s/.*DA_ADDR://;s/PRE_TRANS.*//" |sort |uniq -c
    #fi
    #C=$(grep -P "END_POINT:(ESME|STORAGE|Mobile)" ${OCDRSDIR}/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |wc -l)
    #echo $C DA_NON_222 >> ${DEST_DIR}/ODTS.log
    #if ((C>0)); then 
    #    echo WARNING $C DA_NON_222
    #    grep -P "END_POINT:(ESME|STORAGE|Mobile)" ${OCDRSDIR}/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |sed "s/.*DA_ADDR://;s/PRE_TRANS.*//" |sort |uniq -c
    #    echo END WARNING $C DA_NON_222
    #fi

    # per-ESME per ERR/state/USSD_text counts:
    grep END_POINT: ${OCDRSDIR}/OPS_CDR_${ODTS}* |sed -r 's/.*DEST_IDNT://;s/\s*PPS_ID:.*PPS_ERR:/ PS_ERR:/;s/\s*SILO:.*END_POINT:/ /;s/\s*USSD_Req_text.*USSD_text:/ USSD_text:/;s/USSD_Req_text.*//' |grep -v ^[0-9] |sort |uniq -c >> ${DEST_DIR}/ODTS.log

    # show the COUNT stats in general log
    cat ${DEST_DIR}/ODTS.log

    ## watch for non-Mauretanian
    # while true; do sleep 600; 
    # too heavy on machine :-7  should be -1h instead -10m
    #echo "WATCH: for messages to foreign ops. Mobile."
    #clex -ch 7 -s -10m |sdi -ts -tcap |grep " Address" |grep -vP "\b222\d{8}\b"
    #echo "WATCH: for messages to foreign ops. ESME."
    #clex -ch 3 -s -10m |bin/reafer_pdu_parse -pdus |grep destination_addr |grep -vP "\b222\d{8}\b"
    #echo "WATCH END"

    #while read -r count EP; do LOG=${PREFIX}_CDRS_${EP}; echo "$CSTATDTS $count" >$LOG; done <${DEST_DIR}/ODTS.log
    ls -alstr ${DEST_DIR}/ODTS.log
    while read -r count EP blargh; do
        if [[ -z $blargh ]] ; then
            LOG=${PREFIX}_CDRS_${EP% *};
            echo "$count" >$LOG; 
        fi
    done <${DEST_DIR}/ODTS.log
    rm -rf ${DEST_DIR}/ODTS.log
    # ls -alstr ${PREFIX}_CDRS_*
    ((i++))
done


log "Housekeeping"
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

