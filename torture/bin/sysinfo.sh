#!/bin/bash

HOSTNAME=`hostname`
VERSION=`cat /proc/version`
DATE=`date`
OUT="/tmp/info.html"

echo -n "Customer? "; 		read CUSTOMER
echo -n "Manufacturer? ";       read MANUFACTURER
echo -n "Model? ";		read MODEL
echo -n "Serial #? ";		read SERIAL

PMODEL=`cat /proc/cpuinfo | grep vendor_id | awk -F\: '{print $2}'`
PNAME=`cat /proc/cpuinfo  | grep model | awk -F\: '{print $2}'`
PSPEED=`cat /proc/cpuinfo | grep MHz | awk -F\: '{print $2}' | awk -F\. '{print $1}'`

if [ -z ${PSPEED} ]
then
	PSPEED=`cat /proc/cpuinfo | grep mips | awk -F\: '{print $2}' | awk -F\. '{print $1}'`
fi

RAM=`cat /proc/meminfo | grep MemTotal | awk -F\: '{print $2}' | awk -F\  '{print $1 " " $2}'`
SWAP=`cat /proc/meminfo | grep SwapTotal | awk -F\: '{print $2}' | awk -F\  '{print $1 " " $2}'`

echo "<TITLE>System Information - $HOSTNAME </TITLE>" 		> $OUT 
echo "<BR><BR><H1>Technotes: $CUSTOMER</H1>" 			>> $OUT
echo "<H1>$HOSTNAME</H1><HR WIDTH=90%>" 			>> $OUT
echo "<I>$DATE</I><HR WIDTH=90%><P><UL><PRE>" 			>> $OUT
echo "Hardware Manufacturer:  $MANUFACTURER" 			>> $OUT
echo "Machine Model........:  $MODEL"           		>> $OUT
echo "System Serial Number :  $SERIAL"				>> $OUT
echo "System Specifics.....:  $PMODEL $PNAME, $PSPEED MHz"	>> $OUT
echo "                        $RAM RAM"         		>> $OUT
echo "                        $SWAP swap space" 		>> $OUT
echo "Operating System.....:  $VERSION"         		>> $OUT
echo "</PRE></UL><P><HR WIDTH=90%><P>"           		>> $OUT

echo "<H2>I/O Ports</H2><HR WIDTH=90%><P><UL><PRE>" 		>> $OUT
cat /proc/ioports                                     		>> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                   		>> $OUT


echo "<H2>Interrupts</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
cat /proc/interrupts                                   >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                    >> $OUT

echo "<H2>PCI Devices</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
cat /proc/pci                                           >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                     >> $OUT

echo "<H2>SCSI Devices</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
cat /proc/scsi/scsi                                      >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                     >> $OUT

if [ -e /proc/rd ]
then
	echo "<H2> RAID controller found (how cool!)"		>> $OUT
	echo "</H2><HR WIDTH=90%><P><UL><PRE>"			>> $OUT
	cat /proc/rd/c*/current_status				>> $OUT
	echo "</PRE></UL><HR WIDTH=90%><P>"			>> $OUT
fi

echo "<H2>Disk Configuration</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
df -kv                                                         >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                            >> $OUT

echo "<H2>ifconfig -a</H2><HR WIDTH=90%><P><UL><PRE>"        >> $OUT
ifconfig -a                                                    >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                            >> $OUT

echo "<H2>netstat -rn</H2><HR WIDTH=90%><P><UL><PRE>"        >> $OUT
netstat -rn                                                    >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                            >> $OUT

echo "<H2>/etc/lilo.conf</H2><HR WIDTH=90%><P><UL><PRE>"     >> $OUT
cat /etc/lilo.conf                                             >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                            >> $OUT

echo "<H2>Inetd Services</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
cat /etc/inetd.conf | grep -v "[#]"                 >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                   >> $OUT

echo "<H2>rc3.d Services</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
ls /etc/rc.d/rc3.d/S*                                 >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                   >> $OUT

# Note: this was a quick hack that didn't do what I wanted, but the
# side effect was actually better than what I had wanted.
echo "<H2>Possible Samba Shares</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
grep "[\['path']" /etc/smb.conf | grep -v "[;#]"                >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                             >> $OUT

echo "<H2>Print queues</H2><HR WIDTH=90%><P><UL><PRE>" >> $OUT
lpc status                                             >> $OUT
echo "</PRE></UL><HR WIDTH=90%><P>"                             >> $OUT

echo "<FONT size=-1><i>Last Updated: $DATE"			>> $OUT
echo -n "Your name? ";           		read SYSADMIN
echo "<br>By: $SYSADMIN</i></font></BODY></HTML>"		>> $OUT
echo "Outputting file to /tmp/info.html" 
