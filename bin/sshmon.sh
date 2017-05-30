#!/bin/bash
# e.g. usage ~/bin/sshmon.sh bob@as7builder-x64 "ls -alstr build_area |tail"
while true; do 
    OUT=$(ssh $1 $2)
    if [[ $OUT != $OLDOUT ]] ; then
        date
        echo "$OUT"
        OLDOUT="$OUT"
        ((idle=0))
    else
        ((idle++))
    fi
    if (( $idle > 20 && ( $idle % 20 == 0 ) )) ; then
        echo "WARNING: idle=$idle"
    fi
    sleep 10
done
