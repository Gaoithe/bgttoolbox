#!/bin/bash

DTS=$(date +%Y%m%d_%H%M)
modname=$(basename $(pwd))
[[ "$USER" == "" ]] && USER=$(whoami)

tar -jcvf ../${modname}_${DTS}.tbz ../${modname}
cvs diff -u >../${modname}_${DTS}.patch
mkdir -p /scratch/${USER}/backups
cp -p ../${modname}_${DTS}.tbz ../${modname}_${DTS}.patch /scratch/${USER}/backups/

