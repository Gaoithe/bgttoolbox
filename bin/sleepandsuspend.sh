#!/bin/bash

# to run it optionally give it amount of seconds to wait
# e.g. two hours 7200, e.g. 10 mins 600
echo e.g. invoke: sudo ~/bin/sleepandsuspend.sh 7200

[[ "$USER" != "root" ]] && echo must run this as root. && exit 0;

SLEEP=3600
[[ "$1" != "" ]] && SLEEP=$1

which pm-suspend
[[ "$?" != 0 ]] && echo "Oh dear, I cannot run pm-suspend. This script will not work :-7"

echo will suspend after sleep=$SLEEP secs. USER=$USER
sleep $SLEEP && pm-suspend
# pmi action suspend

