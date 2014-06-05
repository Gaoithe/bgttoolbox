# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
# yeah, ubuntu jaunty ffmpeg works for some amr to ogg but not all. Hmm. 

# default out format is ogg^H^H^Hmp3
OFORMAT=ogg
FFAUDOPTS="-acodec vorbis -ac 2"
while [[ "${1#-}" != "$1" ]] ; do
    [ "$1" == "-n" ] && OPTS_DONOTHING="$1";
    [ "$1" == "-v" ] && OPTS_VERBOSE="$1";
    [ "$1" == "-a" ] && OPTS_ALWAYS="$1";
    [ "$1" == "-f" ] && { OPTS_FORMAT="$1"; shift; OFORMAT="$1"; shift; FFAUDOPTS="$1";}
    [ "$1" == "-h" ] && { echo "usage: $0 [-n] [-v] [-a] [-h] [-f ogg \"ogg_ffmpeg_opts\"] <files>"; }
    shift
done

OFORMAT1=ogg
#FFAUDOPTS="-ar 8000 -ab 12.2k -ac 1"
# -ar 1000, much smaller size, squeaky/fast playing
# -ab 6000 or 1000 no difference in size, playing quality seems unchanged
# see below comments/notes on sizing files, ffmpeg options for ogg output, ...
while [[ "$1" != "" ]] ; do
  for F in "$1" ; do 
    echo F=$F; N=${F%%.amr}; 
    if [[ "$OPTS_ALWAYS" != ""|| ! -e "$N.${OFORMAT}" ]] ; then 
      ffmpeg-amr -i "$F" -y "$N_inter.${OFORMAT1}"; 
      /usr/bin/ffmpeg -i "$N_inter.${OFORMAT1}" -y $FFAUDOPTS "$N.${OFORMAT}";
      rm "$N_inter.${OFORMAT1}"
    fi; 
  done
  shift
done

#for F in *.amr ; do echo F=$F; N=${F%%.amr}; if [[ ! -e $N.ogg ]] ; then ffmpeg-amr -i "$F" "$N.ogg"; fi; done

ogg_to_mp3.sh

