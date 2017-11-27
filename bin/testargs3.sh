#!/bin/bash 

echo CALLED: $0 $*

while [ $# -gt 0 ]; do
   case "$1" in
      -rt)
        echo ARG -rt
        ROLLINGTHUNDER=true
        INSTALL_OMN_DOCKER_SCRIPT=install_OMN_rollingthunder.sh
        shift
        ;;
      -rtargs)
         ROLLINGTHUNDERARGS="$2"
         echo ARG -rtargs special ROLLINGTHUNDERARGS=\"$ROLLINGTHUNDERARGS\"
         shift
         shift
         ;;
      *)
         echo "Unrecognised commandline switch $1"
         shift
      ;;
esac
done

echo foo bar



