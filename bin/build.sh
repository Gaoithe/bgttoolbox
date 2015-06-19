#!/bin/bash
#echo "Building mod.list"
#/slingshot/sbe/LATEST/scripts/build_order --cvs-modules --root /slingshot/deployments/OMN-Traffic-Control >mod.list
#echo "Building mod.graph"
#/slingshot/sbe/LATEST/scripts/build_order --digraph --include-non-metas --root /slingshot/deployments/OMN-Traffic-Control >mod.graph
echo "just for fun" > PURPOSE

# james machine nebraska doesn't like cvs -Q -z9 co -R whatever # presumably -z9 is the problem. it repeatedly gets stuck :-(
/home/james/bin/buildall.sh co 
#/homes/brian/scripts/buildall.sh co 

# after fixing up mod.list and mod.graph with new module hammer-x/drill/ipdip/server . . .
# then run buildall.sh modvers from top [[optionally with -start hammer-x/drill/ipdip/server]]
/home/james/bin/buildall.sh modvers
#[james@nebraska TCHOD4]$ buildall.sh -oneshot hammer-x/drill/custard/server modvers

## apply some changes needed for building
touch SBUG_SRC_BASE
touch SCM.BUILD.ALL
#cp -p {/home/james/work/TC/,}MOS-base/mkrpms.sh 
#cp -p {/home/james/work/TC/,}libtbx/hostid.c
#cp -p {/home/james/work/TC/,}libtbx/Makefile

# see sbe/CHANGES make vars LINUX_VER and LINUX_REAL_VER populated
cat >Makefile.slingshot.fakeyfakey <<EOF
FAKEY_SUPPORTED_LINUX=Y
FAKEY_PRETEND_VERSION=FC9
FAKEY_REAL_VERSION=F19
EOF

export JDK_VERSION=1.7
export JAVA_SOURCE_VERSION=1.7
export JAVA_TARGET_VERSION=1.7
unset JAVA
unset JAVA_HOME

nice time /homes/brian/scripts/buildmonster.pl 
