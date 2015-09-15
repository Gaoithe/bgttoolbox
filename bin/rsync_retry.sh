#!/bin/bash

# e.g. usage ~/bin/rsync_retry.sh /slingshot/PATCHES/OMN-Traffic-Control-15-Q1/v1/00/0{7,8}/RPMS/*AS6*.rpm root@dell-b-14:snapLOG/
# ./snapLOG/rsync_retry.sh ./snapLOG/*.rpm omn@192.168.102.21:/apps/software/


# ls -alstr /slingshot/PATCHES/OMN-Traffic-Control-15-Q1/v1/00/06/RPMS/



iTry=0
notdone=255
while [[ $notdone == 255 && $iTry < 2 ]] ; do
   ((iTry++))

   # -avhz .. h=humanoid, v=verbose, a=archive, z=compression
   # .. archive instructs it to maintain time_t values so even if clocks are out rsync knows the true date of each file
   #rsync -avhz --partial --progress --bwlimit=1000 -ve ssh $* 
   #rsync -avhzP --bwlimit=1000 -ve ssh $* 
   rsync -avhzP -ve ssh $* 

   notdone=${PIPESTATUS[0]}

   if [[ $notdone == 0 ]] ; then
       # success so we exit
       exit
   fi

   echo error=$notdone iTry=$iTry

done
