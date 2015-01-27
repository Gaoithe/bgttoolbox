#!/bin/bash
value=`/bin/grep "^\s*mystring:" mytextfile`
echo "found: [$value]" >> myoutput.log

