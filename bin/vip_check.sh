#!/bin/bash
#--------------------------------------------------------------------------
# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.
#--------------------------------------------------------------------------
# OMN - JCO 29/2/2016
# Check status of VIP.
# If no VIP assigned and can connect to all hosts then stop/start vamp.
# Hardcoded, VIP check on "eth0" of form "eth[0-9]+:[0-9]+:" e.g. eth0:3:
# Hardcoded, /usr/sbin/ifconfig

LOG_FILE=/logs/vip_check.log

log(){
    echo "$(date +%d/%m/%Y-%H:%M:%S) $*" >> $LOG_FILE;
}

# 8006 is custom alarm.
send_alarm(){ 
    /apps/omn/bin/scate -alarm 8006 -1 "VIP check Failed" -2 `hostname` -3 "$*"
}

clear_alarms(){
    SCATE_PROCS=`ps -ef | grep scate | grep 8006 | awk '{print $2}'`
        for i in $SCATE_PROCS; 
            do kill $i;
        done;
}

log "CHECK VIP status"
/apps/omn/scripts/cluster_cmd.sh '/usr/sbin/ifconfig' >/tmp/vip_check

A=$(grep -P ^eth[0-9]+:[0-9]+: /tmp/vip_check)
ERR=$?
if ((ERR == 1)); then
   NODECOUNT=$(grep Running\.\. /tmp/vip_check |wc -l)
   ETH0COUNT=$(grep -P ^eth0: /tmp/vip_check|wc -l)
   log "VIP check FAIL. ERR=$ERR NODECOUNT=$NODECOUNT ETH0COUNT=$ETH0COUNT"
   if ((ETH0COUNT==NODECOUNT)) ; then
      send_alarm "VIP check FAIL. ERR=$ERR NODECOUNT=$NODECOUNT ETH0COUNT=$ETH0COUNT"
      log "All nodes visible. No VIP. Doing sci stop/start of vamp"
      /apps/omn/scripts/cluster_cmd.sh '/apps/omn/bin/aci | grep -i vamp && ps -elf |grep vamp && /usr/sbin/ifconfig' >> $LOG_FILE
      log "STOP vamp"
      /apps/omn/bin/sci -stop_proc vamp
      sleep 5
      log "START vamp"
      /apps/omn/bin/sci -start_proc vamp
      sleep 1
      /apps/omn/scripts/cluster_cmd.sh '/apps/omn/bin/aci | grep -i vamp && ps -elf |grep vamp && /usr/sbin/ifconfig' >> $LOG_FILE
   else
      log "VIP check fail, but all nodes not visible. No action"
   fi
else
   log "VIP check okay"
   clear_alarms
fi

exit 0
