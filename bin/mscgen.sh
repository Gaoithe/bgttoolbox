#!/bin/bash

MSCFILE=$1
if [[ -e $MSCFILE ]] ; then
    bn=$(basename $MSCFILE);
    bf=${bn%%.msc};
    mscgen -i $MSCFILE -T png -o ${bf}.png
    mscgen -i $MSCFILE -T svg -o ${bf}.svg && cat ${bf}.svg && display ${bf}.svg
fi
