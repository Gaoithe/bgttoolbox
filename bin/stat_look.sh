#!/bin/bash

#
#
#
#
# ps="Incoming Normal Message Requests Accepted"; psx -l -n "$ps" | while read stat; do echo $stat; psx -x -n "$ps"/"$stat" -s -1h -e 0h -total; done
for ps in "Incoming Normal Message Requests Received" "Outgoing Normal Message Requests Sent"; do
   psx -l -n "$ps" | while read stat; do echo $stat; psx -x -n "$ps"/"$stat" -s -1h -e 0h -total; done
done
