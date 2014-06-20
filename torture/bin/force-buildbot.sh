#!/bin/bash 

# see also http://slaine.ie.commprove.internal/~jcoleman/buildbot-cheat-quantiqa.html


# defaults:
BBURL=https://trac.commprove.internal/buildbot
#TTB=quantiqa 
#BNAME=full-${TTB}-x86-Win32
USER=${USER}_fbsh
COMMENT=

USAGE="usage: $(basename $0) [-n] [-2] [-T ticket] [-t thing [-t thing [...]]] [platform [platform [...]]] [-c comment] [-u user]
  -n:        do nothing, dummy run, show what commands would be called
  -2:        2 build requests in quick succession 
             for when primary buildbot is b0rked but still trying to build
              and when you have no access to this buildbot
  -T ticket:    no ticket => build trunk, otherwise ticket number (for branch)
  -t thing:  quantiqa(default) cal 3rdParty scm
  platform:  x64-SunOS x64-SunOS x64-Linux x86-Win32(default) x86-Linux

  e.g.
    # windows trunk build 2 requests sent
    force-buildbot.sh -2
    # windows #4567 ticket build 2 requests sent
    force-buildbot.sh -2 -T 4567
    # pre-merge test #4567 ticket all platforms
    force-buildbot.sh -T 4567 x64-SunOS x64-SunOS x64-Linux x86-Win32
    # pre-merge test #4567 ticket all platforms, cal 
    force-buildbot.sh -T 4567 -t cal x64-SunOS x64-SunOS x64-Linux x86-Win32

    
"

if [[ "$1" == "" ]] ; then
  echo "$USAGE"
  exit
fi


#while [[ "$1" != "" ]] ; do
while [[ "$1" != "" ]] ; do
    if [[ "$1" == "-n" ]] ; then
        DONOTHING=echo
    elif [[ "$1" == "-2" ]] ; then
        DOTWO=2
    elif [[ "$1" == "-t" ]] ; then
        TTB="$TTB${TTB+ }$2"
        shift
    elif [[ "$1" == "-T" ]] ; then
        #TICKET="$TICKET${TICKET+ }$2"
        TICKET="$2"
        shift
    elif [[ "$1" == "-c" ]] ; then
        COMMENT="$2"
        shift
    elif [[ "$1" == "-u" ]] ; then
        USER="$2"
        shift
    elif [[ "$1" == "${1#-}" ]] ; then
        PLATFORM="$PLATFORM${PLATFORM+ }$1"
    else
        echo "error: unknown option $1 ?"
        echo "$USAGE"
        exit
    fi
    shift
done

echo BBURL=$BBURL
echo DOTWO=$DOTWO

# default thing to build
[[ "$TTB" == "" ]] && TTB=quantiqa
echo TTB=$TTB

# empty BRANCH is trunk
[[ "$TICKET" != "" ]] && BRANCH=branches%2Fticket-$TICKET
echo BRANCH=$BRANCH

# default platform 
[[ "$PLATFORM" == "" ]] && PLATFORM=x86-Win32
echo PLATFORM=$PLATFORM


for t in $TTB ; do 
for p in $PLATFORM ; do 

   BNAME=full-${t}-${p}

    #  --no-check-certificate for other wget ? 1.10, 1.9 takes --sslcheckcert
   #cmd="wget --sslcheckcert=0 \"${BBURL}/${BNAME}/force?username=${USER}&comments${COMMENT}=&branch=${BRANCH}\""
   cmd="wget --no-check-certificate \"${BBURL}/${BNAME}/force?username=${USER}&comments${COMMENT}=&branch=${BRANCH}\""
   echo cmd=$cmd
   $DONOTHING $cmd
   [[ "$DOTWO" != "" ]] && $DONOTHING $cmd

done
done

exit;

================================================================================

# 2 build requests in quick succession for when primary buildbot is b0rked but still trying to build and when you have no access to this buildbot

wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"; wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"

# Thing To Build
TTB=quantiqa 
TTB=cal 
TTB=3rdParty 
TTB=scm

# build all quantiqa build types
TTB=quantiqa 

BNAME=full-${TTB}-x64-SunOS
wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"
BNAME=full-${TTB}-s64-SunOS
wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"
BNAME=full-${TTB}-x64-Linux
wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"
BNAME=full-${TTB}-x86-Win32
wget --sslcheckcert=0 "${BBURL}/${BNAME}/force?username=${COMMENT}&comments=&branch=${BRANCH}"
#BNAME=full-${TTB}-x86-Linux

