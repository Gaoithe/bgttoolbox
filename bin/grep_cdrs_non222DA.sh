#!/bin/bash
TIME="today"
[[ ! -z "$1" ]] && TIME="$1"
#ODTS=$(date +%d%m%y%H -d "$i hour ago")
#ODTS=$(date +%d%m%y%H -d "$TIME")
ODTS=$(date +%d%m%y -d "$TIME")
echo date time ODTS=$ODTS

    # grep for I_ERR:1.311 Blocking for CDMA_delay
    # MCN Chinguitel Mauretania
    C=$(grep 1.311.*END_POINT:BLOCKED operations_cdrs/OPS_CDR_${ODTS}* |wc -l)
    echo $C BLOCKED_CDMA_delay_CldPa_Notify

    # non-Mauretanian DA
    C=$(grep -P "END_POINT:(ESME|STORAGE|Mobile)" operations_cdrs/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |wc -l)
    if ((C>0)); then 
        echo WARNING $C DA_NON_222
        grep -P "END_POINT:(ESME|STORAGE|Mobile)" operations_cdrs/OPS_CDR_${ODTS}* |grep -Pv "\sDA_ADDR:1.1.222\d{8}\s" |sed "s/.*DA_ADDR://;s/PRE_TRANS.*//" |sort |uniq -c
        echo END WARNING $C DA_NON_222
    fi
