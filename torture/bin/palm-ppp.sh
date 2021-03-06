#!/bin/sh
# Script to establish a routed and NAT'd ppp link between a Palm PDA
# and your PC.

# This script accompanies the article at 
# http://atulchitnis.net/writings/palm-ppp.php

# By Atul Chitnis <http://atulchitnis.net>

# Version 1.1

# Note - if you are using a USB connection, start the connection 
# at the Palm end *FIRST*, wait 2-3 seconds, then run this script.

# ---- start of parameter block 

# The port your Palm is connected to
MyPort="/dev/ttyUSB0"

# The speed it talks at (ignored for USB connections)
MyBaud="115200"

# The IP address to assign to the Palm
MyPalmIP="192.168.1.2"

# The IP address to assign to PC's side of the link
MyPcIP="192.168.1.33"

# What DNS should the Palm use?
MyDNS=`grep ^nameserver /etc/resolv.conf|awk '{ print "ms-dns " $2 }'`
# Comment the previous line and uncomment and edit the next line if you
# prefer to use a DNS different from the ones in your /etc/resolv.conf
# MyDNS="192.168.1.1"

# What device will we use by default for the uplink?
MyUplink="eth0"

# Where are my tools?
MyTools="/sbin/"
MyTools2="/usr/sbin/"

# Where is pppd?
MyPPPD="/usr/sbin/pppd"

# ---- end of parameter block 

# No edits should be required below

# Get rid of ipchains, if loaded
${MyTools}rmmod ipchains &> /dev/null

# Load iptables and some related modules
${MyTools}modprobe ip_tables
${MyTools}modprobe ip_conntrack_ftp
${MyTools}modprobe ip_conntrack_irc

# Flush any rules that may be hanging around 
${MyTools2}iptables -F 


# OK, let's find out what our uplink device really is

DEFDEV=`${MyTools}route -n |grep "^0.0.0.0"|tr -s " "|cut -d " " -f8`
if [ ! -z "$DEFDEV" ]; then
   MyUplink=$DEFDEV
fi

# All done, kick off pppd to talk to the port and establish a link
# pppd will wait for the actual connection to happen before going 
# into the background

${MyPPPD} ${MyPort} ${MyBaud} local noauth \
  ${MyPcIP}:${MyPalmIP} $MyDNS passive updetach asyncmap 0

if [ ! -z "`${MyTools}ifconfig|grep ${MyPalmIP}`" ]; then

   # OK, we have a link, let's NAT

   echo 1 > /proc/sys/net/ipv4/ip_forward

   ${MyTools2}iptables -A INPUT -i ! ${MyUplink} -j ACCEPT
   ${MyTools2}iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
   ${MyTools2}iptables -t nat -A POSTROUTING -o ${MyUplink} -j MASQUERADE

   echo
   echo -e Link is up, your Palm is at ${MyPalmIP} \\a

else
   echo -e Link failed \\a
fi
