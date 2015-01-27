#!/bin/sh
date
echo Extra options $*
rsync $* -av --delete --progress --partial --exclude lnk --exclude obj --exclude RPMS --exclude '*.jar' --exclude '*.tar' --exclude .src.tmp.c --exclude '.#*' --exclude tags --exclude .tmp.cconf.map --exclude FAKE_RELEASE_AREA /home/james/work /na-homes/james
date
