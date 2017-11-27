#!/bin/bash

#ACTION="grep routing_table"
#[[ ! -z $1 ]] && ACTION="grep $1"
#echo ACTION=$ACTION

[[ -z $1 ]] && echo "usage: grep_pythonpath.sh <find actions> e.g. -type f -name tron_deployment_config.py  or  e.g. -type f -exec grep fuddle {} \;" && exit

for d in $(echo $PYTHONPATH |sed "s/:/ /g"); do 
    #find $d -type f -exec $THING {} + 2>/dev/null; 
    eval find $d $* 2>/dev/null; 
done

#[omn@hp-bl-06 ~]$ for d in $(echo $PYTHONPATH |sed "s/:/ /g"); do 
#>     find $d -type f -exec grep corrib.logic {} + 2>/dev/null; 
#> done
#/slingshot/corrib/bus_logic/v1/17/24/python/crb_bus_logic_config.py:CRB_BUS_CONDS_DIR_PATH = "corrib/logic"

#bash-4.2$ ./scripts/grep_pythonpath.sh -type f -name tron_deployment_config.py 
#/slingshot/deptron/OMN-Traffic-Control/v1/15/79/python/tron_deployment_config.py
