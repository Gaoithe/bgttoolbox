#!/bin/bash

# https://sites.google.com/a/openmindnetworks.com/reach/tech-notes/smsc-smsr/routermissedcallnotificationfeature

# Short term stats for 1 day
# TELSTAR
bin/cstat_ci -list | grep telstar > /tmp/telstar.stats
for stat in `cat /tmp/telstar.stats`; do echo $stat; bin/cstat_ci -get $stat -1d > /tmp/$stat; done
for stat in `cat /tmp/telstar.stats`; do echo $stat; cat /tmp/$stat | awk '{ SUM += $2} END { print SUM }' ; done

# SPUTNIK
bin/cstat_ci -list | grep sputnik > /tmp/sputnik.stats
for stat in `cat /tmp/sputnik.stats`; do echo $stat; bin/cstat_ci -get $stat -1d > /tmp/$stat; done
for stat in `cat /tmp/sputnik.stats`; do echo $stat; cat /tmp/$stat | awk '{ SUM += $2} END { print SUM }' ; done
