#!/bin/bash

[[ ! -e /tmp/10m.ch7 ]] && clex -ch 7 -s -10m >/tmp/10m.ch7
[[ ! -e /tmp/10m.ch7.txt ]] && cat /tmp/10m.ch7  |sdi -tcap -ts >/tmp/10m.ch7.txt
TIDS=$(cat /tmp/10m.ch7.txt |grep -A1  -P "abort =|tid =" |grep -A2 abort |grep -vP "^--$|tid|abort" |sed -r 's/.*[TR]x:\s*//;s/\s/\\s/g')

#for t in $TIDS; do echo tid=$t; cat /tmp/10m.ch7.txt |grep -P $t ; done
#[omn@tcussd01 ~]$ for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/10m.ch7.txt |grep -P $t |sed 's/^\[//;s/\]//' |awk '{print $1}' |sort |uniq); echo $IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/10m.ch7.txt ; done;  done |less
#[omn@tcussd01 ~]$ cat /tmp/10m.ch7.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator


#### Full schmoley each pdu expanded:
for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/10m.ch7.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |sort |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/10m.ch7.txt ; done;  done >/tmp/10m.ch7.followabort

#### Full SUMMARY:
#[omn@tcussd01 ~]$ for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/10m.ch7.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/10m.ch7.txt |grep -A1 --no-group-separator -P "(abort|begin|end|kontinue) =|msisdn|ussd_text" ; done;  done |less
for t in $TIDS; do echo tid=$t; IDS=$(cat /tmp/10m.ch7.txt |grep -B4 -A3 -P "$t" |grep -A1 'tid\s=' --no-group-separator |sed 's/^\[//;s/\]//' |awk '{print $1}' |uniq); echo IDS=$IDS; for i in $IDS; do echo i=$i; grep -P "^\[\s*$i\]" /tmp/10m.ch7.txt |grep -A1 --no-group-separator -P "(abort|begin|end|kontinue) =|msisdn|ussd_text" ; done;  done |tee /tmp/10m.ch7.followabort.summary

