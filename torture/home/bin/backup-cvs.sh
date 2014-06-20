#!/bin/bash

if [[ "$1" == "" ]] ; then
  # TODO get dir list from a config, for now one dir only
  backupdir=~/checkedout/netledge
fi


if [[ -d $1 ]] ; then 
  backupdir=$1
else
  echo "usage: $0 <cvsdirtobackup>"
  exit
fi


ts=`date +"%Y%m%d-%H%M"`
tarfile=cvsBackup${ts}.tar
backupbindir=~/bin/backups/
mkdir -p $backupbindir

# careful. backupdir could be relative or absolute.
cd $backupdir
echo echo original DIR: `pwd` >$backupbindir/taremup.sh
#echo cd $backupdir >$backupbindir/taremup.sh
# echo touch foo >>$backupbindir/taremup.sh
# cannot tar -zrvf so just tar then gzip at end
# echo tar -cvf $tarfile foo >>$backupbindir/taremup.sh
cvs -nq up -d -P |grep "^[MCA] " |tee $backupbindir/status.txt | sed "s/^[MCA]/tar -rvf $tarfile/g" >>$backupbindir/taremup.sh

chmod 755 $backupbindir/taremup.sh
$backupbindir/taremup.sh

#tar -tvf $tarfile
gzip $tarfile
tar -ztvf $tarfile.gz
echo scp $USER@slaine:`pwd`/$tarfile.gz .
