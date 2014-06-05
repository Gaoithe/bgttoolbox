#! /bin/sh
# Provides: ipsec/openswan vpn connection

DESC=ipsec

DAEMON=ipsecTODOfullpathhere

. /lib/lsb/init-functions

#set -e

case "$1" in
  start)
        echo Starting ipsec and opening the VPN connection
sudo ipsec setup --start
sudo ipsec auto --add sonicwall
sudo ipsec whack --name sonicwall --initiate
    ;;
  force-reload)
        echo Starting ipsec and opening the VPN connection
sudo ipsec setup --start
sudo ipsec auto --add sonicwall
# if you change the configuration files, you’ll need to run ’
sudo ipsec auto --replace sonicwall
# ’ to reload the file)
sudo ipsec whack --name sonicwall --initiate
    ;;
  stop)
echo Closing the VPN connection and stopping ipsec
sudo ipsec whack --name sonicwall --terminate
sudo ipsec setup --stop
	;;
  restart|force-reload)
	$0 stop
	$0 start
	;;
  status)
	status_of_proc "$DAEMON" "$DESC" && exit 0 || exit $?
	;;
  *)
	N=$0
	echo "Usage: $N {start|stop|restart|force-reload|status}" >&2
	exit 1
	;;
esac

exit 0

# vim:noet
