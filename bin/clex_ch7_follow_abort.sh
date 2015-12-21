#!/bin/bash

#echo "Usage: $0 logfile.ch7 start [end]"
#echo "e.g.: $0 logfile.ch7 23/9/2015-00:00 23/9/2015-00:10"

CH7FILE=10m.ch7
STARTTIME=-10m
ENDTIME=
[[ ! -z $1 ]] && CH7FILE=$1 && shift
[[ ! -z $1 ]] && STARTTIME=$1 && shift
[[ ! -z $1 ]] && ENDTIME="-e $1" && shift

[[ ! -e /tmp/${CH7FILE} ]] && clex -ch 7 -s ${STARTTIME} -e ${ENDTIME} >/tmp/${CH7FILE}
[[ ! -e /tmp/${CH7FILE}.txt ]] && cat /tmp/${CH7FILE}  |sdi -tcap -ts >/tmp/${CH7FILE}.txt
TIDS=$(cat /tmp/${CH7FILE}.txt |grep -A1  -P "abort =|tid =" |grep -A2 abort |grep -vP "^--$|tid|abort" |sed -r 's/.*[TR]x:\s*//;s/\s/\\s/g')

#for t in $TIDS; do echo tid=$t; cat /tmp/${CH7FILE}.txt |grep -P $t ; done
#[omn@tcussd01 ~]$ for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/${CH7FILE}.txt |grep -P $t |sed 's/^\[//;s/\]//' |awk '{print $1}' |sort |uniq); echo $IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/${CH7FILE}.txt ; done;  done |less
#[omn@tcussd01 ~]$ cat /tmp/${CH7FILE}.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator


#### Full schmoley each pdu expanded:
for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/${CH7FILE}.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |sort |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/${CH7FILE}.txt ; done;  done >/tmp/${CH7FILE}.followabort

#### Full SUMMARY:
#[omn@tcussd01 ~]$ for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/${CH7FILE}.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/${CH7FILE}.txt |grep -A1 --no-group-separator -P "(abort|begin|end|kontinue) =|msisdn|ussd_text" ; done;  done |less
for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/${CH7FILE}.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/${CH7FILE}.txt |grep -A1 --no-group-separator -P "(abort|begin|end|kontinue) =|msisdn|ussd_text" ; done;  done |tee /tmp/${CH7FILE}.followabort.summary

