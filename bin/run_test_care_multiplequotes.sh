#!/bin/bash

#https://trello.com/c/HXh16vy8/628-0115075-vimpelcom-14q1-smsc-tc-care-log-cdr-fields-incorrectly-parsed
#0115075 - VimpelCom - 14Q1 - SMSC - TC-Care log(CDR) fields incorrectly parsed in list TRQs 
#
#TEST list:
#
#TODO: how set different charsets so test with them . . ?

SLEEP=30
DTS=$(date +%Y%m%d_%H%M%S)
mkdir -p testresult

TEST=basic_end_double_quote
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with double quotes \"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message \" with quotes in it \" and also 4 near end and 2 right at end.\"\"\!\!\"\"\!\"\""
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m

TEST=ending_with_quotes
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with one quote \""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with quotes x 3 \"\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with quotes x 4 \"\"\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with quotes and commas \",\"bblurgh bleurgh\",\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message \" with quotes in it \" and not at end."
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m


sleep $SLEEP

TEST=ending_with_ticks
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with one tick \'"
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with 2 ticks \'\'"
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message ending with 3 ticks \'\'\'"
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message with ticks \' \'' ending with one tick \'"
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message with ticks \' \'' ending with 2 ticks \'\'"
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message with ticks \' \'' ending with 3 ticks \'\'\'"
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m

sleep $SLEEP

TEST=empty_and_quote_only
#empty and quote only messages 1,2,3,10,81 quotes
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg ""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "\"\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "\"\"\"\"\"\"\"\"\"\""
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m



#12:33:13.061: stderr:                 delilah-8:     tron-1: *** glibc detected *** bin/tron_server: malloc(): memory corruption: 0x0a8bb830 ***
#12:33:13.117: stderr:                 delilah-8:     tron-2: *** glibc detected *** bin/tron_server: malloc(): memory corruption: 0x0aeaa120 ***

sleep $SLEEP

TEST=russian_quotes
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "ставляю,а ради нового года ,ведь такая мелочь\!\!\!\!\!\!\"\!\!\!\"\!\!\!\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg " ятались и бакс позвонил я с ним поговорил и ушёл\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "Заедешь на пустынь? Пробки пи\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "Любииимая моя миуфка:********** смущаешь тем, что совращеночек..^^\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "Хорошо я тебя люблю мой ангел) \"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "Че терпеть\!\!\!\!\"я спать\!\!\""
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m


#
#ставляю,а ради нового года ,ведь такая мелочь!!!!!!"!!!"!!!""
#seems, but for the sake of the new year, because such a small thing !!!!!! "!!!" !!! ""
#
#http://babblefish.com/language/free-language-translation/free-language-translators/
#https://translate.google.com/#auto/en/%D1%81%D1%82%D0%B0%D0%B2%D0%BB%D1%8F%D1%8E%2C%D0%B0%20%D1%80%D0%B0%D0%B4%D0%B8%20%D0%BD%D0%BE%D0%B2%D0%BE%D0%B3%D0%BE%20%D0%B3%D0%BE%D0%B4%D0%B0%20%2C%D0%B2%D0%B5%D0%B4%D1%8C%20%D1%82%D0%B0%D0%BA%D0%B0%D1%8F%20%D0%BC%D0%B5%D0%BB%D0%BE%D1%87%D1%8C!!!!!!%22!!!%22!!!%22%22
#
# ятались и бакс позвонил я с ним поговорил и ушёл"","79037011111
#yatalis buck and I called to talk to him and left "," "79037011111
#
#Заедешь на пустынь? Пробки пи"","79037011111
#You go to the desert? Corks pi "," "79037011111
#
#Любииимая моя миуфка:********** смущаешь тем, что совращеночек..^^"","79037011111 
#Lyubiiimaya my miufka: ********** embarrassing that sovraschenochek .. ^^ "" "79037011111
#
#Хорошо я тебя люблю мой ангел) ""","79037011111
#Че терпеть!!!!"я спать!!"","79037011111                                                              
#Well I love you my angel) "" "" 79037011111Che endure !!!! "I sleep !!" "," 79037011111
#


sleep $SLEEP

TEST=ending_with_gazillions_of_quotes
#### THIS TEST used to CAUSE a CORE DUMP
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message \" with quotes in it \" and also 88 at end.\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\""
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "submit message \" with quotes in it \" and also 89 at end.\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\""
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m

TEST=lots_of_quotes_cause_core_dump_sad_face
bin/smpp_client -bind_type bind_tx -system_id songa -system_type songa -password songa -host vb-48 -port 2775 -dst_expr "1.1.353887777777" -msg_rate 7 -max_msgs 10  -src_expr 1.1.353851234567  -verbose -send_receipts -submit_msg "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\""
cat traffic_care/libcdr.tron-1.spool |tee testresult/${DTS}_${TEST}.out
bin/mci list  |grep tron
clex -ch 0 -s -1m

DTS=$(date +%Y%m%d_%H%M%S)

#???????  yep - one of those tests . . . NUTS!!!! :-(   MWAHHHHH!!!!    - the LOTS of quotes tests.
#12:25:05.733: stderr:                 delilah-8:     tron-1: *** glibc detected *** bin/tron_server: malloc(): memory corruption: 0x09a97290 ***
#12:25:05.708: stderr:                 delilah-8:     tron-2: *** glibc detected *** bin/tron_server: malloc(): memory corruption: 0x0b877708 ***
