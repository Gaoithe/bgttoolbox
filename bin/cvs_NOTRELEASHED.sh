#!/bin/bash

# show files, version date commit comment from last tag
# usage e.g. ~/bin/cvs_NOTRELEASHED.sh tc_qa tc_qa/lib v1-01-59 v1-01-60

MODULE=tc_qa
CHECK=tc_qa/lib/CHANGES
NEXT_TAG=HEAD
[[ ! -z $1 ]] && MODULE=$1
[[ ! -z $2 ]] && CHECK=$2
if [[ ! -z $3 ]] ; then
    LATEST_TAG=$3
else
    LATEST_TAG=$(cvs rlog $CHECK |grep -A1 "^symbolic names:" |head -2 |grep -v "^symbolic names:"|sed "s/[ \t]//;s/:.*//")
fi
[[ ! -z $4 ]] && NEXT_TAG=$4

echo "FROM $LATEST_TAG to $NEXT_TAG"
# v1-01-46
cvs rlog -r${LATEST_TAG}::$NEXT_TAG $MODULE 2>&1 |grep "no revision" |sed "s/.* no revision/NEW FILE ADDED/"
cvs rlog -r${LATEST_TAG}::$NEXT_TAG $MODULE 2>/dev/null |grep -A1 -E "^RCS file:|^revision |date: |no revision" |grep -Ev "^head: |^--$" |grep -Ev "^add system test scripts dir|cvs rlog: Logging"|grep -B1 -A2 "^revision "

