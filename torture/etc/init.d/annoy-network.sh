#!/bin/sh
# sudo cp ~/bin/annoy-network.sh /etc/init.d/
# sudo cp ~/bin/start-annoy-network.sh /etc/init.d/rc5.d/K25annoy_network

# if only I could think of a better way :-(
# Hint: you may set mandatory devices in /etc/sysconfig/network/config
# But if I don't want the network we have an annoying extra delay at init.d
# time. And even if want network it waits 20 secs but that is not enough! 
# Seem to need a retry mechanism.
# (if have just turned modem on or want network to start later when
#  modem is turned on)

SLEEPT=0
ANNOYCOUNT=0
TRYCOUNT=0
QUICK=0
VERBOSE=0

while [[ "$1" != "" ]] ; do
   if [[ "$1" == "-q" ]] ; then
      QUICK=1
   elif [[ "$1" == "-v" ]] ; then
      VERBOSE=1
  else
      echo usage: $0 [-q] [-v] # quick/verbose
      exit -1;
  fi
  shift
done

IPADDR=`netstat -ie eth0 |perl -00 -ne "print \$_ if /eth0/;" |grep "inet addr:" |sed "s/.*:\([0-9][0-9.]*\)\s.*/\1/"`

while [[ $ANNOYCOUNT == 0 || $QUICK == 0 ]] ; do

   ANNOYCOUNT=$(( $ANNOYCOUNT+1 ))

   while [[ "$IPADDR" == "" ]] ; do
      TRYCOUNT=$(( $TRYCOUNT+1 ))
      # while network is down we monitor every 12 secs to see if we can restart
      SLEEPT=12
      sleep $SLEEPT
      if [[ "$VERBOSE" == 1 ]] ; then echo "$TRYCOUNT try network start"; fi
      /etc/init.d/network start
      IPADDR=`netstat -ie eth0 |perl -00 -ne "print \$_ if /eth0/;" |grep "inet addr:" |sed "s/.*:\([0-9][0-9.]*\)\s.*/\1/"`
   done

   if [[ "$VERBOSE" == 1 ]] ; then 
      echo "$ANNOYCOUNT network $IPADDR is up."; 
      netstat -ie eth0 |perl -00 -ne "print \$_ if /eth0/;" 
   fi

   if [[ $QUICK == 0 ]] ; then
      # network is up, now we monitor it every 150 sec to make sure it stays up
      SLEEPT=150
      sleep $SLEEPT
      IPADDR=`netstat -ie eth0 |perl -00 -ne "print \$_ if /eth0/;" |grep "inet addr:" |sed "s/.*:\([0-9][0-9.]*\)\s.*/\1/"`
   fi

done

if [[ "$ANNOYCOUNT" == "1" ]] ; then
   echo network already up. $IPADDR
fi

echo $0 job done.
#netstat -ie eth0 |perl -00 -ne "print \$_ if /eth0/;" 
