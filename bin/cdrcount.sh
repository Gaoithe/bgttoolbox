#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

# remove files older than 4 days
./scripts/cluster_cmd.sh 'find /tmp/cdrcount_* -mtime +4 -exec rm -rf {} +'

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

  OINFOFILE=/tmp/cdrcount_${ODTS}_info.txt
  if [[ ! -e $OINFOFILE ]] ; then
      SUM=$(./scripts/cluster_cmd.sh "cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo DATE=$ODTS CDRDTS=$CDRDTS Assure count on each node SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format. |tee $OINFOFILE
      SUM=$(./scripts/cluster_cmd.sh "grep '^869,261,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,2,.*' assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
      echo DATE=$ODTS Assure count ^869,261, on each node SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format. |tee -a $OINFOFILE

      OCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
      YCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
      TCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
      echo d=$d CDRDTS=$CDRDTS $ODTS Y=$YDTS T=$TDTS |tee -a $OINFOFILE
      echo DATE=$ODTS TOTALS OCOUNT=$OCOUNT YCOUNT=$YCOUNT TCOUNT=$TCOUNT TOT=$((OCOUNT+YCOUNT+TCOUNT)) |tee -a $OINFOFILE
  else
      ls -al $OINFOFILE
      cat $OINFOFILE
  fi

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


    SCFILE=/tmp/cdrcount_${ODTS}_${shortcode}.txt
    if [[ ! -e $SCFILE ]] ; then
        ./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " > $SCFILE
        ./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " >> $SCFILE
        ./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " >> $SCFILE
    fi
    echo DATE=$ODTS SHORTCODE=$shortcode TOT=$(wc -l $SCFILE) ShortCodeFILE=$SCFILE includes CDRS from $YDTS $ODTS $TDTS

    #scOCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " |wc -l)
    #scYCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " |wc -l)
    #scTCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b|OA_ADDR:\d+\.\d+\.${shortcode}' " |wc -l)
    #echo DATE=$ODTS SHORTCODE=$shortcode scOCOUNT=$scOCOUNT scYCOUNT=$scYCOUNT scTCOUNT=$scTCOUNT TOT=$((scOCOUNT+scYCOUNT+scTCOUNT))

    #SUM=$(./scripts/cluster_cmd.sh  "cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |grep -P '\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$'|wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
    #SUM=$(./scripts/cluster_cmd.sh "cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |grep -P '^869,261,.*\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$'|wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
    SUM=$(./scripts/cluster_cmd.sh "grep -P '^869,261,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,2,.*\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$' assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
    echo DATE=$ODTS CDRDTS=$CDRDTS Assure count on each node SHORTCODE=$shortcode SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format.

    #./scripts/cluster_cmd.sh "cat $OFILE $YFILE $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:${shortcode}\b|OA_ADDR:\d+\.\d+\.${shortcode}' " |grep -v "Running.. cat "|sed -r 's/THREAD.*MSG_TYPE://;s/\s.*ORIG_IDNT:/,/;s/\s.*DEST_IDNT:/,/;s/\s.*END_POINT:/,/;s/\s.*FINAL_STATE:/,/;s/\s.*USSD_text:/,/;s/\s.*[A-Za-z_].*$//;s/6215[0-9]{11}/IMSI/'|cut -d , -f 1,2,3,6,4,5 |sort |uniq -c |tee countcdrs_${ODTS}_${shortcode}.txt
    #cat $SCFILE |grep -v "Running.. cat "|sed -r 's/THREAD.*MSG_TYPE://;s/\s.*ORIG_IDNT:/,/;s/\s.*DEST_IDNT:/,/;s/\s.*END_POINT:/,/;s/\s.*FINAL_STATE:/,/;s/\s.*USSD_text:/,/;s/\s.*[A-Za-z_].*$//;s/6215[0-9]{11}/IMSI/'|cut -d , -f 1,2,3,6,4,5 |sort |uniq -c |tee countcdrs_${ODTS}_${shortcode}.txt
    cat $SCFILE |grep -v "Running.. "|sed -r 's/THREAD.*MSG_TYPE://;s/DEST_IDNT:([A-Z_a-z0-9]*\:)*([A-Z_a-z0-9]*)$/Di:\2/;s/TEXT:(OA_ADDR|DA_ADDR):/TEXT_xA:/;s/\s.*OA_ADDR:/,/;s/\s.*DA_ADDR:/,/;s/\s.*ORIG_IDNT:/,/;s/\s.*DEST_IDNT:/,/;s/END_POINT:NO ROUTE/END_POINT:NO_ROUTE/;s/\s.*END_POINT:/,/;s/\s.*FINAL_STATE:/,/;s/\s.*USSD_text:/,/;s/\s.*[A-Za-z_].*$//;s/6215[0-9]{11}/IMSI/;s/[01]\.[01]\.23[0-9]{10}[0-9]*/MSISDN/'|cut -d , -f 1,2,3,4,5,6,7,8 |sort |uniq -c |tee countcdrs_${ODTS}_${shortcode}.txt
    ls -alstr countcdrs_${ODTS}_${shortcode}.txt
    #cat countcdrs_${ODTS}_${shortcode}.txt

  done
done

#shortcode=540; ./scripts/cluster_cmd.sh  "cat assure_test_logs/ussd/Assure_tcussd0*_20151219* |grep -P '\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$' |sed 's/^\([^,]*,[^,]*\),.*/\1/' |sort |uniq -c"

