
# vlc *.wav , playlist view => seg fault!!
#for F in *.ogg *.wav ; do echo vlc "$F"; done
for F in *.ogg *.wav ; do 
   vlc "$F" &
done
