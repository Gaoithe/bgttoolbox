AR_HOSTS="${PREFIXIP}${SITE1}.13 ${PREFIXIP}${SITE1}.14 ${PREFIXIP}${SITE2}.13 ${PREFIXIP}${SITE2}.14"
C_SMSC_HOSTS="${PREFIXIP}${SITE1}.4 ${PREFIXIP}${SITE1}.5 ${PREFIXIP}${SITE1}.6 ${PREFIXIP}${SITE1}.7 ${PREFIXIP}${SITE1}.8 ${PREFIXIP}${SITE1}.9 ${PREFIXIP}${SITE1}.10 ${PREFIXIP}${SITE1}.11"
M_SMSC_HOSTS="${PREFIXIP}${SITE2}.4 ${PREFIXIP}${SITE2}.5 ${PREFIXIP}${SITE2}.6 ${PREFIXIP}${SITE2}.7 ${PREFIXIP}${SITE2}.8 ${PREFIXIP}${SITE2}.9 ${PREFIXIP}${SITE2}.10 ${PREFIXIP}${SITE2}.11"
C_CARE_HOSTS="${PREFIXIP}${SITE1}.16 ${PREFIXIP}${SITE1}.17"
M_CARE_HOSTS="${PREFIXIP}${SITE2}.16 ${PREFIXIP}${SITE2}.17"

# vip-m-sms vip-m-app vip-m-ca
VIP_HOSTS="${PREFIXIP}${SITE2}.12 ${PREFIXIP}${SITE2}.15 ${PREFIXIP}${SITE2}.18 ${PREFIXIP}${SITE1}.12 ${PREFIXIP}${SITE1}.15 ${PREFIXIP}${SITE1}.18"
ITN_HOSTS="${PREFIXIP}${SITE1}.68 ${PREFIXIP}${SITE1}.69 ${PREFIXIP}${SITE1}.70"
UAT_HOSTS="${PREFIXIP}${SITE1}.40 ${PREFIXIP}${SITE1}.41 ${PREFIXIP}${SITE1}.42 ${PREFIXIP}${SITE1}.43 ${PREFIXIP}${SITE1}.44"

SSHPR=~/.ssh/proximus2

tc_sms_11=(tc-sms-11 ${PREFIXIP}${SITE2}.4)
tc_sms_12=(tc-sms-12 ${PREFIXIP}${SITE2}.5)
tc_sms_13=(tc-sms-13 ${PREFIXIP}${SITE2}.6)
tc_sms_14=(tc-sms-14 ${PREFIXIP}${SITE2}.7)
tc_sms_15=(tc-sms-15 ${PREFIXIP}${SITE2}.8)
tc_sms_16=(tc-sms-16 ${PREFIXIP}${SITE2}.9)
tc_sms_17=(tc-sms-17 ${PREFIXIP}${SITE2}.10)
tc_sms_18=(tc-sms-11 ${PREFIXIP}${SITE2}.11)
tc_sms_21=(tc-sms-11 ${PREFIXIP}${SITE1}.4)
tc_sms_22=(tc-sms-12 ${PREFIXIP}${SITE1}.5)
tc_sms_23=(tc-sms-13 ${PREFIXIP}${SITE1}.6)
tc_sms_24=(tc-sms-14 ${PREFIXIP}${SITE1}.7)
tc_sms_25=(tc-sms-15 ${PREFIXIP}${SITE1}.8)
tc_sms_26=(tc-sms-16 ${PREFIXIP}${SITE1}.9)
tc_sms_27=(tc-sms-17 ${PREFIXIP}${SITE1}.10)
tc_sms_28=(tc-sms-11 ${PREFIXIP}${SITE1}.11)

tc_app_11=(tc-app-11 ${PREFIXIP}${SITE2}.13)
tc_app_12=(tc-app-12 ${PREFIXIP}${SITE2}.14)
tc_app_21=(tc-app-21 ${PREFIXIP}${SITE1}.13)
tc_app_22=(tc-app-22 ${PREFIXIP}${SITE1}.14)
tc_ca_11=(tc-ca-11 ${PREFIXIP}${SITE2}.16)
tc_ca_12=(tc-ca-12 ${PREFIXIP}${SITE2}.17)
tc_ca_21=(tc-ca-21 ${PREFIXIP}${SITE1}.16)
tc_ca_22=(tc-ca-22 ${PREFIXIP}${SITE1}.17)

M_SMSC_HNS="tc_sms_11 tc_sms_12 tc_sms_13 tc_sms_14 tc_sms_15 tc_sms_16 tc_sms_17 tc_sms_18"
C_SMSC_HNS="tc_sms_21 tc_sms_22 tc_sms_23 tc_sms_24 tc_sms_25 tc_sms_26 tc_sms_27 tc_sms_28"
M_APP_HNS="tc_app_11 tc_app_12"
C_APP_HNS="tc_app_21 tc_app_22"
M_CA_HNS="tc_ca_11 tc_ca_12"
C_CA_HNS="tc_ca_21 tc_ca_22"
for hn in $M_SMSC_HNS $C_SMSC_HNS $M_APP_HNS $C_APP_HNS $M_CA_HNS $C_CA_HNS; do
 name=$hn[0]
 ip=$hn[1]
 # the evil eval
 eval name_$hn=$hn[0]
 eval ip_$hn=$hn[1]
 #echo DEBUG $hn name_$hn:${!name} ip_$hn:${!ip}
done

# e.g. call ip=$(get_ip tc_sms_11)
function get_ip {
    ip=$1[1]
    echo ${!ip}
}

# ip -> name
# e.g. call name=$(get_name ${PREFIXIP}${SITE2}.13)
function get_name {
    echo $(set |grep -F "$1" |grep tc_ |cut -d '"' -f 1|sed s/=.*//)
    # tc_app_11=([0]="tc-app-11" [1]="${PREFIXIP}${SITE2}.13")
}

echo 'DEBUG e.g. use hn=tc_app_21 ip=$hn[1] use var indirection ${!ip}'
echo 'DEBUG e.g. ip=$(get_ip tc_sms_11); name=$(get_name ${PREFIXIP}${SITE2}.13);'
