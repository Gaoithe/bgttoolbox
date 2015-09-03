#!/bin/bash

#mobitel_tunnel down && mobitel_tunnel up
# ssh -g -L 9000:213.229.248.126:900 root@dell-b-14 (# run this from your local box #)
# http://localhost:9000 (# open this link in a browser #)

DTS=$(date +%Y%m%d_%H%M)
LOG=snapLOG/snapTS_${DTS}.log
date |tee -a ${LOG}

PERIOD=1d
PERIOD=1h
PERIOD=40m
SPERIOD=10m
SPERIOD=20s


TSHOSTS="10.122.251.140 10.122.251.141 10.122.251.151 10.122.251.152"
#IPKOHOSTS="10.122.251.142 10.122.251.143 10.122.251.153 10.122.251.154"
for h in $IPKOHOSTS $TSHOSTS; do
 echo HOST=$h |tee -a ${LOG}
 # log locally and in /tmp/ on host
 ssh omn@$h "{ df -h; ls -alstr *core*; bin/bci -listals; bin/bci -listsev1s; bin/clex -ch 0 -s -${PERIOD}; bin/clex -ch 2 -s -${PERIOD}; bin/clex -ch 3 -s -${SPERIOD} >/tmp/3.log; cat /tmp/3.log |bin/reafer_pdu_parse -pdus; cat /tmp/3.log |bin/clog_parse|grep -v \"  .*\.\..*$\"; bin/clex -ch 4 -s -${SPERIOD}; bin/clex -ch 7 -s -${SPERIOD}; } |tee -a /tmp/$LOG" |tee -a ${LOG}
done

