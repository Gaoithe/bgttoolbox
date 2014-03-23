

for f in $*; do n=${f%%.mp3}; if [[ ! -e "$n.wav" ]] ; then ffmpeg -i "$f" "$n.wav"; fi; done
