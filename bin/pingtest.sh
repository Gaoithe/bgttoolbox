#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

# test the connectivity between 10.2.16.98 and 10.2.16.99 with GW 10.2.16.97

# [omn@lsvprdmmsc01 ~]$ ifconfig |grep -B1 10.2.16.98
# eth2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
#         inet 10.2.16.98  netmask 255.255.255.248  broadcast 10.2.16.103

if [[ "$1" == "--help" ]] ; then
   echo <<EOT
 USAGE:
 TO start: nohup ./scripts/pingtest.sh &
 TO stop:  ./scripts/pingtest.sh --stop
 TO restart: nohup ./scripts/pingtest.sh --restart &
 TO check: ./scripts/pingtest.sh --check
 TO check: ./scripts/pingtest.sh --check -7d
 TO check: ./scripts/pingtest.sh --check "" 28/01/2016-19:00:00

EOT
   head -20 $0
   exit
fi

mkdir -p /apps/omn/pingtest
cd /apps/omn/pingtest

GW=10.2.16.97
PERIOD=-5d
[[ ! -z "$2" ]] && PERIOD=$2
GREP="time=[0-9]\\.|time=[0-9]* ms"
if [[ ! -z "$3" ]]; then
   GREP=$3
   DTS=$(echo $GREP |sed -r 's#([0-9][0-9])/([0-9][0-9])/([0-9][0-9][0-9][0-9])-([0-9][0-9]:[0-9][0-9]:[0-9][0-9])#\3/\2/\1 \4#')
   DTSS=$(date -d "$dts" +%s)
   GREP=$(echo $DTSS |sed s/....$//)
   echo DTS=$DTS DTSS=$DTSS GREP=$GREP
fi

if [[ "$1" == "--check" ]] ; then
   ps -elf |grep ping |grep -vE "grep|$$"
   # find pings of more than 9.999ms
   grep -vE $GREP ping.log |sed -r "s/^\[([0-9]*\.*[0-9]*)\]/[\$(date --date=@\1)]/;;s/^(.*)$/echo \"\1\"/" |bash

   #/apps/omn/bin/clex -ch 0 -s $PERIOD |grep -C3  -E "Connectivity| lost|vamp|Reappearance" |grep -vE "shep|cstat"
   #/apps/omn/bin/clex -ch 0 -s $PERIOD |grep -C3  -E "Connectivity| lost|vamp|Reappearance" |grep -vE "shep|cstat" |grep -E "as lost|resolved|Reappearance of "
   /apps/omn/bin/clex -ch 0 -s $PERIOD |grep -E "as lost|Reappearance of "

   exit
fi


PINFO=$(ps -elf |grep ping |grep -vE "grep|$$")
if [[ "$1" == "--stop" || "$1" == "--restart" ]] ; then
   PIDS=$(ps -elf |grep ping |grep -vE "grep|$$" |awk '{print $4}')
   kill $PIDS
   PIDS=$(ps -elf |grep ping |grep -vE "grep|$$" |awk '{print $4}')
   [[ ! -z $PIDS ]] && kill -9 $PIDS
fi

## DEFAULT action is start
#if [[ "$1" == "--start" ]] ; then
#fi

DTS=$(date +%Y%m%d%H%M%S )
mv ping.log ping_old_${DATETIME}.log

while true; do 
   ### -W 10 . . .  mileage seems to vary. Does it really exit? default seems not to be 10, it didn't exit, we saw 30sec pause in ping log
   ### anyway, fping actually seems to be the tool that should be used.
   ping -W 10 -D -I eth2 $GW >> ping.log
   error=$?
   # if ping exits there is a problem
   if [[ $error != 0 ]] ; then
     echo "ERROR: ping exited with code:$error" |tee -a ping.log
     # TODO: raise alarm
   else
     echo "INFO: ping exited with code:$error" |tee -a ping.log
     # todo: CLEAR ALARM, not ideal though, should clear alarm if ping is running happily
   fi
   sleep 1
done

exit


[omn@lsvprdmmsc01 ~]$ date --date=@1453918660.211688 
Wed Jan 27 19:17:40 WAT 2016
[omn@lsvprdmmsc01 ~]$ ~/scripts/pingtest.sh --check
0 S omn      15804 28834  0  80   0 - 28279 wait   17:27 pts/1    00:00:00 /bin/bash /apps/omn/scripts/pingtest.sh --check
0 S omn      28168 28834  0  80   0 - 28279 wait   Jan27 pts/1    00:00:00 /bin/bash ./scripts/pingtest.sh
4 S omn      28172 28168  0  80   0 - 28595 poll_s Jan27 pts/1    00:00:23 ping -D -I eth2 10.2.16.97
PING 10.2.16.97 (10.2.16.97) from 10.2.16.98 eth2: 56(84) bytes of data.
[1453918660.211688] 64 bytes from 10.2.16.97: icmp_seq=3605 ttl=255 time=13.8 ms
[1453919185.790521] 64 bytes from 10.2.16.97: icmp_seq=4130 ttl=255 time=22.4 ms
[1453919323.000594] 64 bytes from 10.2.16.97: icmp_seq=4267 ttl=255 time=34.5 ms
[1453919382.041362] 64 bytes from 10.2.16.97: icmp_seq=4326 ttl=255 time=10.5 ms
[1453919433.172562] 64 bytes from 10.2.16.97: icmp_seq=4377 ttl=255 time=10.9 ms
[1453919470.150749] 64 bytes from 10.2.16.97: icmp_seq=4414 ttl=255 time=13.1 ms
[1453919585.314841] 64 bytes from 10.2.16.97: icmp_seq=4529 ttl=255 time=29.2 ms
[1453919648.364932] 64 bytes from 10.2.16.97: icmp_seq=4592 ttl=255 time=13.2 ms
[1453919895.629613] 64 bytes from 10.2.16.97: icmp_seq=4839 ttl=255 time=10.5 ms
[1453920011.778563] 64 bytes from 10.2.16.97: icmp_seq=4955 ttl=255 time=10.7 ms
[1453920027.817566] 64 bytes from 10.2.16.97: icmp_seq=4971 ttl=255 time=11.0 ms
[1453920038.862032] 64 bytes from 10.2.16.97: icmp_seq=4982 ttl=255 time=24.3 ms
[1453920182.027773] 64 bytes from 10.2.16.97: icmp_seq=5125 ttl=255 time=12.7 ms
[1453935786.520338] 64 bytes from 10.2.16.97: icmp_seq=20714 ttl=255 time=11.4 ms
[1453943894.282677] 64 bytes from 10.2.16.97: icmp_seq=28814 ttl=255 time=11.0 ms
[1453995676.717209] 64 bytes from 10.2.16.97: icmp_seq=15010 ttl=255 time=10.5 ms

