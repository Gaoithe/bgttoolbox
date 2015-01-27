#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/patch-unlock.pl,v 1.1 2009/08/18 20:41:16 brian Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

sub patch_unlock{
    my($ssh, $builder, $build_machine, $scm_dir, $pname, @argv) = @_;
    my($patch_dir, $i, $user, $via_ssh, $rc, $sig, $subject, $to);
    my($home)=$ENV{"HOME"};
    my($rcmd) = "$ssh $builder\@$build_machine";
    my($verbose) = 0;

    $user = "";
    $via_ssh = 0;

    for($i = 1; $i <= $#argv; $i++){
        if("$argv[$i]" eq "-user"){
            $user = $argv[$i+1];
            $i++;
        }
        elsif("$argv[$i]" eq "-via_ssh"){
            $via_ssh = 1;
        }
        else{
            print STDERR "Unexpected extra argument: '$argv[$i]'\n";
            exit -1;
        }
    }

    if("$user" eq ""){
        my($cvsroot) = $ENV{"CVSROOT"};
        if(!defined($cvsroot)){
            print STDERR "\$CVSROOT is not setup in the environment. Bailing\n";
            exit -1;
        }
        if(!($cvsroot =~ /ext:(\S+)\@/)){
            print STDERR "Cannot workout user from '$cvsroot' (expected ...ext:XXX\@...)\n";
            exit -1;
        }
        
        $user = $1;
    }

    if(! -f "/slingshot/.this-is-iowa"){
        print STDERR "This must be run from a system that has /slingshot mounted from iowa\n";
        exit -1;
    }

    $patch_dir = "/slingshot/PATCHES/$pname";
    if(! -d "$patch_dir"){
        print STDERR "Patch directoty '$patch_dir' doesn't exist\n";
        exit -1;
    }

    if(! -f "$patch_dir/LATEST/CANDIDATE"){
        print STDERR "Current patch doesn't seem to be a candidate\n";
        exit -1;
    }
    if(-f "$patch_dir/LATEST/CANDIDATE.UNLOCKED"){
        print STDERR "Current patch is already unlocked\n";
        exit -1;
    }

    if($via_ssh == 0){
        $rc = system("$ssh", 
                     "$builder\@$build_machine", 
                     "$scm_dir/scm.pl",
                     "-patch-unlock",
                     "$pname",
                     "-user", "$user",
                     "-via_ssh");
        $rc >>= 8;
        if($rc == 0){
            $sig = "";
            if(-f "$home/.sig"){
                if(open FP, "$home/.sig"){
                    while(<FP>){
                        $sig .= $_;
                    }
                    close FP;
                }
            }

            $subject = sprintf "[RELEASE] Candidate patch for $pname has been unlocked and can be re-released";

            
            $to = "release-targets";

            if(0){
                $subject = sprintf "[ELEASE] Candidate patch for $pname has been unlocked and can be re-released";
                $to = "brian.kelly";
            }
            open MAIL, "| $ssh $user\@$build_machine mail -s \\'$subject\\' $to\@openmindnetworks.com" or die "Failed to send automatic mail: $!";
            print MAIL "<EOM>\n";
            print MAIL "$sig\n";
            close MAIL;
            if($? != 0){
                print STDERR "Seemed to fail sending automatic mail\n";
                $rc = -1;
            }
        }
        exit $rc;
    }
    $rc = 0;

    `chmod +w $patch_dir/LATEST/`;
    $rc |= $?;

    `touch $patch_dir/LATEST/CANDIDATE.UNLOCKED`;
    $rc |= $?;

    `chmod a-w $patch_dir/LATEST/`;
    $rc |= $?;

    exit $rc;
}
    
return 1;
