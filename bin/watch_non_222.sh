#!/bin/bash

while true; do 
    # too heavy on machine :-7  should be -1h instead -10m
    echo "WATCH: for messages to foreign ops. Mobile."
    clex -ch 7 -s -10m |sdi -ts -tcap |grep " Address" |grep -vP "\b222\d{8}\b"
    echo "WATCH: for messages to foreign ops. ESME."
    clex -ch 3 -s -10m |bin/reafer_pdu_parse -pdus |grep destination_addr |grep -vP "\b222\d{8}\b"
    echo "WATCH END"
    sleep 600
done
