
for f in $*; do n=${f%%.ogg}; if [[ ! -e "$n.wav" ]] ; then ffmpeg -i "$f" "$n.wav"; fi; done
