#!/bin/bash
#--------------------------------------------------------------------------
# OMN - DF 1/9/2015 
# This script imports DSO MMS capable subscribers into SPD DB. It does it
# it with new db option rather than using deltas.
# v0.1

IMPORT_FILE=/data/spd_import/spd_import.dat
LOG_FILE=/data/spd_import/spd_import.log

log(){
    echo "$(date +%d/%m/%Y-%H:%M:%S) $*" >> $LOG_FILE;
}

send_alarm(){ 
    /apps/omn/bin/scate -alarm 8006 -1 "SPD Import Failed" -2 `hostname` -3 "$*"
}

clear_alarms(){
    SCATE_PROCS=`ps -ef | grep scate | grep 8006 | awk '{print $2}'`
        for i in $SCATE_PROCS; 
            do kill $i;
        done;
}

log ""
log "BEGIN Check for new file"
if [ ! -f $IMPORT_FILE ]; then
    log "INFO: No new file to import"
    log "END Check for new file ends with no new file result"
    exit 0
fi

clear_alarms

if [ ! -s $IMPORT_FILE ]; then
    log "ERROR: File is there but is empty?!?"
    send_alarm "Empty file"
    log "END Check for new file ends with error - empty file"
    exit 255
fi
log "END Check for new file"

log "BEGIN Import" 
/apps/omn/bin/spdci -dtb MMSC -cmd import_new $IMPORT_FILE 2>&1| tee $LOG_FILE
RC=`tail -n 5 /data/spd_import/spd_import.log | grep -ci "data imported ok"`

if [ $RC == 0 ]; then
    log "=== SPD import FAILED ==="
    send_alarm "Check Log"
    exit 255
fi

rm -rf $IMPORT_FILE
log "=== SPD import SUCCESS ==="
log "END Import" 
exit 0
