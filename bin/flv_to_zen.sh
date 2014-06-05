

##for f in *.flv; do n=${f%%.flv}; if [[ ! -e "$n.avi" ]] ; then ffmpeg -i "$f" "$n.avi"; fi; done

FILE=$1
/usr/bin/ffmpeg -i $FILE -s 320x240 -acodec libmp3lame -vcodec mpeg4 -vtag XVID -b 500k -ab 320k ${FILE%%.flv}.avi
cp ${FILE%%.flv}.avi /mnt/Zen-Xfi/Video/

