#!/bin/sh
usage(){
	echo "Usage: buildall.sh [{-start|-start-after} mod] [-oneshot mod] [{-stop|-stop-after} mod] {clean|spotless|all|modvers|status|status1}"
}

MODLIST="mod.list"
OVERRIDES=""
QALL=0
ERROR=0

# problematic -z9 argument to cvs for james@nebraska -> ssh james@iowa cvsroot
MZ9=-z9
MZ9=

if [ ! -f "PURPOSE" ]; then
    echo "You *must* have a PURPOSE file beside mod.list"
    exit -1;
fi

if [ "$1" = "-sbe" ]; then
    SCM="$2/scripts/scm.pl"
    shift
    shift
fi

while [ "$1" = "-override" ]; do
    if [ $# -lt 3 ]; then
	echo "Insufficient args for -override"
	exit -1
    fi
    OVERRIDES="$OVERRIDES $1 $2 $3"
    shift
    shift
    shift
    echo "OVERRIDES: $OVERRIDES"
done

if [ "$1" = "-modlist" ]; then
    MODLIST=$2
    shift
    shift
fi

if [ "$1" = "-quick" ]; then
    QALL=1
    shift
fi

if [ "$1" = "-quick" ]; then
    QALL=1
    shift
fi

if [ ! -f $MODLIST ]; then
    echo "$MODLIST does not exist"
    exit -1
fi

grep "BRANCH-NAME" $MODLIST >/dev/null
if [ $? -eq 0 ]; then
    BRANCH=`grep "BRANCH-NAME" $MODLIST | sed -e 's/.*BRANCH-NAME//' | awk '{print $1}'`
    BRANCH_ARGS="-r $BRANCH"
else
    BRANCH=""
    BRANCH_ARGS=""
fi

SKIPS="TOMCAT|MOS-WEB|JBOSS|openldap-pkg"
SKIPS="MOS-WEB|JBOSS|openldap-pkg"

MODS=`cat $MODLIST | grep -v '#' | egrep -v  $SKIPS | sed -e 's/ .*//'`;
MOD1=`cat $MODLIST | grep -v '#' | egrep -v  $SKIPS | sed -e 's/ .*//' | head -1`;
MOD99=""
MSG=""
TF=/tmp/buildall.$$
TF1=/tmp/buildall.1.$$
echo logfiles $TF and $TF1

banner(){
    echo
    echo
    echo "###############################################################"
    echo "                       $1"
    echo "###############################################################"
}

do_checkout(){
    if [ "$BRANCH_ARGS" = "" ]; then
	MINUS_R=`egrep "$1 " $MODLIST | (read mod ver; if [ "$ver" != "" ]; then echo "-r $ver"; fi)`;
    else
	MINUS_R="$BRANCH_ARGS"
    fi
    # echo "BRANCH ARGS for $1: '$MINUS_R'"
    echo cvs -Q $MZ9 co $MINUS_R $1
    cvs -Q $MZ9 co $MINUS_R $1
}

do_mod_spo_all(){
    (cd $1; $SCM $OVERRIDES -modvers -workarea $WA . >Module.versions; gmake spotless; gmake_all $1; exit $?)
}

gmake_all(){
    if [ $QALL -ne 0 ]; then
	if [ -f tests/Makefile ]; then
	    tmp=`perl -e "require \"/slingshot/sbe/LATEST/scripts/needs_tests.pl\"; printf \"%d\n\", needs_tests(\"$1\");"`
	    tmp=`expr $tmp`;
	    if [ $tmp -eq 0 ]; then
		cp tests/Makefile tests/Makefile.orig
		cat tests/Makefile.orig | sed -s 's/^all:/old-all:/' >tests/Makefile
		echo "all:" >tests/Makefile
	    fi
	fi
    fi
    gmake all __FAKE_RELEASE_AREA
    rc=$?
    if [ $QALL -ne 0 ]; then
	if [ -f tests/Makefile.orig ]; then
	    mv tests/Makefile.orig tests/Makefile
	fi
    fi
    exit $rc
}



if [ $# != 1 -a $# != 3 -a $# != 5 ]; then
	usage
	exit -1
fi

FIN=0

check_mod(){
    CHKFND=0
    for d in $MODS; do
	if [ "$d" == "$1" ]; then
	    CHKFND=1
	fi
    done

    if [ $CHKFND -eq 0 ]; then
	echo "Unknown module $1"
	exit -1
    fi
}

while [ $FIN -eq 0 -a $# -gt 1 ]; do
    FIN=1
    if [ "$1" == "-start" ]; then
	check_mod $2
	MOD1="$2"
	shift
	shift
	FIN=0;
    fi
    if [ "$1" == "-start-after" ]; then
	check_mod $2
	MOD1=""
	MOD1A="$2"
	shift
	shift
	FIN=0;
    fi
    if [ "$1" == "-stop" ]; then
	check_mod $2
	MOD99="$2"
	shift
	shift
	FIN=0;
    fi
    if [ "$1" == "-stop-after" ]; then
	check_mod $2
	MOD99A="$2"
	shift
	shift
	FIN=0;
    fi
    if [ "$1" == "-oneshot" ]; then
	check_mod $2
	MOD1="$2"
	MOD99A="$2"
	shift
	shift
	FIN=0;
    fi
    if [ $FIN -ne 0 ]; then
	echo "Huh: $1"
	usage
	exit -1
    fi
done

if [ $# != 1 ]; then
	usage
	exit -1
fi

STARTED=0
M1=""
# echo "MODS: $MODS"
for d in $MODS; do
    if [ "$d" == "$MOD1" ]; then
	# echo "Starting: $d"
	STARTED=1
    fi
    if [ "$d" == "$MOD99" ]; then
	# echo "Stopping: $d"
	STARTED=0
    fi
    if [ $STARTED -ne 0 ]; then
	M1="$M1 $d"
    fi
    if [ "$d" == "$MOD99A" ]; then
	STARTED=0
    fi
    if [ "$d" == "$MOD1A" ]; then
	# echo "Starting: $d"
	STARTED=1
    fi
done
MODS=$M1
# echo $MOD99
# echo $MODS

WA=`pwd`
if [ "$SCM" = "" ]; then
    SCM=/slingshot/sbe/LATEST/scripts/scm.pl
fi
#SCM="perl /usr/brian/wa-1/sbe/scm.pl"
#
# MOS-base
#


if [ "$1" == "spotless" -o "$1" == "clean" ]; then
    M1=""
    for m in $MODS; do
	M1="$m $M1"
    done
    MODS=$M1
fi

# echo "Arg: $1"
if [ "$1" = "autoci" ]; then
    echo -n "Enter a release message: "
    cat >/tmp/CHANGES.msg
fi
top_banner=0

case "$1" in 
    metalist)
        top_banner=-1
	;;
    autoci|patch-release|checkout|all|spotless|clean|modvers|metaclean|spo-all|mod-spo-all|co-mod-spo-all)
        top_banner=1
	;;
    status|update|status1|status2|status3|list|digraph)
        top_banner=0
        ;;
    co)
        top_banner=1
        ;;
    *)
        echo "$1 not accounted for in top_banner calculation"
	;;
esac;

rm -f buildall.error

case "$1" in 
    status|update|status1|status2|status3)
        [[ -e cvs.${1} ]] && mv cvs.${1} cvs.${1}.older
        ;;
esac;

if [ "$1" = "digraph" ]; then
    echo "digraph scooby {"
    echo "   {"
    echo "       rank =\"same\";"
    echo "       \"Scooby-Dooby-Doo\"";
    echo "   };"
fi


for d in $MODS; do
    if [ $top_banner -gt 0 ]; then
	banner $d
    fi

    touch $TF

    case "$1" in 
	autoci)
            (
		cd $d;
		head -1 CHANGES | sed -e 's/-/ /g' | (read a b c; c=`expr $c + 1`; if [ $c -lt 10 ]; then c="0$c"; fi; echo "$a-$b-$c") >/tmp/CHANGES.tmp
		echo -n "	" >>/tmp/CHANGES.tmp
		cat /tmp/CHANGES.msg >>/tmp/CHANGES.tmp
		echo >>/tmp/CHANGES.tmp
		cat CHANGES >>/tmp/CHANGES.tmp
		mv /tmp/CHANGES.tmp CHANGES
		echo cvs -Q commit -m "`cat /tmp/CHANGES.msg`" .
		cvs -Q commit -m "`cat /tmp/CHANGES.msg`" .
	    )
            ;;
	metalist)
            (
		echo cvs -Q $MZ9 co -p $d/Makefile
		rd=`cvs -Q $MZ9 co -p $d/Makefile 2>/dev/null | grep RELEASE_DIR | sed -e 's/^[^\/]*\//\//'`
		if [ -d "$rd/LATEST/RPMS" ]; then
		    echo $d
		fi
	    )
            ;;
	update)
            #echo cvs -Q $MZ9 update $d redirect $TF1
            #(cd $d; cvs -Q $MZ9 update . ) >$TF1;
            echo cvs -q $MZ9 update $d redirect $TF1
            (cd $d; cvs -q $MZ9 update . ) > $TF1;
	    rc=$?
	    grep -v '^?' $TF1 |tee $TF
            cat $TF | sed "s# # $d\/#" >> cvs.update
	    if [ $rc -eq 0 ]; then
		/bin/true
	    else
		/bin/false
	    fi
            ;;
	co)
	    do_checkout $d
            ;;
	patch-release)
            /slingshot/sbe/LATEST/scripts/scm.pl -release $d patch 
            ;;
	list)
	    echo $d
	    ;;
	status)
            echo cvs -q $MZ9 status $d
            (cd $d; cvs -q $MZ9 status . 2>/dev/null | grep Status: | grep -v Up-to-date; exit 0) |tee $TF
            cat $TF |grep -v '^?' | sed "s# # $d\/#" >> cvs.status
            ;;
	status1)
            echo cvs -q $MZ9 status $d
            (cd $d; cvs -q $MZ9 status . 2>/dev/null | grep Status: | egrep -v "Up-to-date|Patch"; exit 0) |tee $TF
            cat $TF |grep -v '^?' | sed "s# # $d\/#" >> cvs.status1
            ;;
	status2)
            echo cvs -nq $MZ9 up -d -P $d
            (cd $d; cvs -nq $MZ9 update -d -P . 2>/dev/null; exit 0) |tee $TF
            cat $TF |grep -v '^?' | sed "s# # $d\/#" >> cvs.status2
            #cat $TF >> cvs.status2
            ;;
	status3)
            echo cvs -nq $MZ9 up -d -P $d
            (cd $d; cvs -nq $MZ9 update -d -P . 2>/dev/null |grep -v ^?; exit 0) |tee $TF
            cat $TF |grep -v '^?' | sed "s# # $d\/#" >> cvs.status3
            ;;
	checkout)
	    do_checkout $d
            ;;
	spotless|clean)
            (cd $d; gmake $1; exit 0)
	    ;;
	metaclean)
            (cd $d; rm -rf RPMS __clarity __modlist Metaversions; exit 0)
	    ;;
	all)
            (cd $d; gmake_all $d; exit $?)
	    ;;
	co-mod-spo-all)
	    do_checkout $d
	    do_mod_spo_all $d
	    ;;
	mod-spo-all)
	    do_mod_spo_all $d
	    ;;
	spo-all)
            (cd $d; gmake spotless; gmake_all $d; exit $?)
	    ;;
	modvers)
	   
	    (cd $d; $SCM $OVERRIDES -modvers -workarea $WA . >Module.versions; exit $?)
	    ;;
	cp)
	    (cd $d; if [ -d RPMS ]; then ls -1 RPMS/*.rpm; cp RPMS/*.rpm ~/tmp; fi) >$TF 2>&1
	    ;;
	digraph)
	    cat $d/Module.versions | grep "=`pwd`" | sed -e "s!.*=$PWD/!!" |(
		while read A; do
		    echo "    \"$d\" -> \"$A\";";
		done
	    )
	    ;;
	*)
	    usage
	    exit -1;
	    ;;
    esac;
    if [ $? -ne 0 ];  then
	echo "###############################################################" |tee -a buildall.error
	echo "        Error/Bailed while performing $1 in $d"|tee -a buildall.error
	echo "###############################################################"|tee -a buildall.error
	if [ "$1" != "update" ] ; then
            exit -1
        else
	    grep -v '^?' $TF1 |tee -a buildall.error
            ERROR=1
        fi
    fi

    v=`wc -l $TF | awk '{print $1}'`
    v=`expr $v`

    if [ $v -gt 0 ]; then
	if [ $top_banner -eq 0 ]; then
	    banner $d
	fi
	cat $TF
    fi
    rm -f $TF
    rm -f $TF1

done

case "$1" in 
    update|status|status1|status2|status3)
        echo "Local CHANGES see cvs.$1.Lchanges Local and Remote CHANGES (excluding CHANGES and Module.versions.release) see cvs.$1.LRchanges"
        grep -v ^[UP] cvs.$1 > cvs.$1.Lchanges
        echo =============== Local and Remote Changes in cvs.$1.LRchanges{.HIST} =================
        grep -Ev "(CHANGES|Module.versions.release)$" cvs.$1 |tee cvs.$1.LRchanges
        date >> cvs.$1.LRchanges.HIST
        cat cvs.$1.LRchanges >> cvs.$1.LRchanges.HIST
        date >> cvs.$1.HIST
        cat cvs.$1 >> cvs.$1.HIST
        ;;
esac;


if [ "$1" = "digraph" ]; then
    echo "}"
fi

if [ -e buildall.error ] ; then
    cat buildall.error
fi

if [ $ERROR -eq 1 ] ; then
    exit -1
fi

exit 0



