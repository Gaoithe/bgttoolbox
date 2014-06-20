#!/bin/bash
# Run slime forest adventure, or install it if can't find it to run
# Support multiple users
# You will need to sudo

installdir=/usr/games
script=/bin/sfa

if [[ "$1" == "-uninstall" ]] ; then
  if [[ -e $script || -e $installdir/slimeforest ]] ; then
    echo I need to sudo now, enter your password if you can sudo, hit Ctrl-C if not.
    sudo rm -rf $installdir/slimeforest
    sudo rm -f $script
    if [[ -e $script || -e $installdir/slimeforest ]] ; then
	echo Something is still left behind
    else
	echo ":( you b&%$£! You uninstalled slimeforest :("
    fi
  fi
  exit;
fi

if [[ ! -e $installdir/slimeforest ]] ; then

    echo Can\'t find game?  Installing game to $installdir

    if [[ ! -e sfa.tgz ]] ; then
	echo Can\'t install without sfa.tgz in current directory.
	exit;
    fi
	
    # install the sfa script (THIS script)
    echo installing $0 to $script
    chmod 755 $0
    echo I need to sudo now, enter your password if you can sudo, hit Ctrl-C if not.
    sudo cp $0 $script
    if [[ ! -e $script ]] ; then
	echo I really REALLY need to sudo to get the permissions right I\'m afraid :-7
	exit;
    fi

    # unpack game to shared area
    sudo chmod 777 $installdir
    cp sfa.tgz $installdir/sfa.tgz
    cd $installdir/
    tar -zxvf sfa.tgz
    rm sfa.tgz

    # make an archive of playerdata for first time users 
    # directory permissions must allow all users to pack & unpack playerdata
    chmod 777 slimeforest/jquest
    cd slimeforest/jquest
    chmod 777 playerdata
    chmod 666 playerdata/*
    tar -zcvf playerdata.tgz playerdata/*

    echo Install finished.
    #exit;
fi

if [[ "$1" != "-fullscreen" && "$1" != "" ]] ; then
  echo usage: sfa [-fullscreen]
  echo run slime forest adventure game
  echo learn katakana, hiragana and kanji
  echo run in window or specify -fullscreen to run in full screen mode
  #read
  exit;
fi

echo Game should now start.
# change to where slime forest is installed
cd $installdir/slimeforest/jquest

username=`whoami`
if [[ -f $username.tgz ]] ; then
  # unpack tarfile of player's previous session
  tar -zxvf $username.tgz
else
  # first time user runs script
  # unpack tarfile of first time user playerdata
  tar -zxvf playerdata.tgz
fi

# run game in full screen or window
nohup ./jquest $1

# after game archive playerdata contents, overwriting existing archive
tar -zcvf $username.tgz playerdata/*
rm playerdata/*

exit;



