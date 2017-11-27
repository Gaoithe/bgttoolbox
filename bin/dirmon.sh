#!/bin/bash
[[ "$1" != "" ]] && cd $1
while true; do find . -maxdepth 1 -mmin 1 -exec ls -al {} +; sleep 5; echo AGAIN AGAIN; done
