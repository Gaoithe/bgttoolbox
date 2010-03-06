#!/bin/bash

#INVOCATION:
#$ bt-sync-mobile.sh [device [dir]]
#$ bt-sync-mobile.sh Pooky 'C:\Data\Images\' 2>&1 |tee .btsync/bt_sync_images.log 
#Stuff is synched to ~/.btsync/`echo $dir |sed 's/[\/ \\"]/_/g'`
#wami*.gpx and *.jpg files are cleared off device if synced successfully and mp4 or png
#
#REQUIREMENTS: 
#linux with bluetooth hardware
#various bluetooth linux utils, these ubuntu packages:
#bluez bluez-utils(?) obexftp openobex-apps
#
# some of these come by default, and some are not needed, but this is on the system the script was tested on
#$ dpkg -l |egrep "bluez|hci|obex" |sed 's/  */ /g'
#ii bluez 4.32-0ubuntu4.1 Bluetooth tools and daemons
#ii bluez-alsa 4.32-0ubuntu4.1 Bluetooth audio support
#ii bluez-cups 4.32-0ubuntu4.1 Bluetooth printer driver for CUPS
#ii bluez-gnome 1.8-0ubuntu5 Bluetooth utilities for GNOME
#ii bluez-gstreamer 4.32-0ubuntu4.1 Bluetooth gstreamer support
#ii bluez-utils 4.32-0ubuntu4.1 Transitional package
#ii gnome-vfs-obexftp 0.4-1build1 GNOME VFS module for OBEX FTP
#ii libopenobex1 1.5-1 OBEX protocol library
#ii libopenobex1-dev 1.5-1 OBEX protocol library - development files
#ii obex-data-server 0.4.4-0ubuntu1 D-Bus service for OBEX client and server sid
#ii obexftp 0.19-7ubuntu2 file transfer utility for devices that use t
#ii openobex-apps 1.5-1 Applications for OpenOBEX
#ii python-bluez 0.16-1ubuntu1 Python wrappers around BlueZ for rapid bluet
#
#NOTES:
#The bluetooth connect seems to fail sometimes.
#Files with funny chars in name could cause a problem. maybe. () are okay
#Files to clear out are hardcoded.
#It's simple - just syncs files up if they don't exist on host.
#There are various other TODOs
# 
### TODO: hey look at Images\_PAlbTN\ dir ! every thumbnail since year DOT! sneaky !
# nokia E65 phone
#
#I've thrown together an ugly script to automate sync (a dumb enough sync) of files from my phone.
#And made an ugly blog post about the ugly script also:
#http://gaoithe.livejournal.com/33541.html
#
#It would be nice to sync properly like rsync (i.e. check files size and date/times on host and device).
#It would be nice to use rsync itself! :)
#Possibly obexftp could be improved, commands like "get-if-changed, put-if-not-up-to-date", recursive ability.
#Hmm. Hmm.
#mount could mount some ugly thing + obexftp interface?   then rsync away
# Hmmm.
#
# 14/11/2009 Fix allow spaces in file names.
#     probably also allow spaces in dirs and device name
#     for F in *.amr ; do echo F=$F; done
#     for F in *.amr ; do echo F=$F; N=${F%%.amr}; if [[ ! -e $N.ogg ]] ; then ffmpeg -i $F $N.ogg; fi; done
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
# for F in *.amr ; do echo F=$F; N=${F%%.amr}; if [[ ! -e $N.ogg ]] ; then ffmpeg-amr -i "$F" "$N.ogg"; fi; done
#
# f=Sound\ clip\(10\).ogg; n=${f%%.amr}; mv "$f" "${n}_DragonSoup.ogg"
# for f in DataSoundsDigital/Sound\ clip\({1,2}*\).ogg; do vlc "$f"; done 
# for f in DataSoundsDigital/Sound\ clip\({1*,20,21,22,23}\).ogg; do n=${f%%.ogg}; mv "$f" "${n}_DragonSoup.ogg"; done 
# 
# for f in DataSoundsDigital/Sound\ clip\(*\).ogg; do vlc "$f"; done 
# for f in *.flv; do n=${f%%.flv}; if [[ ! -e "$n.wav" ]] ; then ffmpeg -i "$f" "$n.wav"; fi; done



# TODO: if match ^- option parse
# -n - do nothing
# -v - verbose
# -c - clean files after
while [[ "${1#-}" != "$1" ]] ; do
    [ "$1" == "-n" ] && OPTS_DONOTHING="$1";
    [ "$1" == "-v" ] && OPTS_VERBOSE="$1";
    [ "$1" == "-c" ] && OPTS_CLEAN="$1";
    shift
done

#[ "$OPTS_DONOTHING" != "" ] && echo "optn";
#[ "$OPTS_DONOTHING" == "" ] && echo "not optn";

DEVICENAME="$1"
#echo all is $*
BTSYNCHOME=~/.btsync

# DEVICENAME can be blank (scans all devices)
HCISCAN=`hcitool scan |grep "$DEVICENAME" |grep -v ^Scanning `
#Scanning ...
#	00:1F:5D:BF:29:39	Nokia 3120 fionnuala
#	00:17:E5:EE:29:18	Pooky
#check for duplicates
DEVCOUNT=`echo "$HCISCAN" |wc -l`
HCISCAN_S=`echo "$HCISCAN" |sed 's/[\t ][\t ]*/ /g;s/^ *//;'`
BTADDR=`echo "$HCISCAN_S" |cut -d' ' -f1`
DEVNAME=`echo "$HCISCAN_S" |cut -d' ' -f2-`

#echo "DEVCOUNT=$DEVCOUNT HCISCAN=$HCISCAN 
#BTADDR=$BTADDR DEVNAME=$DEVNAME"

if [[ $DEVCOUNT -ne 1 ]] ; then
    echo "usage: $0 [<opts>] <devicename>  <dir_to_sync>
  e.g. $0 42:54:41:44:44:52 \"C:/Data/\"
Which device?
$HCISCAN
options:
  -n - do nothing
  -v - verbose
  -c - clean files after
"
    exit;
fi

echo "BTADDR=$BTADDR DEVNAME=$DEVNAME"
#sudo hcitool info $BTADDR

DIRTOSYNC="$2"
# DONE pass in dir/file to sync on cmd line in $2
if [[ -z $DIRTOSYNC ]] ; then
    echo "usage: $0 [<opts>] <devicename>  <dir_to_sync>
  e.g. $0 42:54:41:44:44:52 \"C:/Data/\"
  e.g. $0 \$BTADDR \"C:/Data/Images/\"
  e.g. $0 $BTADDR \"C:/Data/Videos/\"
  e.g. $0 42:54:41:44:44:52 \"C:/Data/Sounds/\"
options:
  -n - do nothing
  -v - verbose
  -c - clean files after
"
    DIRTOSYNC="C:/Data/"
    #exit;
fi

mkdir -p $BTSYNCHOME

DIRTOSYNC_HASH=`echo "$DIRTOSYNC" |sed 's/[\/ \\"]/_/g'`
# cd to where we are getting files
mkdir -p $BTSYNCHOME/$DIRTOSYNC_HASH
cd /tmp
cd  $BTSYNCHOME/$DIRTOSYNC_HASH
pwd

#obexftp -b $BTADDR -v -l ""
#obexftp -b $BTADDR -v -l "C:/"
echo DIRTOSYNC=$DIRTOSYNC DIRTOSYNC_HASH=$DIRTOSYNC_HASH
obexftp -b $BTADDR -v -l "$DIRTOSYNC" |tee $BTSYNCHOME/$DIRTOSYNC_HASH.list




echo get list of all files
echo TODO: parse xml safely/properly
# <folder name="whereami" modified="20080825T144716Z" user-perm="RWD" mem-type="DEV"/>
#  <file name="CapsOff.sisx" size="25568" modified="20080331T131250Z" user-perm="RWD"/>
#FILES=$(grep "<file name=" $BTSYNCHOME/$DIRTOSYNC_HASH.list |cut -d'"' -f2 `)
FILES=$(grep "<file name=" $BTSYNCHOME/$DIRTOSYNC_HASH.list |sed 's/.*name="//;s/" .*//;s/ /_SPACE_/g')

date >> $BTSYNCHOME/$DIRTOSYNC_HASH.log
echo FILES=$FILES |tee -a $BTSYNCHOME/$DIRTOSYNC_HASH.log


## forget about first retrieve or not, just check files on each system
#if [[ -f $BTSYNCHOME/$DIRTOSYNC_HASH.success ]] ; then
#echo for second/.. retrieve just get differences

echo TODO: recurse into directories
 
echo TODO get updated files, now we get new files only


function wipe_existing_files_from_list () { 
    echo for now we check if file exists already and wipe from list
    ##file list to retrieve by eliminating ones already retrieved
    FILESTOGET=
    for F in $FILES ; do
        F2=$(echo $F|sed 's/_SPACE_/ /g')
        if [ "$OPTS_VERBOSE" != "" ] ; then
            echo F $F F2 $F2
        fi
        if [[ ! -f $F && ! -f $F2 ]] ; then
            FILESTOGET="$FILESTOGET $F"
        fi
    done   
    FILES="$FILESTOGET"
#diff $BTSYNCHOME/$DIRTOSYNC_HASH $BTSYNCHOME/$DIRTOSYNC_HASH.success
#mv $BTSYNCHOME/$DIRTOSYNC_HASH $BTSYNCHOME/$DIRTOSYNC_HASH.success
}

function get_the_files () {
    if [[ ! -z $FILES ]] ; then 
        echo get the files
        date >> $BTSYNCHOME/$DIRTOSYNC_HASH.get
        SP_Q=$(echo $FILES|grep _SPACE_)
        if [[ "$SP_Q" != "" ]] ; then
            # spaces in file names so must do them induhvidually
            for F in $FILES; do 
                F=$(echo $F|sed 's/_SPACE_/ /g')
                echo "obexftp get $F"
                echo obexftp -b $BTADDR -v -c \"$DIRTOSYNC\" -g \"$F\"
                obexftp -b $BTADDR -v -c "$DIRTOSYNC" -g "$F" |tee -a $BTSYNCHOME/$DIRTOSYNC_HASH.get
            done 
        else
            echo "obexftp get $FILES"
            echo obexftp -b $BTADDR -v -c \"$DIRTOSYNC\" -g $FILES
            obexftp -b $BTADDR -v -c "$DIRTOSYNC" -g $FILES |tee -a $BTSYNCHOME/$DIRTOSYNC_HASH.get
        fi
  
        # can obexftp do a dir? would be handy.
        #obexftp -b $BTADDR -v -g "$DIRTOSYNC" |tee $BTSYNCHOME/$DIRTOSYNC_HASH.getdir
        # also -G (get and delete) could be used for some files
    fi
}



# TODO/half DONE track and check each file seperately
# TODO maybe if we got the file, store the associated line then in .success file
# use size/date in xml and  on file system.
# ideally we want commands: GET[and remove] if newer/different

function track_the_files () { 
#CHECKFILES=`echo $FILES |sed 's/ / && -f /g'`
#if [[ $CHECKFILES ]] ; then
#   mv $BTSYNCHOME/$DIRTOSYNC_HASH $BTSYNCHOME/$DIRTOSYNC_HASH.success
    date >> $BTSYNCHOME/$DIRTOSYNC_HASH.success
    for F in $FILES ; do
        F=$(echo $F|sed 's/_SPACE_/ /g')
        if [[ -f $F ]] ; then
            # a file name which is part of others will cause problems 
            FILEINFO=`grep "<file name=" $BTSYNCHOME/$DIRTOSYNC_HASH.list |grep $F`
            echo "$FILEINFO" >> $BTSYNCHOME/$DIRTOSYNC_HASH.success
        fi
    done
}


## TODO cleanup all files  on mobile retrieved this time or previous
##   allows syncing as soon as possible but cleaning after longer (keep recent photos, traces, ...) 

# cleanup files matching certain patterns on mobile if they were successfully retrieved
# we could use -G earlier (get and delete)
function clean_the_files () { 
    for F in $FILES ; do
        F=$(echo $F|sed 's/_SPACE_/ /g')
###if [[ -f bin/eirkey.pl && ( -n ${FG#wami-2} || -n ${F%gpx} ) ]] ; then echo yep; fi
        
        if [[ -f $F && ( -n ${F#wami-2*.gpx} || -n ${F#*.jpg} || -n ${F#*.mp4} || -n ${F#*.png} ) ]] ; then
            obexftp -b $BTADDR -v -c "$DIRTOSYNC" -k $F |tee -a $BTSYNCHOME/$DIRTOSYNC_HASH.clean
        fi
    done
}




wipe_existing_files_from_list
echo "files to get FILES=$FILES"

if [ "$OPTS_DONOTHING" == "" ] ; then

  get_the_files

  track_the_files

  if [ "$OPTS_CLEAN" != "" ] ; then

    clean_the_files

  fi

fi
