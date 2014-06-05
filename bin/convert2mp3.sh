#!/bin/bash

if [ "$1" = "" ] ; then
  echo 'usage: $0 <sound file(s)>'
  exit 1
fi

echo all is $*

for f in "$*"
do
  if [ -f "$f" ]; then
    name=`echo "$f"|sed -e "s/.[^.]*$//"`
    echo processing file $f, to ${name}.{wav,mp3,ogg}
    file "$f"
    #rm -f "${name}.wav"
    # -af volume=0,resample=44100:0:1 \
    mplayer -quiet -vo null -vc dummy \
     -ao pcm:waveheader:file="${name}.wav" "$f"
    # minimum quality -V9 and -b 32 (actually 32 minimum for .mp3)
    #lame -V0 -h -b 160 --vbr-new "${name}.wav" "${name}.mp3"
    lame -V9 -h -b 8 --vbr-new "${name}.wav" "${name}.mp3"
    oggenc "${name}.wav"
    ls -al "${name}".{wav,mp3,ogg}
    file "${name}".{wav,mp3,ogg}
fi
done

exit

# LSB should define a "this is how to trigger installs of things" standard.
# I know it has standardized on rpms ... .. . :-P
queryapt=`ls /etc/ |grep apt`
queryyum=`ls /etc/ |grep yum`
queryrpm=`ls /etc/ |grep rpm`
lsb_release -a
uname -a

#  510  mplayer -quiet -vo null -vc dummy -ao pcm:waveheader:file="Oh.wav" Oh\ *
#  512  mplayer Oh.wav 
#  513  identify Oh.wav 
#  516  file Oh.wav 
#  517  mplayer -quiet -vo null -vc dummy   -af volume=0,resample=8000:0:1  -ao pcm:waveheader:file="Oh8000.wav" Oh\ *
#  520  file Oh\ ye\ broke\ me\ cups\ .amr 
#  537  oggenc Oh.wav 
#  542  lame -V0 -h -b 160 --vbr-new input.wav output.mp3
#  543  lame -V0 -h -b 32 --vbr-new Oh.wav Oh.mp3
#  544  sudo apt-get install lame
#  545  lame -V0 -h -b 32 --vbr-new Oh.wav Oh.mp3
#  547  lame -V0 -h -b 8 --vbr-new Oh.wav Oh.mp2
#  549  lame -V0 -h -b 8 --vbr-new Oh.wav Ohxx.mp3
#  551  lame -V4 -h -b 8 --vbr-new Oh.wav Ohxx4.mp3
#  554  lame -V9 -h -b 8 --vbr-new Oh.wav Ohxx9.mp3
