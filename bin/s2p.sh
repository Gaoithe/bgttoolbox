#!/bin/sh

# print help
print_help() {
   echo "Usage: s2p.sh <INPUT_RAW_SS7_PDU_LOG> <OUTPUT_CAPTURE_FILE>"
   exit 0
}

# check commandline arguments
[ ! -e $1 ] && echo "ERROR: Input file \"$1\" does not exists" && print_help && exit 1
[ ! "${2}" ]  && echo "ERROR: Output capture file is not set" && print_help && exit 1

# check text2pcap routine ( included in Wireshark rpm )
type -P text2pcap &>/dev/null  && continue  || { echo "text2pcap command not found."; exit 1; } 

# define temporary file
TMP_FILE='/tmp/s2p.tmp'
[ -f $TMP_FILE ] && rm -f $TMP_FILE

# read the input file line by line and prepare ASCII file for text2pcap
while read line
do
  arr=(`echo $line | tr "\ " "\ "`)
  echo ${arr[0]} 000 `echo ${arr[3]} | sed "s/\(\[\|\]\)//g" | sed "s/\(..\)/\1\ /g"` >> $TMP_FILE
done < $1
  
# call text2pcap to translate the temporary ASCII file to a capture file
text2pcap -q -l 155 -t "%d/%m/%Y-%H:%M:%S." $TMP_FILE $2

# delete the temporary file
rm -f $TMP_FILE

exit 0
