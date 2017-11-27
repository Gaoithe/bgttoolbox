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
echo another level
echo CALL: do_ssh -tt ${SUSER}@$OASIS_MASTER_HOST $SYSTESTTEMP/install_start_rollingthunder.sh -r $VDOT -s $SUT -ch $CLUSTER_HOSTS -rtargs \"$ROLLINGTHUNDERARGS\" -masterid $OASIS_MASTER_ID
set -x


~/bin/testargs3.sh -rtargs "$ROLLINGTHUNDERARGS" 



