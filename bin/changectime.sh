#!/bin/sh
now=$(date +"%Y-%M-%d %T")
echo $now
#sudo date --set="Sat May 11 06:00:00 IDT 2013"
sudo date --set="$2"
chmod 644 $1
sudo date --set="$now"

#[james@nebraska Downloads]$ stat route1063408928.gpx 
#  File: ‘route1063408928.gpx’
#    Size: 38325           Blocks: 88         IO Block: 4096   regular file
#    Device: fd02h/64770d    Inode: 17755000    Links: 1
#    Access: (0644/-rw-r--r--)  Uid: (  613/   james)   Gid: (  100/   users)
#    Access: 2016-05-25 10:38:08.555644074 +0100
#    Modify: 2016-05-03 00:00:00.000000000 +0100
#    Change: 2016-05-24 12:06:15.905108436 +0100
#     Birth: -

