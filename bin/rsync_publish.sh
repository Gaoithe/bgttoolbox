#!/bin/bash

cd ~james
rsync -avzhP mscgen_USSD_message_flows /scratch/james/
rsync -avzhP mscgen_USSD_message_flows /home/james/public_html/

# mscgen.sh toTC_PSSRwithCode_USSRwithMENU_Abort.msc
#  1004  2016-04-18 12:09:53 ls -alstr *.msc
# ls /scratch/james/mscgen_USSD_message_flows/

