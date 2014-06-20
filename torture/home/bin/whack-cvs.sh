#!/bin/bash

# DANGER WILL ROBINSON! DANGER! All your base is belong to us!
echo DANGER WILL ROBINSON! DANGER! All your base is belong to us!

if [[ "$1" == "" ]] ; then
  # TODO get dir list from a config, for now one dir only
  whackdir=~/checkedout/netledge
fi


if [[ -d $1 ]] ; then 
  whackdir=$1
else
  echo "usage: $0 <cvsdirtowhack>"
  exit
fi

ts=`date +"%Y%m%d-%H%M"`
bindir=~/tmp/
mkdir -p $bindir

cd $whackdir
echo cd $whackdir >$bindir/whackem.sh
cvs -nq up -d -P |grep "^[MC] " |sed "s/^[MCA]/rm /g" >>$bindir/whackem.sh

chmod 755 $bindir/whackem.sh
$bindir/whackem.sh

cvs up -d -P