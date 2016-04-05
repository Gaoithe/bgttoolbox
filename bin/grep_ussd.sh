#!/bin/bash

# e.g. usage ./scripts/grep_ussd.sh 777_drum_err.ch7 8156361236
FILE=$1
MSISDN=$2
#FILE=/tmp/24112015_17.ch7
#MSISDN=2348055572473
[[ -z $FILE ]] && exit -1
[[ -z $MSISDN ]] && exit -1

CH7FILE=$FILE
BASEFILE=${FILE//.ch7/}
head $FILE |grep frosti >/dev/null
if [[ $? == 1 ]] ; then
    less $FILE |sdi -tcap -ts >${BASEFILE}.txt
    CH7FILE=${BASEFILE}.txt
fi

echo FILE=$FILE CH7FILE=$CH7FILE BASEFILE=$BASEFILE MSISDN=$MSISDN
#less $CH7FILE |grep -B200 -A200 $MSISDN >/tmp/grep_begin${MSISDN}.out
#MSISDN_INFO=$(grep $MSISDN /tmp/grep_begin${MSISDN}.out)
echo grep $MSISDN $CH7FILE
MSISDN_INFO=$(grep $MSISDN $CH7FILE)
[[ -z "$MSISDN_INFO" ]] && echo "no match" && exit
echo "MSISDN_INFO=$MSISDN_INFO"
IDS=$(echo "$MSISDN_INFO" |sed "s/^\[ *//;s/]//"|cut -d" " -f 1)
echo IDS=$IDS

# find any otid/dtid matching search
TIDS=$(cat $CH7FILE |grep -P "^\[\s*($(echo $IDS |sed "s/ /\|/g"))]"|grep -P -A1 "otid =|dtid =" |sed "s/.*:\s*//;s/ $//g;s/ /./g" |grep -v -P "dtid|otid|--" |sort|uniq)
echo TIDS=$TIDS
# find any otid/dtid associated with the search tids
OTIDS=$(cat $CH7FILE |grep -P -A2 "otid =|dtid =" |grep -v -P "dtid|otid|}\s*$" |grep -B1 -A1 -P "\s+($(echo $TIDS |sed "s/ /\|/g"))\s*$" |sed "s/.*:\s*//;s/ $//g;s/ /./g" |grep -v -P -- "--" |sort|uniq)
echo OTIDS=$OTIDS
# find all message IDs 
MIDS=$(cat $CH7FILE |grep -P -A2 "otid =|dtid =" |grep -v -P "dtid|otid|}\s*$" |grep -B1 -A1 -P "\s+($(echo $OTIDS |sed "s/ /\|/g"))\s*$" |sed "s/^\[ *//;s/]//"|cut -d" " -f 1|sort|uniq)
echo MIDS=$MIDS


cat $CH7FILE |grep -P "^\[\s*($(echo $MIDS |sed "s/ /\|/g"))]" > ${CH7FILE}_${MSISDN}.txt
echo all messages in ${CH7FILE}_${MSISDN}.txt
ls -al ${CH7FILE}_${MSISDN}.txt

grep -P -B1 -A4 "begin =|abort =|end =|Opcode |msisdn =|otid =|dtid =|$MSISDN|ussd_text|operationCode|DataCod" ${CH7FILE}_${MSISDN}.txt > ${CH7FILE}_${MSISDN}_summary.txt
ls -al ${CH7FILE}_${MSISDN}*

exit





#!/bin/bash

FILE=$1
MSISDN=$2
#FILE=/tmp/24112015_17.ch7
#MSISDN=2348055572473
[[ -z $FILE ]] && exit -1
[[ -z $MSISDN ]] && exit -1

less $FILE |sdi -tcap -ts |grep -B200 -A200 $MSISDN >/tmp/grep_begin${MSISDN}.out
MSISDN_INFO=$(grep $MSISDN /tmp/grep_begin${MSISDN}.out)
IDS=$(echo "$MSISDN_INFO" |sed "s/^\[ *//;s/]//"|cut -d" " -f 1)
echo "$MSISDN_INFO"
echo $IDS


##[omn@tcussd01 ~]$ for id in $IDS; do less /tmp/24112015_17.ch7 |sdi -tcap -ts |grep "^\[ *$id\]" ; done >/tmp/grep_ids${MSISDN}.out
##echo "[ 129177] 24/11/2015-17:36:44.739 frosti-2 M3UA-Rx:				 40 5d da 0f " |grep -P "$(echo $IDS |sed "s/ /\|/g")" 
##less /tmp/24112015_17.ch7 |sdi -tcap -ts |grep -P "$(echo $IDS |sed "s/ /\|/g")" >/tmp/grep_ids${MSISDN}.out

cat /tmp/grep_begin${MSISDN}.out|grep -P "$(echo $IDS |sed "s/ /\|/g")" >/tmp/grep_ids${MSISDN}.out
#grep -P -A1 "otid =|dtid =" /tmp/grep_ids${MSISDN}.out
OTIDS=$(grep -P -A1 "otid =|dtid =" /tmp/grep_ids${MSISDN}.out |sed "s/.*:\s*//;s/ $//g;s/ /./g" |grep -v -P "otid|--")
echo $OTIDS
# get all [OD]TIDS
OTIDS=$(cat /tmp/grep_begin${MSISDN}.out|grep -C5 -P "$(echo $OTIDS |sed "s/ /\|/g")"|grep -P -A1 "otid =|dtid =" |sed "s/.*:\s*//;s/ $//g;s/ /./g" |grep -v -P "dtid|otid|--")
echo $OTIDS


##less /tmp/24112015_17.ch7 |sdi -tcap -ts |grep -P "$(echo $IDS |sed "s/ /\|/g")" >/tmp/grep_ids${MSISDN}.out
less $FILE |sdi -tcap -ts |grep -B7 -A500 -P "$(echo $OTIDS |sed "s/ /\|/g")" >/tmp/grep_allotids${MSISDN}.out

IDS=$(cat /tmp/grep_allotids${MSISDN}.out |grep -P "$(echo $OTIDS |sed "s/ /\|/g")" |sed "s/^\[ *//;s/]//"|cut -d" " -f 1)
echo $IDS
cat /tmp/grep_allotids${MSISDN}.out|grep -P "$(echo $IDS |sed "s/ /\|/g")" >/tmp/grep_all${MSISDN}.out



grep -P -B1 -A4 "otid =|dtid =|$MSISDN|ussd_text|operationCode|DataCod" /tmp/grep_all${MSISDN}.out |tee  /tmp/grep_${MSISDN}_summary.out
#cat /tmp/grep_all${MSISDN}.out
ls -alstr /tmp/grep_all${MSISDN}.out
