#!/bin/sh

# for when you need to re-adjust ctime on a bunch of files
# e.g. when ctime lost by transferring from device to filesystem
# e.g. for photos, gps tracks

now=$(date +"%Y-%M-%d %T")
echo now=$now
if [[ -z $1 || -z $2 ]]; then
    echo "usage: $0 <file> <date/time>"
    echo "warning: requires sudo, temporarily sets date on machine (to past/future) so could cause trouble (e.g. if interrupted leaving date set to not now)"
    echo "warning: depends on filesystem behaviour, this works on linux/ext2"

#http://stackoverflow.com/questions/16126992/setting-changing-the-ctime-or-change-time-attribute-on-a-file/17066309#17066309
#http://askubuntu.com/questions/62492/how-can-i-change-the-date-modified-created-of-a-file

    echo "e.g. usage: get date from image meta info exif:DateTime"
    echo "     ~/bin/changectime.sh $f  $(identify -format %[exif:DateTime] goo.jpg|sed -r 's/:/-/;s/:/-/;')"
#[james@nebraska Downloads]$ identify -verbose DSC_0122.JPG  |grep -i date
#    date:create: 2015-02-13T13:18:27+00:00
#    date:modify: 2015-02-13T13:18:27+00:00
#    exif:DateTime: 2015:02:13 13:16:51
#    exif:DateTimeDigitized: 2015:02:13 13:16:51
#    exif:DateTimeOriginal: 2015:02:13 13:16:51
#    exif:GPSDateStamp: 2015:02:13

    echo "e.g. usage: get date from xml in gpx file 'Rode 10.53 km on 03/05/2016'"
    echo "     for f in route*.gpx; do echo f=$f; D=$(grep \" on \" $f|sed 's/.* on //;s/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/g'); sudo ~/bin/changectime.sh $f $D; stat $f |grep Change; done"
#[james@nebraska Downloads]$ stat route1063408928.gpx 
#  File: ‘route1063408928.gpx’
#  Size: 38325           Blocks: 88         IO Block: 4096   regular file
#Device: fd02h/64770d    Inode: 17755000    Links: 1
#Access: (0644/-rw-r--r--)  Uid: (  613/   james)   Gid: (  100/   users)
#Access: 2016-05-25 10:38:08.555644074 +0100
#Modify: 2016-05-03 00:00:00.000000000 +0100
#Change: 2016-05-24 12:06:15.905108436 +0100
# Birth: -

#Adjusting dates inside gpx files:
#for f in route*.gpx; do 
#   echo f=$f;
#   D=$(grep " on " $f|sed 's/.* on //;s/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/g');
#   echo $f $D;
#   # FIRST:
#   perl -pi -e 'undef $/; s/(trkseg.*)\n(.*trkpt.*)(\/\>)/$1\n$2><time>'$D'T08:40:00Z<\/time><\/trkpt>/m'  $f
#   # LAST trkpt
#   perl -pi -e 'undef $/; s/(trkpt.*)(\/\>)\n(?!.*trkpt)/$1><time>'$D'T09:15:00Z<\/time><\/trkpt>\n/m' $f
#done
    exit 0
fi

#sudo date --set="Sat May 11 06:00:00 IDT 2013"
sudo date --set="$2"
chmod 644 $1
sudo date --set="$now"

