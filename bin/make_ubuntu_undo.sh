
LOG=$1
#LOG=/var/log/dpkg.log.1
grep " upgrade " $LOG |sed "s/^/TS='/;s/ /_/;s/ /';C=/;s/ /;P='/;s/ /;OLD='/;s/ /;NEW='/;s/\$/'; goto \$1 \$2/"

