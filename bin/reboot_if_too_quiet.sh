#!/bin/bash
# reboot_if_too_quiet.sh, cannot find what is causing hang . . so . . dawnly cron job as root

function check() {
    bn=$(basename $FILE)
    
    [[ ! -e $FILE ]] && echo create $FILE && touch $FILE
    [[ ! -e /tmp/$bn ]] && cp -p $FILE /tmp/
    
    NOT_QUIET=$(find $FILE -newer /tmp/$bn)
    
    if [[ -z $NOT_QUIET ]] ; then
        echo $FILE is too quiet
        $DEBUG shutdown -r now
    else
        echo $FILE is not too quiet
        $DEBUG marking too quiet check as done
        cp -p $FILE /tmp/
    fi
}



FILE=$(ls -atr /home/james/.emacs.d/auto-save-list/|tail -1)
check $FILE

FILE=/home/james/TOO_QUIET.txt
check $FILE


