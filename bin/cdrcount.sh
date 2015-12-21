#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

DAYSAGO=1
SHORTCODE="565 300 777"
[[ ! -z $1 ]] && DAYSAGO=$1 && shift
[[ ! -z $1 ]] && SHORTCODE=$1 && shift
ODTS=$(date +%d%m%y -d "$DAYSAGO day ago")
CDRDTS=$(date +%Y%m%d -d "$DAYSAGO day ago")
for shortcode in $SHORTCODE $*; do 
    COUNT=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |wc -l)
    GOODCOUNT=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep $CDRDTS |wc -l)
    COUNTB1=$(./scripts/cluster_cmd.sh "cat \$(ls -tr /data/operations_cdrs/OPS_CDR_${ODTS}* |head -1)"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep -v $CDRDTS |wc -l)
    COUNTB2=$(./scripts/cluster_cmd.sh "cat \$(ls -tr /data/operations_cdrs/OPS_CDR_${ODTS}* |tail -1)"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep -v $CDRDTS |wc -l)
    echo DATE=$ODTS SHORTCODE=$shortcode GOODCOUNT=$GOODCOUNT BAD_COUNT=$COUNT COUNTB1=$COUNTB1 COUNTB2=$COUNTB2
done

