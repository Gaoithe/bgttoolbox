#!/bin/bash

MYSQL_NAME=james_gprs
MYSQL_USER=gprs_user
MYSQL_PASS=gprs_user
#MYSQL_HOST=ares.ie.commprove.internal
#MYSQL_HOST=apollo.ie.commprove.internal
#MYSQL_HOST=localhost
MYSQL_HOST=uno.ie.commprove.internal

mysql-e () { 
    CMD="mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_NAME -e \"$1\""
    echo $CMD
    eval $CMD
}

alias mysql-first='mysql-e "select \"*\" from proc_gmmsm limit 1;"'

mysql-proc () {
    mysql-e "select count(*),proctype from proc_gmmsm group by proctype;"
}

mysql-proc-st () {
    mysql-e "select count(*),proctype,EndStatus from proc_gmmsm group by proctype,EndStatus;"
}

mysql-proc-imsi () {
    mysql-e "select ProcType,StartNsec,count(*),imsi,imei from proc_gmmsm group by imsi,imei,ProcType;"
}

mysql-imsi () { 
    mysql-e "select ProcType,EndStatus,EndParam,Startsec,(Endsec-StartSec) as time,imsi,imei 
             from proc_gmmsm where imsi='$1' order by Startsec;" 
}

mysql-noimsi () {
    mysql-e "select count(*),imei from proc_gmmsm where imei='NO IMEI' group by imei;"
    mysql-e "select count(*),imsi from proc_gmmsm where imsi='NO IMSI' group by imsi;"

    mysql-e "select count(*),imsi,imei from proc_gmmsm where imsi='NO IMSI' and imei='NO IMEI' group by imsi;"
    mysql-e "select count(*),ProcType,EndStatus,imsi,imei from proc_gmmsm where imsi='NO IMSI' and imei='NO IMEI' group by imsi,ProcType,EndStatus;"
}

#alias mysql-file='mysql-e "select ProcId,StartSec,filepos,proc_index_filename,proc_index_file_offset,proc_index_record_size from proc_gmmsm limit 10;"'
mysql-file () { 
    mysql-e "select ProcId,StartSec,filepos,proc_index_filename,
             proc_index_file_offset,proc_index_record_size 
             from proc_gmmsm limit 0$1;"
}
# :) http://slaine/cgi-bin/cgi_james?request_type=getprocmsgs&iface=iups&procid=948030
# mysql -h ares.ie.commprove.internal -u gprs_user -pgprs_user gprs -e "select ProcType,EndStatus,EndParam,Startsec,(Endsec-StartSec) as time,imsi,imei from proc_gmmsm limit 1000;"

mysql-var () {
   V=$1
   if [[ $V == "" ]]; then
       V="%"
   fi 
   echo $V
}

mysql-detail () {
    PT=`mysql-var ${1+"$@"}`
    ES=`mysql-var ${2+"$@"}`
    mysql-e "select ProcType, ProcDir, hex(ProcId), StartSec, StartNsec, EndSec, EndNsec, APN, IP, NTlli, NMsg, IMSI, IMEI, CellId, OldRai, TLLI, TLLIReall, EndStatus, EndParam, NReq, NAcc, NCpl, NRej from proc_gmmsm  where proctype like '$PT' and endstatus like '$ES'"
}

ts=`date +"%Y%m%d-%H%M"`
recfile=test-record-${ts}.txt

mysql-proc > $recfile
mysql-proc-st >> $recfile
mysql-noimsi >> $recfile

# log statistics from database and log file to 
if [[ "$1" != "" ]] ; then
    LOGFILE=$1
    echo LOGFILE=$LOGFILE
    tail -7000  $LOGFILE |grep -A29 "Started on" |tail -29 >>$recfile
fi

