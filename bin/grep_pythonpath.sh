#!/bin/bash
ACTION="grep routing_table"
[[ ! -z $1 ]] && ACTION=$1
for d in $(echo $PYTHONPATH |sed "s/:/ /g"); do 
    find $d -type f -exec $THING {} + 2>/dev/null; 
done
