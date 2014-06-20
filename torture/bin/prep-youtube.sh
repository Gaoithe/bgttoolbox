#!/bin/bash

#Bale jump videos uploading ...
#http://www.youtube.com/user/green3gg
#.mov or .mp4 format 320x240, 700-1000kbps (bitrate) ?
# http://dinsdalepiranha.wordpress.com/2007/10/16/how-to-make-a-video-for-youtube-with-linux/


function prep-youtube() {
    mencoder "$FILE" \
	-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=1000:vhq:keyint=250:threads=2:vpass=1 \
	-oac mp3lame -lameopts cbr:br=128 \
	-ffourcc XVID \
	-vf scale=320:-2,crop=320:240,expand=320:240 \
	-af resample=44100:0:0 \
	-o "$OUT"

    mencoder "$FILE" \
	-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=1000:vhq:keyint=250:threads=2:vpass=2 \
	-oac mp3lame -lameopts cbr:br=128 \
	-ffourcc XVID \
	-vf scale=320:-2,crop=320:240,expand=320:240 \
	-af resample=44100:0:0 \
	-o "$OUT"
}

# Alternatively, it's been pointed out to me that you can encode directly to .flv, (which is what youtube will turn a .avi file into) with ffmpeg (sudo apt-get install ffmpeg) as follows:

#ffmpeg -i $FILE.vob -s 320.ANW240 $FILE.flv

#m2u00663.mpg  m2u00664.mpg  m2u00665.mpg  m2u00666.mpg
FILES=`ls *.mpg`
for FILE in $FILES ; do
  echo FILE=$FILE
  file $FILE
  OUT=$FILE.youtube
  prep-youtube $FILE $OUT
done

#http://crazedmuleproductions.blogspot.com/2007/05/how-to-upload-video-to-youtube.html#
#
#The list of file types YouTube accepts are .WMV, .AVI, .MOV and .MPG. Though they do specify that
#the recommended, least problematic file type and specification is:
#- MPEG container format
#- MPEG 1 or 2 video compression
#- 320x240 resolution
#- MP3 audio
#
#The largest video you can upload is 100MB and it cannot be longer than 10 minutes.




# $file m2u00665.mpg m2u00665.mpg.youtube
# m2u00666.mpg: MPEG sequence, v2, program multiplex
# m2u00665.mpg.youtube: RIFF (little-endian) data, AVI, 320 x 240, 25.00 fps, video: XviD, audio: MPEG-1 Layer 3 (stereo, 44100 Hz)
# -rwxrwxr-x 1 finnc  parents 73170944 2008-10-13 23:48 m2u00666.mpg
# -rw-r--r-- 1 jamesc jamesc   9023178 2008-10-14 19:48 m2u00666.mpg.youtube

# jamesc@greeneagle-desktop:~/Videos/20081011VisitCobhFamilyInauguralGames-BaleJump
#
#Blue Team Family Straw Bale Jump
#
#Family Games - Bale Jumping.
#Fionnuala, Grandad, Orla, Daire, Carly, Bill and Paul pile over the Bale in 27 seconds. Maeve wisely sits this one out and observes carefully and skeptically.
#
#Family Team Straw Bale Jump
