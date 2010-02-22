# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
# yeah, ubuntu jaunty ffmpeg works for some amr to ogg but not all. Hmm. 
for F in *.amr ; do echo F=$F; N=${F%%.amr}; if [[ ! -e $N.ogg ]] ; then ffmpeg-amr -i "$F" "$N.ogg"; fi; done
