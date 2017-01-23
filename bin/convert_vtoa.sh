#!/bin/bash

for f in *.mkv; do 
    # ffmpeg -i $f
    #bn=$(basename "$f")
    bn=${f%%-[A-Za-z0-9]*}
    echo bn=$bn
    if [[ ! -e "$bn.mka" ]] ; then
        echo ffmpeg -i "$f" -acodec: copy -vn "$bn.mka"
    fi
done

#    Stream #0:0(und): Video: h264 (Main), yuv420p, 640x480 [SAR 1:1 DAR 4:3], 29.97 fps, 29.97 tbr, 1k tbn, 59.94 tbc
#    Stream #0:1(eng): Audio: opus, 48000 Hz, stereo, s16 (default)
