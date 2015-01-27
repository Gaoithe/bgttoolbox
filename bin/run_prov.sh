#!/bin/bash
scp ~/bin/run_provision_TC.sh omn@vb-28:scripts/
ssh omn@vb-28 /apps/omn/scripts/run_provision_TC.sh |tee -a TC_provision.log; 
#ssh omn@vb-28 sbug_session -cmd enable -path corrib_router/cobwebs -level 3 -verbose
