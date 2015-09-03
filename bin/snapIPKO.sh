#!/bin/bash

#mobitel_tunnel down && mobitel_tunnel up
# ssh -g -L 9000:213.229.248.126:900 root@dell-b-14 (# run this from your local box #)
# http://localhost:9000 (# open this link in a browser #)

date |tee -a snapTS.log

#TSHOSTS="10.122.251.142 10.122.251.143 10.122.251.140 10.122.251.141"
IPKOHOSTS="10.122.251.151 10.122.251.152 10.122.251.153 10.122.251.154"
for h in $IPKOHOSTS $TSHOSTS; do
 ssh omn@$h "df -h; ls -alstr \"*core*\"; bin/clex -ch 0 -s -2d |tee /tmp/0.log; bin/clex -ch 2 -s -2d |tee /tmp/2.log; bin/clex -ch 3 -s -10m |tee /tmp/3.log;" |tee -a snapTS.log
done

#ssh 10.122.251.142 df -h 
#ssh 10.122.251.143 df -h 
#ssh 10.122.251.153 df -h 
#ssh 10.122.251.154 df -h 
#ssh 10.122.251.140 df -h 
#ssh 10.122.251.141 df -h 
#ssh 10.122.251.151 df -h 
#ssh 10.122.251.152 df -h 
#
