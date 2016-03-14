#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

# e.g. usage:
#./scripts/cluster_cmd.sh rm -rf /tmp/cdrcount_070316.txt
#./scripts/cdrcount.sh "1" "0011223344 0011223345 484 326 610 737 822 901 909"


DAYSAGO=1
DAYSAGO="1 2 3 4 5"
SHORTCODE="540 565 300 777"
SHORTCODE="0011223344 0011223345 484 326 610 737 822 901 909"

[[ ! -z $1 ]] && DAYSAGO=$1 && shift
[[ ! -z $1 ]] && SHORTCODE=$1 && shift
echo $0 \"$DAYSAGO\" \"$SHORTCODE\"
for d in $DAYSAGO; do
  ## ODTS = OPS CDR DTS, Y = yesterday T = tomorrow (relative to ODTS/DAYSAGO)
  ODTS=$(date +%d%m%y -d "$d day ago")
  YDTS=$(date +%d%m%y -d "$((d+1)) day ago")
  TDTS=$(date +%d%m%y -d "$((d-1)) day ago")
  CDRDTS=$(date +%Y%m%d -d "$d day ago")

  SUM=$(./scripts/cluster_cmd.sh "cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
  echo DATE=$ODTS Assure count on each node SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format.
  SUM=$(./scripts/cluster_cmd.sh "grep '^869,261,.*' assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* |wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
  echo DATE=$ODTS Assure count ^869,261, on each node SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format.


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

  OCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
  YCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
  TCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}'" |wc -l)
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
    scOCOUNT=$(./scripts/cluster_cmd.sh "cat $OFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    scYCOUNT=$(./scripts/cluster_cmd.sh "cat $YFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    scTCOUNT=$(./scripts/cluster_cmd.sh "cat $TFILE |grep -P 'MSG_TYPE:(869|868|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:$shortcode\b' " |wc -l)
    echo DATE=$ODTS SHORTCODE=$shortcode scOCOUNT=$scOCOUNT scYCOUNT=$scYCOUNT scTCOUNT=$scTCOUNT TOT=$((scOCOUNT+scYCOUNT+scTCOUNT))

    #SUM=$(./scripts/cluster_cmd.sh  'cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* '" |grep -P '\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$'|wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
    SUM=$(./scripts/cluster_cmd.sh  'cat assure_test_logs/ussd/Assure_tcussd0*_${CDRDTS}* '" |grep -P '869,261,.*\b$shortcode\b,.*,.*,.*,.*,.*,.*,.*,.*,$'|wc -l" |grep ^[0-9]*$ |sed -r ': rep;/.*/ {N;s/\n/+/g;t rep}')
    echo DATE=$ODTS Assure count on each node SHORTCODE=$shortcode SUM=$SUM ans=$(($SUM)), NOT date exclusive as date-time stamp in assure is unix time format.
    
    ./scripts/cluster_cmd.sh "cat $OFILE $YFILE $TFILE |grep -P 'MSG_TYPE:(869|869|358|359|360|361).*SUB_TIME:${CDRDTS}' |grep -P 'USSD_text:${shortcode}\b' " |grep -v "Running.. cat "|sed -r 's/THREAD.*MSG_TYPE://;s/\s.*ORIG_IDNT:/,/;s/\s.*DEST_IDNT:/,/;s/\s.*END_POINT:/,/;s/\s.*FINAL_STATE:/,/;s/\s.*USSD_text:/,/;s/\s.*[A-Za-z_].*$//;s/6215[0-9]{11}/IMSI/'|cut -d , -f 1,2,3,6,4,5 |sort |uniq -c |tee countcdrs_${ODTS}_${shortcode}.txt
    ls -alstr countcdrs_${ODTS}_${shortcode}.txt
    #cat countcdrs_${ODTS}_${shortcode}.txt

  done
done


#[tcussd03] Running.. cat assure_test_logs/ussd/Assure_tcussd0*_20151219* |grep -P '\b540\b,.*,.*,.*,.*,.*,.*,.*,.*,$' |sed 's/^\([^,]*,[^,]*\),.*/\1/' |sort |uniq -c
#     25 358,102
#     18 359,103
#      9 361,105
#      8 869,0
#     12 869,261
#[omn@tcussd01 ~]$ #
#
#THE MAGIC NUMBERS:
#      2 869,261
