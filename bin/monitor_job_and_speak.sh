#!/bin/bash

USERHOST=$1 
JDIR=$2
JOB=$3

shift 
shift
shift

[[ -z $USERHOST || -z $JDIR || -z $JOB ]] && {
  echo "usage: $0 user@host jenkinsjobsdir jobname"
  echo " e.g. monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_Staging"
  exit -1
} 

MYDIR=~/.monitor_job_and_speak
mkdir -p $MYDIR

mkdir -p $MYDIR/$JOB
[[ -e $MYDIR/$JOB/ls ]] && mv $MYDIR/$JOB/ls{,.OLD}
ssh $USERHOST ls -ltr --time-style long-iso $JDIR/$JOB/builds/ > $MYDIR/$JOB/ls
ssh $USERHOST cat $JDIR/$JOB/workspace/VERSION.txt > $MYDIR/$JOB/VERSION.txt 2>/dev/null || true

#drwxr-xr-x 3 jenkins jenkins 4096 Aug  7 14:34 1098
#lrwxrwxrwx 1 jenkins jenkins    4 Aug  7 14:48 lastFailedBuild -> 1099
#drwxr-xr-x 3 jenkins jenkins 4096 Aug  7 14:50 1099
#lrwxrwxrwx 1 jenkins jenkins    4 Aug  7 15:50 lastUnsuccessfulBuild -> 1100
#lrwxrwxrwx 1 jenkins jenkins    4 Aug  7 15:50 lastUnstableBuild -> 1100
#drwxr-xr-x 3 jenkins jenkins 4096 Aug  7 15:50 1100
#lrwxrwxrwx 1 jenkins jenkins    4 Aug  9 15:47 lastSuccessfulBuild -> 1101
#lrwxrwxrwx 1 jenkins jenkins    4 Aug  9 15:47 lastStableBuild -> 1101
#drwxr-xr-x 3 jenkins jenkins 4096 Aug  9 15:48 1101

LASTJOB=$(tail -1 $MYDIR/$JOB/ls |sed "s/.* //")
LASTJOBDATE=$(tail -1 $MYDIR/$JOB/ls | sed "s/  */ /g" |cut -d" " -f6- | sed "s/ \S*$//g")
LASTJOBSTATE=$(grep " $LASTJOB\$" $MYDIR/$JOB/ls | grep last |grep -v Successful| sed "s/.*last//;s/Build.*//")
[[ -z $LASTJOBSTATE ]] && LASTJOBSTATE="Running"
#echo "last job $LASTJOB"
#echo "last job date $LASTJOBDATE state $LASTJOBSTATE"

### watch out! $LASTJOBSTATE can end up as "Successful\nStable" or "Successful\nUntable"


LASTSTABLE=$(grep lastStableBuild $MYDIR/$JOB/ls | sed "s/.* //g")
LASTSTABLEDATE=$(grep " $LASTSTABLE\$" $MYDIR/$JOB/ls | sed "s/  */ /g" | grep -v last |cut -d" " -f6-8)
#echo "last stable job $LASTSTABLE"
#echo "last stable date $LASTSTABLEDATE"


#if verbose then say 
#echo "The latest $JOB job is number $LASTJOB." | tee $MYDIR/$JOB/verbose.txt
#echo "Job number $LASTJOB is $LASTJOBSTATE since $LASTJOBDATE." | tee -a $MYDIR/$JOB/verbose.txt
#echo "The last stable job was number $LASTSTABLE on $LASTSTABLEDATE" | tee -a $MYDIR/$JOB/verbose.txt


#if verbose/hourly . . .
#  if running then say:
#  "The latest yellowstone_QA_Staging job is number 1101. Job number 1101 is still running since datetime. "

if [[ -n $LASTJOB ]] && ! diff -u $MYDIR/$JOB/ls{,.OLD} ; then 
    echo "Something is different in the directory listing" | tee $MYDIR/$JOB/verbose.txt

    echo "The latest $JOB job is number $LASTJOB." | tee $MYDIR/$JOB/sayit.txt
    echo "Job number $LASTJOB is $LASTJOBSTATE since $LASTJOBDATE." | tee -a $MYDIR/$JOB/sayit.txt

    [[ -e $MYDIR/$JOB/VERSION.txt ]] && cat $MYDIR/$JOB/VERSION.txt  | tee -a $MYDIR/$JOB/sayit.txt

    if [[ $LASTJOBSTATE == "Stable" ]] ; then
        echo "Yahoo. $LASTJOBSTATE" | tee -a $MYDIR/$JOB/sayit.txt
        ## TODO: play fanfare
        ## TODO: flash lights
        ## TODO: release the golden streamers, doves, helium balloons, page #30 etc etc
        if [[ $JOB == yellowstone_QA_Staging ]] ; then
            #mplayer /home/jamesc/Music/GCTT.wav
            mplayer "/home/jamesc/Music/Glitch Cassidy - Input Output - 06 Throwing Toys.mp3"
        fi
        if [[ $JOB == yellowstone_QA_MEMLEAKTEST ||  $JOB == yellowstone_QA_MEMLEAKTEST_Retry ]] ; then
            mplayer /home/jamesc/Downloads/Richard_Wagner_-_Ride_of_the_Valkyries.ogg
        fi
        if [[ $JOB == yellowstone_QA_RUPTEST ]] ; then
            mplayer "/home/jamesc/Music/Glitch Cassidy - Input Output - 01 I Don't Know.mp3"
        fi
        
    fi

    if [[ $LASTJOB != $LASTSTABLE ]] ; then
        echo "The last stable job was number $LASTSTABLE on $LASTSTABLEDATE" | tee -a $MYDIR/$JOB/sayit.txt
    fi

    cat $MYDIR/$JOB/sayit.txt |festival --tts


    # if we are not happy linger here for a while
    if [[ $LASTJOBSTATE != "Stable" && $LASTJOBSTATE != "Running" ]] ; then
        if [[ $JOB == yellowstone_QA_Staging || 
                    $JOB == yellowstone_QA_MEMLEAKTEST || 
                    $JOB == yellowstone_QA_MEMLEAKTEST_Retry ||
                    $JOB == yellowstone_QA_RUPTEST ]] ; then
            for i in $(seq 12); do 
                echo "foo. $JOB is $LASTJOBSTATE. this is not pleasing." | tee -a $MYDIR/$JOB/sayit.txt | festival --tts
                sleep 10
            done
        fi
    fi


fi

#if [[ $LASTJOBSTATE == "still running" ]] ; then
#fi

#if that dir changed then say
#  "The latest yellowstone_QA_Staging job number 1101 is finished."
#  "job number 1101 is stable/unstable/failed"
#  if 1101 != stable
#   "The last stable build was xxxx on datetime"
# or
#  "The latest yellowstone_QA_Staging job number 1101 is running."
#  "build 1101 is running, last stable build is xxxx"





############## todo look @ VERSION.txt
## parse all VERSION.txt and get excited if nearing quorum

