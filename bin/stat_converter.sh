#! /bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

# A script to convert short-term stats into plaintext format and those those in windstat user's directory for QoS team to download

DEST_DIR=/logs/stats

if [ ! -d $DEST_DIR ]; then
  echo "Stat directory doesn't exists!"
  exit 1
fi

# Short term stats
cstat_ci -get "minni.fsm_req_in" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_minni.fsm_req_in
cstat_ci -get "minni.fsm_err_out" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_minni.fsm_err_out
cstat_ci -get "dinni.mt_fsm_msc_req_out" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.mt_fsm_msc_req_out
cstat_ci -get "dinni.mt_fsm_rsp_in" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.mt_fsm_rsp_in
cstat_ci -get "dinni.mt_fsm_uerror_in" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.mt_fsm_uerror_in
cstat_ci -get "dinni.sri_req_out" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.sri_req_out
cstat_ci -get "dinni.sri_cnf_in" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.sri_cnf_in
cstat_ci -get "dinni.sri_uerror_in" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_dinni.sri_uerror_in
cstat_ci -get "qsr.delivery_attempts" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_qsr.delivery_attempts
cstat_ci -get "qsr.delivery_retries" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_qsr.delivery_retries
cstat_ci -get "qsr.messages" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_qsr.messages
cstat_ci -get "qsr.receipts" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_qsr.receipts
cstat_ci -get "reafer.total_msgs_in_requests" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_reafer.total_msgs_in_requests
cstat_ci -get "reafer.total_msgs_out_requests" -abs -1h > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_reafer.total_msgs_out_requests


# absent subscriber
psx -x -n "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_SM_006" -s -1h -e -0h -total |sed "s/Stat not found/0/" > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_absent_subscriber_sm
psx -x -n "GSM MAP DELIVERY error response/ABSENT_SUBSCRIBER_027" -s -1h -e -0h -total |sed "s/Stat not found/0/" > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_absent_subscriber

# unknown subscriber
psx -x -n "GSM MAP DELIVERY error response/UNKNOWN_SUBSCRIBER_001" -s -1h -e -0h -total |sed "s/Stat not found/0/" > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_unknown_subscriber

# ESME
psx -l -n "Incoming Normal Message Requests Received" | while read stat; do echo $stat; psx -x -n "Incoming Normal Message Requests Received"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_in_req_received

psx -l -n "Incoming Normal Message Requests Accepted" | while read stat; do echo $stat; psx -x -n "Incoming Normal Message Requests Accepted"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_in_req_accepted

psx -l -n "Incoming Normal Message Requests Rejected" | while read stat; do echo $stat; psx -x -n "Incoming Normal Message Requests Rejected"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_in_req_rejected

psx -l -n "Outgoing Normal Message Requests Sent" | while read stat; do echo $stat; psx -x -n "Outgoing Normal Message Requests Sent"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_out_req_sent

psx -l -n "Outgoing Normal Message Requests Accepted" | while read stat; do echo $stat; psx -x -n "Outgoing Normal Message Requests Accepted"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_out_req_accepted

psx -l -n "Outgoing Normal Message Requests Rejected" | while read stat; do echo $stat; psx -x -n "Outgoing Normal Message Requests Rejected"/"$stat" -s -1h -e 0h -total; done > $DEST_DIR/$(date +%Y%m%d%H -d "1 hour ago")_esme_out_req_rejected

exit 0
