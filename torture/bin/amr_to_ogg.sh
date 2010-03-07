# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
# yeah, ubuntu jaunty ffmpeg works for some amr to ogg but not all. Hmm. 

# default out format is ogg
OFORMAT=ogg
while [[ "${1#-}" != "$1" ]] ; do
    [ "$1" == "-n" ] && OPTS_DONOTHING="$1";
    [ "$1" == "-v" ] && OPTS_VERBOSE="$1";
    [ "$1" == "-a" ] && OPTS_ALWAYS="$1";
    [ "$1" == "-f" ] && { OPTS_FORMAT="$1"; shift; OFORMAT="$1";}
    shift
done

FFAUDOPTS="-ar 8000 -ab 12.2k -ac 1"
# -ar 1000, much smaller size, squeaky/fast playing
# -ab 6000 or 1000 no difference in size, playing quality seems unchanged
# see below comments/notes on sizing files, ffmpeg options for ogg output, ...
while [[ "$1" != "" ]] ; do
  for F in $1 ; do 
    echo F=$F; N=${F%%.amr}; 
    if [[ "$OPTS_ALWAYS" != ""|| ! -e "$N.${OFORMAT}" ]] ; then 
      ffmpeg-amr -i "$F" -y "$N_inter.${OFORMAT}"; 
      /usr/bin/ffmpeg -i "$N_inter.${OFORMAT}" -y -acodec vorbis -ac 2 "$N.${OFORMAT}";
      rm "$N_inter.${OFORMAT}"
    fi; 
  done
  shift
done

#for F in *.amr ; do echo F=$F; N=${F%%.amr}; if [[ ! -e $N.ogg ]] ; then ffmpeg-amr -i "$F" "$N.ogg"; fi; done


# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-06 23:12 MyFairLady_marr.jam.ogg
# 136 -rw-r--r-- 1 jamesc jamesc   134228 2010-03-06 23:12 MyFairLady_marr_jam.ogg
#  88 -rw-r--r-- 1 jamesc jamesc    85896 2010-03-06 23:12 MyFairLady_marr.hail.ogg
# 104 -rw-r--r-- 1 jamesc jamesc   101093 2010-03-06 23:12 MyFairLady_marr.end.ogg
# 108 -rw-r--r-- 1 jamesc jamesc   106151 2010-03-06 23:12 MyFairLady_loverlyStart.liam.ogg
# 132 -rw-r--r-- 1 jamesc jamesc   128798 2010-03-06 23:12 MyFairLady_loverlyStart.jam.ogg
# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-06 23:20 MyFairLady_marr.jam_ar8000ab12.2ac1.ogg
#  56 -rw-r--r-- 1 jamesc jamesc    50213 2010-03-06 23:21 MyFairLady_marr.jam_ar1000ab12.2ac1.ogg
# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-06 23:29 MyFairLady_marr.jam_ar8000ab6000ac1.ogg
# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-06 23:31 MyFairLady_marr.jam_ar8000ab1000ac1.ogg
#jamesc@jamesc-laptop:~/Music/mobilePhone/DataSoundsDigital$ history |tail
#  535  FFAUDOPTS="-ar 8000 -ab 1000 -ac 1"
#  536  ffmpeg-amr -i "$F" $FFAUDOPTS ${N}_ar8000ab1000ac1.ogg
#  537  mplayer MyFairLady_marr.jam_ar8000ab1000ac1.ogg
#  538  ls -alstr



# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-06 23:50 MyFairLady_marr.jam_vorvn.ogg
#jamesc@jamesc-laptop:~/Music/mobilePhone/DataSoundsDigital$ ffmpeg-amr -i "$F" -vn -sameq ${N}_vorvn.ogg
#       -vn Disable video recording.
## CHIPMUNKS:
#ffmpeg-amr -i "$F" -vn -ar 4000 -ab 2 -aq 0 -v 5 -y  ${N}_aq0.ogg




# it uses FLAC (mad) by default, that's lossless.  BIG output files.
# to get to ogg + vorbis inside (instead of ogg + flac)
#  785  ffmpeg-amr -i MyFairLady_marr.jam.amr -y ${N}_vorb.ogg
#  790  /usr/bin/ffmpeg -i MyFairLady_marr.jam_vorb.ogg -y -acodec vorbis -ac 2 ${N}_vorb_VORB.ogg
#  791  ls -alstr
# 388 -rw-r--r-- 1 jamesc jamesc   392814 2010-03-07 01:11 MyFairLady_marr.jam_vorb.ogg
#  72 -rw-r--r-- 1 jamesc jamesc    65770 2010-03-07 01:13 MyFairLady_marr.jam_vorb_VORB.ogg
#  792  mplayer MyFairLady_marr.jam_vorb_VORB.ogg


# jamesc@jamesc-laptop:~/Music/mobilePhone/DataSoundsDigital$ mplayer MyFairLady_marr.jam_aq0.ogg
# MPlayer 1.0rc2-4.3.3 (C) 2000-2007 MPlayer Team
# CPU: Genuine Intel(R) CPU           T2500  @ 2.00GHz (Family: 6, Model: 14, Stepping: 8)
# CPUflags:  MMX: 1 MMX2: 1 3DNow: 0 3DNow2: 0 SSE: 1 SSE2: 1
# Compiled with runtime CPU detection.
# mplayer: could not connect to socket
# mplayer: No such file or directory
# Failed to open LIRC support. You will not be able to use your remote control.
# 
# Playing MyFairLady_marr.jam_aq0.ogg.
# [Ogg] stream 0: audio (FLAC, try 2), -aid 0
# Ogg file format detected.
# ==========================================================================
# Forced audio codec: mad
# Opening audio decoder: [ffmpeg] FFmpeg/libavcodec audio decoders
# AUDIO: 1000 Hz, 1 ch, s16le, 0.0 kbit/0.00% (ratio: 0->2000)
# Selected audio codec: [ffflac] afm: ffmpeg (FFmpeg FLAC audio decoder)
# ==========================================================================
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# AO: [pulse] Failed to connect to server: Connection refused
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# AO: [alsa] 48000Hz 1ch s16le (2 bytes per sample)
# Video: no video
# Starting playback...
# A:  -1.1 (unknown) of inf (-24.-8)  0.1% 8.00x 
# 
# Exiting... (End of file)
# 
# 
# jamesc@jamesc-laptop:~/Music/mobilePhone/DataSoundsDigital$ mplayer MyFairLady_marr.jam_vorb.ogg
# MPlayer 1.0rc2-4.3.3 (C) 2000-2007 MPlayer Team
# CPU: Genuine Intel(R) CPU           T2500  @ 2.00GHz (Family: 6, Model: 14, Stepping: 8)
# CPUflags:  MMX: 1 MMX2: 1 3DNow: 0 3DNow2: 0 SSE: 1 SSE2: 1
# Compiled with runtime CPU detection.
# mplayer: could not connect to socket
# mplayer: No such file or directory
# Failed to open LIRC support. You will not be able to use your remote control.
# 
# Playing MyFairLady_marr.jam_vorb.ogg.
# [Ogg] stream 0: audio (FLAC, try 2), -aid 0
# Ogg file format detected.
# ==========================================================================
# Forced audio codec: mad
# Opening audio decoder: [ffmpeg] FFmpeg/libavcodec audio decoders
# AUDIO: 8000 Hz, 1 ch, s16le, 0.0 kbit/0.00% (ratio: 0->16000)
# Selected audio codec: [ffflac] afm: ffmpeg (FFmpeg FLAC audio decoder)
# ==========================================================================
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# AO: [pulse] Failed to connect to server: Connection refused
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# AO: [alsa] 48000Hz 1ch s16le (2 bytes per sample)
# Video: no video
# Starting playback...
# A:  -0.2 (unknown) of inf (-24.-8)  0.6% 
# 
# 
# 
# 
# 
# jamesc@jamesc-laptop:~/Music/mobilePhone/DataSoundsDigital$ mplayer MyFairLady_marr.jam_vorb_VORB.ogg
# MPlayer 1.0rc2-4.3.3 (C) 2000-2007 MPlayer Team
# CPU: Genuine Intel(R) CPU           T2500  @ 2.00GHz (Family: 6, Model: 14, Stepping: 8)
# CPUflags:  MMX: 1 MMX2: 1 3DNow: 0 3DNow2: 0 SSE: 1 SSE2: 1
# Compiled with runtime CPU detection.
# mplayer: could not connect to socket
# mplayer: No such file or directory
# Failed to open LIRC support. You will not be able to use your remote control.
# 
# Playing MyFairLady_marr.jam_vorb_VORB.ogg.
# [Ogg] stream 0: audio (Vorbis), -aid 0
# Ogg file format detected.
# ==========================================================================
# Forced audio codec: mad
# Opening audio decoder: [ffmpeg] FFmpeg/libavcodec audio decoders
# AUDIO: 8000 Hz, 2 ch, s16le, 0.0 kbit/0.00% (ratio: 0->32000)
# Selected audio codec: [ffvorbis] afm: ffmpeg (FFmpeg Vorbis decoder)
# ==========================================================================
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# E: context.c: waitpid(): No child processes
# AO: [pulse] Failed to connect to server: Internal error
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# I: caps.c: Dropping root privileges.
# I: caps.c: Limited capabilities successfully to CAP_SYS_NICE.
# AO: [alsa] 48000Hz 2ch s16le (2 bytes per sample)
# Video: no video
# Starting playback...
# A:   1.2 (01.1) of 37.9 (37.8)  1.2% 
# 
# MPlayer interrupted by signal 2 in module: play_audio
# 