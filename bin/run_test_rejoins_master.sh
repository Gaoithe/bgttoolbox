#!/bin/bash

while true; do
   ssh omn@vb-28 /apps/omn/scripts/run_test_rejoins.sh |tee -a test.log; 
   ssh omn@vb-48 /apps/omn/scripts/run_test_rejoins.sh |tee -a test.log;
done

