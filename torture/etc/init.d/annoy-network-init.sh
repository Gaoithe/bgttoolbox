#!/bin/sh
#
# start/stop script to keep network up (or bring network up after delay for
# dsl router training (for e.g.)
# by hjames, may 2006
#
# chkconfig: 2345 95 03
# description:  Start and stop annoying keep network up thing
# probe: true
# processname: annoy-network.sh
# config: /etc/annoy-network.conf
# pidfile: /var/run/annoy-network.pid

# sudo cp ~/bin/annoy-network-init.sh /etc/init.d/
# sudo cp ~/bin/annoy-network.sh /usr/local/sbin/annoy-network.sh
# no sudo cp ~/bin/start-annoy-network.sh /etc/init.d/rc5.d/K25annoy_network
ANNOYING=/usr/local/sbin/annoy-network.sh
PID=/var/run/annoy-network.pid
LOGFILE=/var/log/annoy-network.log

# Source function library. (redhat)
# . /etc/rc.d/init.d/functions

# if only I could think of a better way :-(
# Hint: you may set mandatory devices in /etc/sysconfig/network/config
# But if I don't want the network we have an annoying extra delay at init.d
# time. And even if want network it waits 20 secs but that is not enough! 
# Seem to need a retry mechanism.
# (if have just turned modem on or want network to start later when
#  modem is turned on)

#### could we do something with this?:
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && echo "networking not up"; 
echo "networking ${NETWORKING}"



start(){
    $ANNOYING -v >$LOGFILE 2>&1 &
    ret=$?

    if [ $ret -eq 0 ]; then
        echo good.
    fi

    return $?
}

stop(){
    killproc $ANNOYING
    ret=$?
    return $?
}



# See how we were called.
case "$1" in
  start)
        start
    ;;

  stop)
        stop
        ;;

  status)
    echo no status
    exit $?
    ;;

  restart)
    $0 stop
    sleep 1
    $0 start
    ;;  

  *)
        echo "Usage: annoy-network.sh {start|stop|status|restart}"
        exit 1
esac

exit $ret

