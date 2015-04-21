#!/bin/sh
# root has to run smartctl
DRIVE=sda
export TERM=xterm; eval `resize`
echo "DATE=$(date)" |tee -a /home/james/discmon_${DRIVE}.log
/sbin/smartctl -A /dev/$DRIVE >> /home/james/discmon_${DRIVE}.log
WARN=$(/sbin/smartctl -A /dev/$DRIVE | grep FAIL)
if [[ ! -z $WARN ]] ; then
  echo "WARNING. FAIL. $WARN"
  wall "diskmon $DRIVE WARNING. FAIL. $WARN"
  # show historical values, is the raw count increasing ??
  grep -E "DATE=|FAILING_NOW" /home/james/discmon_${DRIVE}.log |tail -20 |wall
fi

#crontab entry for root:
## 22:11 daily. monitor disc drive warnings/failures
#11        22      *        *       *      /home/james/bin/diskmon.sh >/tmp/diskmon.out 2>&1


# Reallocated_Sector_Ct raw value is 4035 = 4035 reallocated sectors.
# value=2 < threshold=36 ius the normalized value/thresh.
#  5 Reallocated_Sector_Ct   0x0033   002   002   036    Pre-fail  Always   FAILING_NOW 4035
# http://serverfault.com/search?q=FAILED+SMART+self-check
# http://static.googleusercontent.com/media/research.google.com/en//archive/disk_failures.pdf
#  see 3.5.2 Reallocation Counts
#
# [root@nebraska mysql]# smartctl -A /dev/sda
# smartctl 6.2 2013-07-26 r3841 [i686-linux-3.14.17-100.fc19.i686.PAE] (local build)
#     Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
# 
#     === START OF READ SMART DATA SECTION ===
#     SMART Attributes Data Structure revision number: 10
#     Vendor Specific SMART Attributes with Thresholds:
#     ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
#       1 Raw_Read_Error_Rate     0x000f   118   099   006    Pre-fail  Always       -       174942352
#         3 Spin_Up_Time            0x0003   097   097   000    Pre-fail  Always       -       0
#           4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       132
#             5 Reallocated_Sector_Ct   0x0033   002   002   036    Pre-fail  Always   FAILING_NOW 4035
#               7 Seek_Error_Rate         0x000f   084   060   030    Pre-fail  Always       -       296747717
#                 9 Power_On_Hours          0x0032   053   053   000    Old_age   Always       -       41809
#                  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
#                   12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       65
#                   183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
#                   184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
#                   187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
#                   188 Command_Timeout         0x0032   100   094   000    Old_age   Always       -       154621837512
#                   189 High_Fly_Writes         0x003a   100   100   000    Old_age   Always       -       0
#                   190 Airflow_Temperature_Cel 0x0022   066   058   045    Old_age   Always       -       34 (Min/Max 32/39)
#     194 Temperature_Celsius     0x0022   034   042   000    Old_age   Always       -       34 (0 15 0 0 0)
#     195 Hardware_ECC_Recovered  0x001a   043   014   000    Old_age   Always       -       174942352
#     197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
#     198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
#     199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
#     240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       185177515009014
#     241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       1020165072
#     242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       370970339
# 
# 
