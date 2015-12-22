#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

DAYSAGO=1
DAYSAGO="1 2 3 4 5"
SHORTCODE="540 565 300 777"
[[ ! -z $1 ]] && DAYSAGO=$1 && shift
[[ ! -z $1 ]] && SHORTCODE=$1 && shift
echo $0 \"$DAYSAGO\" \"$SHORTCODE\"
for d in $DAYSAGO; do
  ## ODTS = OPS CDR DTS, Y = yesterday T = tomorrow (relative to ODTS/DAYSAGO)
  ODTS=$(date +%d%m%y -d "$d day ago")
  YDTS=$(date +%d%m%y -d "$((d+1)) day ago")
  TDTS=$(date +%d%m%y -d "$((d-1)) day ago")
  CDRDTS=$(date +%Y%m%d -d "$d day ago")
  ## ODTS = OPS CDR DTS, Y = yesterday T = tomorrow (relative to ODTS/DAYSAGO)
  OFILE=/tmp/cdrcount_${ODTS}.txt
  YFILE=/tmp/cdrcount_${YDTS}.txt
  TFILE=/tmp/cdrcount_${TDTS}.txt
  if [[ ! -e $OFILE ]] ; then
      # handle CDRs with menus, strip out most of menu
      #./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*" |grep -P "^THREAD_ID|USSD_text" |sed 's/with: /WITHCHOMP/'|sed -r '$!N;s/\n[^:]*USSD_dlg_id:/CHOMPYSTUFF USSD_dlg_id:/;P;D' >$OFILE
      ./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}* |grep -P '^THREAD_ID|USSD_text' |sed 's/with: /WITHCHOMP/'|sed -r '$!N;s/\n[^T][^H][^R][^E][^A][^D].*USSD_dlg_id:/CHOMPYSTUFF USSD_dlg_id:/;P;D' >$OFILE"
  fi
  if [[ ! -e $YFILE ]] ; then
      # handle CDRs with menus, strip out most of menu
      ./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${YDTS}* |grep -P '^THREAD_ID|USSD_text' |sed 's/with: /WITHCHOMP/'|sed -r '$!N;s/\n[^T][^H][^R][^E][^A][^D].*USSD_dlg_id:/CHOMPYSTUFF USSD_dlg_id:/;P;D' >$YFILE"
  fi
  if [[ ! -e $TFILE ]] ; then
      # handle CDRs with menus, strip out most of menu
      ./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${TDTS}* |grep -P '^THREAD_ID|USSD_text' |sed 's/with: /WITHCHOMP/'|sed -r '$!N;s/\n[^T][^H][^R][^E][^A][^D].*USSD_dlg_id:/CHOMPYSTUFF USSD_dlg_id:/;P;D' >$TFILE"
  fi

  OCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
  YCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
  TCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
  echo d=$d CDRDTS=$CDRDTS $ODTS Y=$YDTS T=$TDTS
  echo DATE=$ODTS TOTALS OCOUNT=$OCOUNT YCOUNT=$YCOUNT TCOUNT=$TCOUNT TOT=$((OCOUNT+YCOUNT+TCOUNT))

  #cat $OFILE |grep -P "MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}.*FINAL_STATE:DELIVERED"|grep -P "USSD_text:$shortcode\b" |grep $CDRDTS |wc -l)

  for shortcode in $SHORTCODE $*; do 
    #BADCOUNT=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |wc -l)
    #869COUNT=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep $CDRDTS |wc -l)
    #xxxBADCOUNT_missCDRSwithMENUS=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep -P "MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}.*FINAL_STATE:DELIVERED"|grep -P "USSD_text:$shortcode\b" |grep $CDRDTS |wc -l)
    #COUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}.*FINAL_STATE:DELIVERED' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    #ALSOBADCOUNT=$(./scripts/cluster_cmd.sh "cat /data/operations_cdrs/OPS_CDR_${ODTS}*"|grep -P "MSG_TYPE:(869|869|358|359|360|361)"|grep -P "USSD_text:$shortcode\b" |grep $CDRDTS |wc -l)
    #COUNTB1=$(./scripts/cluster_cmd.sh "cat \$(ls -tr /data/operations_cdrs/OPS_CDR_${ODTS}* |head -1)"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep -v $CDRDTS |wc -l)
    #COUNTB2=$(./scripts/cluster_cmd.sh "cat \$(ls -tr /data/operations_cdrs/OPS_CDR_${ODTS}* |tail -1)"|grep "MSG_TYPE:869"|grep -P "USSD_text:$shortcode\b" |grep -v $CDRDTS |wc -l)
    #echo DATE=$ODTS SHORTCODE=$shortcode COUNT=$COUNT COUNTB1=$COUNTB1 COUNTB2=$COUNTB2 TOT=$((COUNT+COUNTB1+COUNTB2)) add COUNTB1/B2 to preceding or foillowing days count
    scOCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    scYCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    scTCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    echo DATE=$ODTS SHORTCODE=$shortcode scOCOUNT=$scOCOUNT scYCOUNT=$scYCOUNT scTCOUNT=$scTCOUNT TOT=$((scOCOUNT+scYCOUNT+scTCOUNT))
  done
done

