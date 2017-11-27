#!/bin/bash -ex

ARGS=" -rt -skip_docker_load_unless"
ROLLINGTHUNDERARGS="-profile qa -rollback never -p ContTypeSeq@STOD,DTOD -p /Timeout/Delete@60 -p /Timeout/HealthCheck/STOD@60 -p /Timeout/HealthCheck/DTOD@60"
#ARGS+=" -rtargs \"$ROLLINGTHUNDERARGS\""

echo CALL: ~/bin/testargs2.sh $ARGS
~/bin/testargs2.sh $ARGS -rtargs "$ROLLINGTHUNDERARGS"

