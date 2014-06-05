# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
for F in *.mp3 ; do echo F=$F; N=${F%%.mp3}; if [[ ! -e $N.ogg ]] ; then ffmpeg -i "$F" "$N.ogg"; fi; done
