#!/bin/bash

# Process for photos 17/4/2016 . . . Shotwell upload to ~/Pictures/2016/04/17/ . . . ln -s 20160417Description . . . run rsync to Elements
FROM=/home/jamesc/Pictures/201[3456]
EDIR=/media/jamesc/Elements/GreenSpaceMultimedia/FamilyPhotos/AllPictures
#james-laptop:/media/jamesc/Elements/GreenSpaceMultimedia/FamilyPhotos/AllPictures
rsync -avzhP $FROM $EDIR

