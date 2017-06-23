#!/bin/bash


function help {
cat <<EOF
Usage: $(basename $0) [<options>] [-ping] <sshuser@host> "<command>"
# e.g. usage ~/bin/sshmon.sh builduser@buildmachine "ls -alstr builddir |tail"
# e.g. usage ~/bin/sshmon.sh -ping builduser@buildmachine "ls -alstr builddir |tail"

Default MODE: poll continuous polling of command until no change, then exit  
Ping MODE: ping command once and compare with last run, exit 42 if change

Full Usage: $(basename $0) . . . \
    [-pt <polltime_secs>] [-it <idletime_secs>] [-wt <warnperiod_secs>] \
    [-pf <pollfile>] \
    [-ec <exitcode>] [-mi <maxidle_secs] \
    [-ping] <sshuser@host> "<command>"

Use this script directly on command-line or in jenkins set up a monitor job:
    ScriptTrigger: ./sshmon.sh -ping <sshuser@host> "<command>"
     (with exit code 42 and cron e.g. 'H/15 * * * *')
    Build Action: ./sshmon.sh -maxidle 120 <sshuser@host> "<command>"
     and scp <sshuser@host:dir/logfile> ./
     and archive logfile

EOF
}


do_ssh() {
    ssh -o "BatchMode=yes" -o "StrictHostKeyChecking=no" -o ServerAliveInterval=15 -o ServerAliveCountMax=3 $*
}

polltime=10
idletime=120
warntime=60
pollfile=.sshmon/poll.out
exitcode=42
maxidle=

PING=false
while [ $# -gt 0 ]; do
    case "$1" in
        -ping)
            PING=true
            shift
        ;;
        -pt|-polltime)
            polltime=$2
            shift
            shift
        ;;
        -it|-idletime)
            idletime=$2
            shift
            shift
        ;;
        -wt|-warntime)
            warntime=$2
            shift
            shift
        ;;
        -pf|-pollfile)
            pollfile=$2
            shift
            shift
        ;;
        -ec|-exitcode)
            exitcode=$2
            shift
            shift
        ;;
        -mi|-maxidle)
            maxidle=$2
            shift
            shift
        ;;
        -h|-help)
            help && exit 0
        ;;
        *)
            break
        ;;
    esac
done

mkdir -p $(dirname $pollfile)
touch ${pollfile}.OLD
[[ -e $pollfile ]] && mv $pollfile{,.OLD}

while true; do 
    echo CALLING: ssh $*
    OUT=$(do_ssh $*|tee $pollfile)
    if [[ -e ${pollfile}.OLD ]] ; then
        DIFF=$(diff -u $pollfile{,.OLD})
        if $PING; then
            # if pinging and files same then exit 0
            # if pinging and files diff then exit $exitcode
            if [[ -z $DIFF ]] ; then
                echo "INFO: exit 0 because no change"
                exit 0
            else
                echo "INFO: exit $exitcode change seen"
                exit $exitcode
            fi
        fi
    fi
    if [[ $OUT != $OLDOUT ]] ; then
        if (( idle > 20 )) ; then
            echo "INFO: WAKING UP, WAS idle for idle=${idle}s"
        fi
        date
        echo "$OUT"
        OLDOUT="$OUT"
        ((idle=0))
    else
        ((idle+=polltime))
    fi
    if (( $idle > $idletime && ( $idle % $warntime == 0 ) )) ; then
        echo "WARNING: idle=${idle}s"
    fi
    if [[ ! -z $maxidle ]] && (( idle >= maxidle )) ; then
        # if polling and > maxidle then exit
        exit 0
    fi
    sleep $polltime
done
