
# TODO: tool to convert files and transfer to zen
# youtube url -> download -> convert -> Zen/Videos(or queued for Zen)

# Script invoked from Gnome gui:
# * drag and drop URL or files in, 
# * in gnome menus right-click and  select to_zen.sh

# use perl probably ... tool getting a bit more complex than simple

# unage to_zen.sh, drop file in nautilus => ... ? nothing?

PID=$$
LOG=/tmp/to_zen_$PID.log
echo "pwd: "$(pwd) >> $LOG
echo "0: $0" >> $LOG

while [[ "$1" != "" ]] ; do
  echo "v: $1"
  shift
done

export >> $LOG

##for f in *.flv; do n=${f%%.flv}; if [[ ! -e "$n.avi" ]] ; then ffmpeg -i "$f" "$n.avi"; fi; done

#FILE=$1
#/usr/bin/ffmpeg -i $FILE -s 320x240 -acodec libmp3lame -vcodec mpeg4 -vtag XVID -b 500k -ab 320k ${FILE%%.flv}.avi
#cp ${FILE%%.flv}.avi /mnt/Zen-Xfi/Video/

