#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

FILE=$1
MSISDN=$2
#FILE=/tmp/24112015_17.ch7
#MSISDN=2348055572473
if [[ -z $FILE || -z $MSISDN ]]; then
    echo e.g. usage ./scripts/grep_ussd.sh 777_drum_err.ch7 8156361236
    echo e.g. usage ./scripts/grep_ussd.sh hsijimiFRE.ch7 2348055574389 
    echo if *whatever*.ch0 .ch3 .ch2 exist then they will be grepped for dialog ids/msisdn also.
    exit -1
fi

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
echo "MSISDN_INFO="; echo "$MSISDN_INFO"
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

#for otid in $OTIDS; do otid_hex=$(echo $otid |sed "s/\.//g"); otid_dec=$(printf %d 0x$otid_hex); echo 0x$otid_hex = $otid_dec; done
for tid in $TIDS; do 
    tid_hex=$(echo $tid |sed "s/\.//g"); 
    tid_dec=$(printf %d 0x$tid_hex); 
    #echo 0x$tid_hex = $tid_dec; 
    TIDS_HEX="$TIDS_HEX $tid_hex"
    TIDS_DEC="$TIDS_DEC $tid_dec"
done
echo TIDS_DEC=$TIDS_DEC
for otid in $OTIDS; do 
    otid_hex=$(echo $otid |sed "s/\.//g"); 
    otid_dec=$(printf %d 0x$otid_hex); 
    #echo 0x$otid_hex = $otid_dec; 
    OTIDS_HEX="$OTIDS_HEX $otid_hex"
    OTIDS_DEC="$OTIDS_DEC $otid_dec"
done
echo OTIDS_DEC=$OTIDS_DEC


cat $CH7FILE |grep -P "^\[\s*($(echo $MIDS |sed "s/ /\|/g"))]" > ${CH7FILE}_${MSISDN}.txt
echo all messages in ${CH7FILE}_${MSISDN}.txt
ls -al ${CH7FILE}_${MSISDN}.txt

grep -P -B1 -A4 "begin =|abort =|end =|Opcode |msisdn =|otid =|dtid =|$MSISDN|ussd_text|operationCode|DataCod" ${CH7FILE}_${MSISDN}.txt > ${CH7FILE}_${MSISDN}_summary.txt

#grep -A1 -P 'ussd_text|msisdn =|abort =|end =' ${CH7FILE}_${MSISDN}.txt |sed -r 's/\s\s*/ /g' |grep -vP "ussd_text|msisdn =|--" |sed "s/.*tid =.*//" > ${CH7FILE}_${MSISDN}_sum.txt
grep -A1 -P 'ussd_text|msisdn =|abort =|end =|begin =|errorCode =' ${CH7FILE}_${MSISDN}.txt |sed -r 's/\s\s*/ /g' |grep -vP "ussd_text|msisdn =|--|tid =" |sed "s/.*begin =.*//" > ${CH7FILE}_${MSISDN}_sum.txt

if [[ -e ${BASEFILE}.ch3 ]] ; then
    echo "\n\nCHANNEL 3:\n" >> ${CH7FILE}_${MSISDN}_sum.txt
    grep -P "ESME: HSI|Direction:|command_id:|short_message:|message_id:|sequence_number:|destination_addr:|source_addr:|$MSISDN|^Time:" ${BASEFILE}.ch3 |grep -B5 -A2 $MSISDN >> ${CH7FILE}_${MSISDN}_sum.txt
fi

if [[ -e ${BASEFILE}.ch2 ]] ; then
    echo "\n\nCHANNEL 2/0:\n" >> ${CH7FILE}_${MSISDN}_sum.txt
    grep -P "$MSISDN|$(echo $TIDS_DEC|sed 's/ /|/g')|$(echo $OTIDS_DEC|sed 's/ /|/g')" ${BASEFILE}.ch[02] >> ${CH7FILE}_${MSISDN}_sum.txt
fi

ls -al ${CH7FILE}_${MSISDN}*

exit




#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                      begin = {
#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                          otid = {
#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                              40 b1 49 85 
#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                          }
#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                          dialoguePortion = {
#[ 267737] 23/3/2016-12:08:01.711 frosti-1 M3UA-Rx:                              dialogueAsID = {
#[omn@tcussd01 ~]$ cat $CH7FILE |grep -C5 -P "\[\s*$(echo $OTIDS |sed "s/ /\|/g")]"|grep -P -A5 "begin =" 

##[omn@tcussd01 ~]$ for id in $IDS; do less /tmp/24112015_17.ch7 |sdi -tcap -ts |grep "^\[ *$id\]" ; done >/tmp/grep_ids${MSISDN}.out
##echo "[ 129177] 24/11/2015-17:36:44.739 frosti-2 M3UA-Rx:                              40 5d da 0f " |grep -P "$(echo $IDS |sed "s/ /\|/g")" 
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

