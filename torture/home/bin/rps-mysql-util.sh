
alias rpsiups="./rps -p -c -l /store/recordings/IuPS/iups_lac_file.txt /store/recordings/IuPS/IU_PS_K15_0_with_correct_timestamps.acs7 "
alias rpsshort="./rps -l /tmp/lac_file.txt /store/recordings/Gb/reallyshort0408.nlr"
alias rpsdbshort="./rps -c -l /tmp/lac_file.txt /store/recordings/Gb/reallyshort0408.nlr"

alias makerps="nice -6 make -j 5 2>&1 >make.log |tee makeerr.log"
alias makerpsgb="nice -6 make STACKS=gb -j 5 2>&1 >make.log |tee makeerr.log"
alias makerpsiups="nice -6 make STACKS=iups -j 5 2>&1 >make.log |tee makeerr.log"
alias makerpsrel="nice -6 make BUILD=release -j 5 2>&1 >make.log |tee makeerr.log"

#mysql -h ares.ie.commprove.internal -u gprs_user -pgprs_user gprs -e "select count(*),imsi,imei from proc_gmmsm group by imsi;"
MYSQL_NAME=gprs
MYSQL_USER=gprs_user
MYSQL_PASS=gprs_user
MYSQL_HOST=localhost
#MYSQL_HOST=uno.ie.commprove.internal
#MYSQL_HOST=ares.ie.commprove.internal
#MYSQL_HOST=apollo.ie.commprove.internal

mysql-e () { 
    CMD="mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_NAME -e \"$1\""
    echo $CMD
    eval $CMD
}

alias mysql-first='mysql-e "select \"*\" from proc_gmmsm limit 1;"'

alias mysql-proc="mysql-e \"select count(*),proctype from proc_gmmsm group by proctype;\""
alias mysql-proc-st="mysql-e \"select count(*),proctype,EndStatus from proc_gmmsm group by proctype,EndStatus;\""
alias mysql-proc-imsi="mysql-e \"select ProcType,EndStatus,StartSec,StartNsec,count(*),imsi,imei from proc_gmmsm group by imsi,imei,ProcType;\""

mysql-imsi () { 
    mysql-e "select ProcType,EndStatus,EndParam,Startsec,StartNsec,(Endsec-StartSec) as time,imsi,imei 
             from proc_gmmsm where imsi like '$1' order by Startsec;" 
}

mysql-noimsi () {
    mysql-e "select count(*),imei from proc_gmmsm where imei='NO IMEI' group by imei;"
    mysql-e "select count(*),imsi from proc_gmmsm where imsi='NO IMSI' group by imsi;"

    mysql-e "select count(*),imsi,imei from proc_gmmsm where imsi='NO IMSI' and imei='NO IMEI' group by imsi;"
    mysql-e "select count(*),ProcType,EndStatus,imsi,imei from proc_gmmsm where imsi='NO IMSI' and imei='NO IMEI' group by imsi,ProcType,EndStatus;"
}

mysql-file () { 
    mysql-e "select ProcId,StartSec,filepos,proc_index_filename,
             proc_index_file_offset,proc_index_record_size 
             from proc_gmmsm limit 0$1;"
}

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

findch () { find -name '*.[ch]*' -exec grep -Hn $1 {} \;; }

