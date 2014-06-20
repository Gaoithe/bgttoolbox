# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
for F in *.ogg ; do 
  echo F=$F;
  N=${F%%.ogg};
  if [[ ! -e $N.mp3 ]] ; then
    echo ffmpeg -i "$F" "$N.mp3"; 
    ffmpeg -i "$F" -y "$N.mp3"; 
  fi; 
done
