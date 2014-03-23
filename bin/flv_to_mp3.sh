
for f in *.flv; do n=${f%%.flv}; if [[ ! -e "$n.mp3" ]] ; then FILE=$n; /usr/bin/ffmpeg -i "$FILE.flv" -s 320x240 -acodec libmp3lame -ab 320k "${FILE%%.flv}.mp3"; fi; done

