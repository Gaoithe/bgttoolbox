#!/bin/bash

#BRANCH=OMN-Traffic-Control-14-Q3
#BRANCH=OMN-Traffic-Control-15-Q3
#MONSTERFLAGS=-restart

BRANCH=
MONSTERFLAGS=

DTS=$(date +%Y%m%d_%H%M); 

# check mod.list and mod.graph 
if [[ $MONSTERFLAGS != "-restart" ]] ; then
   [[ -e mod.list ]] && mv mod{,_${DTS}}.list
   [[ -e mod.graph ]] && mv mod{,_${DTS}}.graph
fi

if [[ -z $BRANCH ]] ; then
   if [[ ! -e mod.list ]] ; then
       echo "Building mod.list"
       /slingshot/sbe/LATEST/scripts/build_order --cvs-modules --root /slingshot/deployments/OMN-Traffic-Control >mod.list
       [[ -e mod.graph ]] && mv mod{,_${DTS}}.graph
   fi
   if [[ ! -e mod.graph ]] ; then 
       echo "Building mod.graph"
       /slingshot/sbe/LATEST/scripts/build_order --digraph --include-non-metas --root /slingshot/deployments/OMN-Traffic-Control >mod.graph
   fi
else 
   PLANFILES="/slingshot/BRANCHES-PLANS/${BRANCH}.plan branch.plan"
   if [[ ! -e mod.list || ! -e branch.plan || $(diff -q $PLANFILES) ]] ; then
       echo "Building mod.list"
       cp $PLANFILES
       #cp /slingshot/BRANCHES-PLANS/${BRANCH}.plan branch.plan
       echo "# BRANCH-NAME ${BRANCH}" >mod.list
       grep -v ^# branch.plan |awk '{print $2}' >>  mod.list
       [[ -e mod.graph ]] && mv mod{,_${DTS}}.graph
   fi
   if [[ ! -e mod.graph ]] ; then 
       echo "Building mod.graph"
       DTCVER=$(grep deployments/OMN-Traffic-Control branch.plan |cut -d" " -f 3 |sed "s/-/\//g")
       /slingshot/sbe/LATEST/scripts/build_order --digraph --include-non-metas --root /slingshot/deployments/OMN-Traffic-Control/$DTCVER/SRC >mod.graph
   fi
fi

if [[ $MONSTERFLAGS != "-restart" ]] ; then

   echo "just for fun" > PURPOSE

   # james machine nebraska doesn't like cvs -Q -z9 co -R whatever # presumably -z9 is the problem. it repeatedly gets stuck :-(
   # buildall.sh gets branch from BRANCH-NAME in mod.list
   /home/james/bin/buildall.sh co 
   #/homes/brian/scripts/buildall.sh co 

   # after fixing up mod.list and mod.graph with new module hammer-x/drill/ipdip/server . . .
   # then run buildall.sh modvers from top [[optionally with -start hammer-x/drill/ipdip/server]]
   /home/james/bin/buildall.sh modvers
   #[james@nebraska TCHOD4]$ buildall.sh -oneshot hammer-x/drill/custard/server modvers

   /home/james/bin/buildall.sh spotless

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

fi

export JDK_VERSION=1.7
export JAVA_SOURCE_VERSION=1.7
export JAVA_TARGET_VERSION=1.7
unset JAVA
unset JAVA_HOME

nice time /homes/brian/scripts/buildmonster.pl $MONSTERFLAGS

build_greperr.sh
