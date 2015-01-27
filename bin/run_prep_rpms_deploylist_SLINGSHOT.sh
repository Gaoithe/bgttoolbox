# in build area prepare deploylist.txt and copy rpms to 

# see also notes_bluesky_gandhi, notes_building.txt, notes_garv_vb-27..., ~/notes_gui_crash

TCBASE=/slingshot

#perl $TCBASE/MOS-base/scripts/deploylist.pl -fc9 $TCBASE/deployments/OMN-Traffic-Control >deploylist.txt
#FILES=$(cat deploylist.txt)
perl $TCBASE/MOS-base/LATEST/scripts/deploylist.pl -fc9 $TCBASE/deployments/OMN-Traffic-Control/LATEST >deploylist_SLINGSHOT.txt

cp -p deploylist_SLINGSHOT.txt /scratch/james/RPMS/rpms_cobwebs/
