#!/bin/bash


DEST=/home/jamesc/Pictures/201611FionnOldMobilePhone/DCIM/Camera/
cd /run/user/1000/gvfs/mtp*/Intern*/DCIM
FILES=$(ls Camera/)
#echo FILES=$FILES
ls Camera/ |wc -l
for f in $FILES; do 
   echo -n $f; 
   if [[ ! -e $DEST/$f ]]; then
      # the timeout doesn't work on frozen mtp file
      # we run this full script in a while true; do ~/bin/sync_flaky_mtp.sh; sleep 1; done loop
      # and periodically visit, if stuck unlock phone, deselect MTP and select it again 
      # (to interrupt and restart MTP connection)
      # simply unplug & replug doesn't bring MTP connection back ok
      timeout 20s cp -p Camera/$f $DEST/ && rm Camera/$f && echo success; 
   else 
      echo already; 
      diff -u Camera/$f $DEST/$f
      if [[ $? == 0 ]]; then 
         rm Camera/$f && echo RM
      else
         # doing this copy on the weird files causes nasty freezy freezes.
         #cp -p Camera/$f $DEST/$f && rm Camera/$f && echo success;
         identify $DEST/$f && rm Camera/$f && echo RM
      fi
   fi; 
done

beep
