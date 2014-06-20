#!/bin/bash

cd mmp3
echo "streamripper $* " |tee -a ~/call_streamripper.log
echo "streamripper http://www.monkeymagic.org$1 " |tee -a ~/call_streamripper.log
streamripper http://www.monkeymagic.org$1 
exit

echo " 0 $0 1 $1 " |tee -a ~/showcmdline.log
echo "hash $# star $* at $@"  |tee -a ~/showcmdline.log

i=0
while [[ "$1" != "" ]] ; do
  ((i++))
  echo "p $i is '$1'" |tee -a ~/showcmdline.log
  shift
done

