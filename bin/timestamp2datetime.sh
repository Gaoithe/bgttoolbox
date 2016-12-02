#!/bin/bash
# python>>> time.ctime(1479217225)

# datetime 2 timestamp:
#date -d "2016/01/26 19:53:26" +%s

# timestamp 2 datetime:
ts=$1
date -d @$ts
