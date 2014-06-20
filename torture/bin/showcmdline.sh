#!/bin/bash

echo " 0 $0 1 $1 " |tee -a ~/showcmdline.log
echo "hash $# star $* at $@"  |tee -a ~/showcmdline.log

i=0
while [[ "$1" != "" ]] ; do
  ((i++))
  echo "p $i is '$1'" |tee -a ~/showcmdline.log
  shift
done

