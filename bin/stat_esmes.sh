#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

OCDRSDIR=/data/operations_cdrs
STATDIR=/logs/stats/

ODTS=$(date +%d%m%y%H)
echo ODTS=$ODTS
# per-ESME per ERR/state/USSD_text counts:
grep END_POINT: ${OCDRSDIR}/OPS_CDR_${ODTS}* |sed -r 's/.*DEST_IDNT://;s/\s*PPS_ID:.*PPS_ERR:/ PS_ERR:/;s/\s*SILO:.*END_POINT:/ /;s/\s*USSD_Req_text.*USSD_text:/ USSD_text:/;s/USSD_Req_text.*//' |grep -v ^[0-9] |sort |uniq -c

ODTS=$(date +%d%m%y%H -d "$i hour ago")

for i in $(seq 1 $((24*5))); do 
   ODTS=$(date +%d%m%y%H -d "$i hour ago"); 
   LOG=$STATDIR/${ODTS}_esmes
   if [[ ! -e $LOG ]] ; then
       echo ODTS=$ODTS |tee $LOG; 
       grep END_POINT: ${OCDRSDIR}/OPS_CDR_${ODTS}* |sed -r 's/.*DEST_IDNT://;s/\s*PPS_ID:.*PPS_ERR:/ PS_ERR:/;s/\s*SILO:.*END_POINT:/ /;s/\s*USSD_Req_text.*USSD_text:/ USSD_text:/;s/USSD_Req_text.*//' |grep -v ^[0-9] |sort |uniq -c |tee -a $LOG
   fi 
done

