#!/bin/bash

DEST_DIR=/logs/stats

DTS=$(date +%Y%m%d%H%M -d "10 minutes ago")
DTSTART=$(date +%d/%m/%y-%H:%M:00 -d "10 minutes ago")
while true; do

   NOWDATE=$(date)
   NOW=$(date +%s)
   if [[ ! -z "$THEN" ]] ; then
       DTS=$(date +%Y%m%d%H%M -d "$THENDATE")
       DTSTART=$(date +%d/%m/%y-%H:%M:00 -d "$THENDATE")
   fi

   PREFIX=$DEST_DIR/$DTS

   echo WATCH BEGIN DTS=$DTS PREFIX=$PREFIX DTSTART=$DTSTART NOW=$NOW $NOWDATE=$NOWDATE
   date

   clex -s "$DTSTART" -ch 4 > /tmp/10m.ch4
   echo BEGIN sanity check
   cat /tmp/10m.ch4 |grep -A1 -P ": INVITE|: History-|: From:" |head
   echo END sanity check
   echo "WATCH: for messages IN SIP to foreign ops."
   cat /tmp/10m.ch4 |grep History- |sed "s/.*History-Info: <sip://;s/@192.200.11.1:.*//" |grep -Pv "^222\d{8}$|^\d{8}$" |tee /tmp/ch4addr.log
   echo "WATCH: for messages IN SIP from foreign ops."
   cat /tmp/10m.ch4 |grep From: |sed "s/.*From: <sip://;s/@192.200.11.1:.*//" |grep -Pv "^222\d{8}$|^\d{8}$"

   echo "WATCH: for messages to foreign ops. Mobile."
   clex -ch 7 -s "$DTSTART" |sdi -ts -tcap |tee /tmp/10m.ch7 |grep " Address" |grep -vP "\b222\d{8}\b" |tee /tmp/ch7addr.log

   echo "WATCH: for messages to foreign ops. ESME."
   clex -ch 3 -s "$DTSTART" |bin/reafer_pdu_parse -pdus |tee /tmp/10m.ch3 |grep destination_addr |grep -vP "\b222\d{8}\b" |tee /tmp/ch3addr.log

   # funny numbers in messages coming in in sip ch4 log are okay, we should block them.
   # messages going out are bad.
   if [[ -s /tmp/ch7addr.log || -s /tmp/ch3addr.log ]] ; then
       echo "WATCH found something. mkdir $PREFIX"
       mkdir $PREFIX
       cp -p /tmp/ch3addr.log /tmp/ch4addr.log /tmp/ch7addr.log $PREFIX/
       cp -p /tmp/10m.ch3 /tmp/10m.ch4 /tmp/10m.ch7 $PREFIX/
       clex -ch 0 -s "$DTSTART" > $PREFIX/10m.ch0
       clex -ch 1 -s "$DTSTART" > $PREFIX/10m.ch1
       clex -ch 2 -s "$DTSTART" > $PREFIX/10m.ch2
       clex -ch 13 -s "$DTSTART" > $PREFIX/10m.ch13
       ls -al $PREFIX/
   fi 

   echo "WATCH END"

   THENDATE=$NOWDATE
   THEN=$NOW
   NEXT=$((THEN+600))
   NOW=$(date +%s)
   sleep $(( $NEXT - $NOW ))

done
