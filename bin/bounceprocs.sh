
mci list |grep -P "c2g|reafer" 
PROCS=$(mci list |grep -P "c2g|reafer" |awk '{print $3}')

# stop start mci procs with 2 secs in between.
# codiac in list twice like in release notes.
mci list |grep -P "c2g|g2c|reafer|codiac|pinch|jim|gummi" 
PROCS=$(mci list |grep -P "c2g|g2c|reafer|codiac|pinch|jim|gummi" |awk '{print $3}')
for p in c2g g2c_{hlr,msc,sgsn,smsc} codiac pinch codiac jim gummi; do
  echo p=$p; mci list |grep $p
  PROCS=$(mci list |grep -P "$p" |awk '{print $3}')
  mci stop $PROCS
  mci start $PROCS
  sleep 2
done

sleep 5
echo DONE
mci list |grep -P "c2g|g2c|reafer|codiac|pinch|jim|gummi"



