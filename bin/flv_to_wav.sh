for f in *.flv; do n=${f%%.flv}; if [[ ! -e "$n.wav" ]] ; then ffmpeg -i "$f" "$n.wav"; fi; done
