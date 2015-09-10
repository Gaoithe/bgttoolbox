#!/bin/bash

[[ ! -e /tmp/mmsc.stats ]] && bin/cstat_ci -list | grep -E "h2c.svr_conn|h2c.m_send|h2c.m_ret|qsr.messages$|mmsc.mm7_(submit|deliver)" >/tmp/mmsc.stats

for stat in `cat /tmp/mmsc.stats`; do 
   echo $stat;
   bin/cstat_ci -get $stat -1d > /tmp/$stat; 
   cat /tmp/$stat | awk '{ SUM += $2} END { print SUM }'
   rm /tmp/$stat; 
done

