#!/bin/bash

# keep strace on cvp_server going over multiple restarts (sci -stop and sci -rejoin)
while true; do
  PID=$(ps -fu omn |grep "bin/cvp_server" |grep -v grep |awk '{print $2}'); strace -t -v -s 1024 -p $PID 2>&1 |tee -a atlas_cvp_server_EVENMORE_${PID}.strace
  sleep 2;
done

