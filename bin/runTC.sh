#!/bin/bash

[[ -z $RPMNDIR ]] && RPMNDIR=rpms_runTC

if [[ -z $INSTALL_FROM_SLINGSHOT ]] ; then
    INSTALL_FROM_SLINGSHOT=true
    [[ -e mod.list ]] && INSTALL_FROM_SLINGSHOT=false
fi
[[ -z $INSTALL_LATEST ]] && INSTALL_LATEST=true

#HOST
[[ -z $REL ]] && REL=14-Q1
[[ -z $PLAT ]] && PLAT=FC9

help(){
    cat <<EOF
runTC.sh script must be run for each host/node in cluster.
You MUST install same release on each node.
TODO: should write defaults toi a cluster file and read in second script.

Set HOST=<host> host to uninstall/install on.
Set INSTALL_FROM_SLINGSHOT=false to install local build

EOF
}

menu(){
    clear
    cat <<EOF
====================================
run_prep_rpms_deploylist.sh must be done before . . . RPMNDIR=rpms_<xxxx>
Set vars with <VAR>=<VALUE>. 
After all vars set then enter "run". 
Enter "exit" or garbage to quit.
   HOST=$HOST
   ROOTUSER=$ROOTUSER
   INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT (true or INSTALL_FROM_SLINGSHOT false for LOCAL BUILD)
EOF

    if $INSTALL_FROM_SLINGSHOT; then
        cat <<EOF
      INSTALL_LATEST=$INSTALL_LATEST (true or false(choose release))
EOF
    fi

    if $INSTALL_FROM_SLINGSHOT && ! $INSTALL_LATEST; then
        cat <<EOF
      REL=$REL (e.g. 13-Q1 14-Q1 15-Q1 15-Q2 15-Q3)
      PLAT=$PLAT (e.g. FC9, AS6 or AS7)
EOF
    fi
    echo -n "${PS1}> "
}

get_input(){
    read $1
}

after_input(){
   # when set host
   ROOTUSER=vroot
   [[ "${HOST:0:2}" != "vb" ]] && ROOTUSER=root
   export ROOTUSER

   if $INSTALL_FROM_SLINGSHOT && ! $INSTALL_LATEST; then
       PUB=/slingshot/PUBLISHED/OMN-Traffic-Control/$REL
       PUB_BASE=$PUB/BASE/$PLAT
       PUB_PAT=$PUB/PATCHES/$PLAT
       echo PUB=$PUB
       echo PUB_BASE=$PUB_BASE
       echo PUB_PAT=$PUB_PAT
       cat $PUB/info
   fi

}

run(){
    echo run HOST=$HOST
    if [[ -z $HOST ]] ; then
        echo "ERROR: MUST set HOST"
    else
        echo -n "HOST=$HOST INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT "
        $INSTALL_FROM_SLINGSHOT && echo -n "INSTALL_LATEST=$INSTALL_LATEST REL=$REL PLAT=$PLAT "
        echo run_uninstall_install_TC_master.sh $HOST 
        ROOTUSER=$ROOTUSER INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT \
            INSTALL_LATEST=$INSTALL_LATEST REL=$REL PLAT=$PLAT \
            run_uninstall_install_TC_master.sh $HOST
        exit
    fi
}

# load vars last run with (in this directory)
# cluster .conf
[[ -e .runtc ]] && source .runtc
 
while [[ true ]] ; do
    echo while HOST=$HOST
    HOST=$HOST menu
    get_input in
    echo DEBUG in=$in
    after_input

    cat > .runtyc <<EOF
HOST=$HOST
ROOTUSER=$ROOTUSER
INSTALL_FROM_SLINGSHOT=$INSTALL_FROM_SLINGSHOT
INSTALL_LATEST=$INSTALL_LATEST
REL=$REL
PLAT=$PLAT
EOF

    eval $in
    export HOST
    export ROOTUSER
    export INSTALL_FROM_SLINGSHOT
    export INSTALL_LATEST
done
