#!/bin/bash

# should be run as root (sudo)

USBIFACE=$(ifconfig |grep "\sLink\s" |awk '{print $1}'|grep enp0)
IP=$(ifconfig |grep -A1 $USBIFACE|tail -1 |awk '{print $2}'|sed s/addr://)
echo USBIFACE=$USBIFACE IP=$IP

[[ "$IP" == "" || "$USBIFACE" == "" ]] && echo "ERROR: cannot see usb network interface" && exit -1

# DANGEROUS:

# BRIDGE start
ifconfig eth0 0.0.0.0
ifconfig $USBIFACE 0.0.0.0
brctl addbr br0 
brctl addif br0 eth0
brctl addif br0 $USBIFACE
ifconfig br0 up
dhclient br0

# UNBRIDGE stop
ifconfig eth0 down
ifconfig $USBIFACE down
ifconfig br0 down
brctl delbr br0 
ifconfig eth0 up
dhclient eth0

