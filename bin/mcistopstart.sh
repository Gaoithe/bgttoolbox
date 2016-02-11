#!/bin/bash

# Disclaimer: This script is an example test script, it is NOT SUPPORTED for use. 
#             Use this script at your own risk.

# Usage: to do mci stop followed by mci start of various processes when installing patches

plist="reafer gummi g2c mist_sti sparta h2c q2c quasar"
plist="careca riquelme reafer dinni g2c c2g quasar"
plist=$*
[[ -z $plist ]] && echo "error: pass list of process names to script." && echo "usage: $0 reafer dinni g2c c2g quasar" && exit

bin/mci list |grep -E $(echo $plist|tr " " "|") 
for p in $plist; do
   pnames=$(bin/mci list |grep -P "\b$p\b" |awk '{print $3}')
   echo STOP and START $p === $pnames
   if [[ ! -z $pnames ]] ; then
      bin/mci stop $pnames
      sleep 2
      bin/mci list |grep -P "\b$p\b"
      bin/mci start $pnames
      bin/mci list |grep -P "\b$p\b"
   fi
done


bin/bci -listals

