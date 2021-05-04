#!/bin/bash

#root@james-laptop:~# mount /dev/sdb1 /media/usb/
#The disk contains an unclean file system (0, 0).
#The file system wasn't safely closed on Windows. Fixing.
#root@james-laptop:~# ls /media/usb/
#2016                                              FloppyDaffCountandSharkFishHidingInThere  $RECYCLE.BIN  System Volume Information
#CobhColemansWindowsXPFamilyTreePassworddairygold  GreenSpaceMultimedia                      RECYCLER
#root@james-laptop:~# ln -sf /media/usb /media/jamesc/Elements
#root@james-laptop:~# mount |grep sdb1
#/dev/sdb1 on /media/usb type fuseblk (rw,nosuid,nodev,allow_other,blksize=4096)


# # .. # # .. # #
#            --remove-source-files   sender removes synchronized files (non-dir)
#            --del                   an alias for --delete-during
#            --delete                delete extraneous files from dest dirs


# Process for photos 17/4/2016 . . . Shotwell upload to ~/Pictures/2016/04/17/ . . . ln -s 20160417Description . . . run rsync to Elements
FROM=/home/jamesc/Pictures/201[3456789]*
#FROM=/home/jamesc/Pictures/2017
EDIR=/media/jamesc/Elements1/GreenSpaceMultimedia/FamilyPhotos/AllPictures
#james-laptop:/media/jamesc/Elements/GreenSpaceMultimedia/FamilyPhotos/AllPictures
#rsync -avzhP $FROM $EDIR
#rsync -avzhP --include=*.mp4 --remove-source-files  $FROM $EDIR

FROM=/home/jamesc/Pictures/201[78]*
EDIR=/media/jamesc/Elements1/GreenSpaceMultimedia/FamilyPhotos/AllPictures
rsync -avzhP --include=*.mp4 --remove-source-files  $FROM $EDIR

FROM=/home/jamesc/Pictures/201[9]*
EDIR=/media/jamesc/Elements1/GreenSpaceMultimedia/FamilyPhotos/AllPictures
rsync -avzhP --include=*.mp4 $FROM $EDIR

#FROM=/home/jamesc/Pictures/201[3456789]*
#rsync -avzhP --include=*.mp4 $FROM $EDIR
