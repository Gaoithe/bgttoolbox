#!/bin/bash

PIDS=$(ps -elf | grep -E '^\w+[ ]+\w+[ ]+\w+[ ]+\w+[ ]+1\b' |awk '{print $4}')

ps -fu |grep -E "^\w+\s+('$(echo $PIDS|sed "s/ /|/g")')"
ps -fu 2>&1 |grep -E "^\w+[ ]+($(echo $PIDS|sed "s/ /|/g"))\b"
