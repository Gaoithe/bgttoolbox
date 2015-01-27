#!/bin/bash

while true; do
  ACI=$(aci |grep -i wassa)
  if [[ "$ACI" != "$OLDACI" ]] ; then
    date |tee -a aci_mon.log
    echo $ACI |tee -a aci_mon.log
  fi
  OLDACI="$ACI"
  sleep 1
done

