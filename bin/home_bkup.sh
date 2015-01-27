#!/bin/sh
date
echo Extra options $*
rsync $* -av --delete --progress --partial --exclude .ccache --exclude work /home/james /na-homes
date
