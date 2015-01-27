#!/usr/bin/perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/scm.pl,v 1.51 2013/09/11 22:03:34 aidan Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

package main;

my($ssh) = "ssh";
my($build_machine) = "builder";
my($builder) = "bob";
my($scm_root) = "/slingshot/sbe";
my($scm_dir);
my(%overrides) = ();
my(%cmd_arg_needs) = ();
my($cmd, $arg0, $arg1, $arg2, $auto_flag);
my($build_area) = "/homes/bob/build_area";
# $build_area = "/usr/bkelly/pooky/pooky/build_area";
my($base);
my($me) = `whoami`;
my($hostname) = `hostname`;
my($prunestr) = "";
my($i);

if($0 =~ /\//){
    ($base) = $0 =~ /^(.*)\/[^\/]*$/;
    push(@INC, "$base");
}

my($cvsroot) = $ENV{"CVSROOT"};
if(!defined($cvsroot)){
    print STDERR "\$CVSROOT is not setup for $me\@$hostname.\n";
    exit -1;
}
my($cvs_rsh) = $ENV{"CVS_RSH"};

if($cvsroot =~ /\@/){
    if(!defined($cvs_rsh)){
        print STDERR "\$CVS_RSH is not setup for $me\@$hostname though CVSROOT implies remote operation\n";
        exit -1;
    }
    if($cvs_rsh =~ /^ssh\.(\S+)$/){
        $build_machine = $1;
        $ssh = $cvs_rsh;
    }
}

sub yn{
    my($c);
    while(<STDIN>){
        chop;
        $c = $_;
        if($c =~ /^[yY]/){
            return 0;
        }
        elsif($c =~ /^[nN]/){
            return 1;
        }
        print "Please enter Y or N\n";
    }
}

sub bkwd_cmp {
    my($a1, $b1) = ($a, $b);

    if($b1 =~ /^v(\d)$/){
        $b1 =~ s/v/v0/;
    }
    if($a1 =~ /^v(\d)$/){
        $a1 =~ s/v/v0/;
    }
    $b1 cmp $a1;
}


sub get_dirs{
    my($root) = @_;
    my(@entries) = ();
    my(@dirs) = ();
    my($tmp);

    if(1){
        opendir(DIR, "$root");
        @entries = readdir(DIR);
        closedir(DIR);

        @entries = sort bkwd_cmp @entries;

        foreach $tmp (@entries){
            if(-d "$root/$tmp" && "$tmp" ne "." && "$tmp" ne ".."){
                push @dirs, $tmp;
            }
        }
    }
    else{
        # print "$root: ";

        open FIND, "$ssh $builder\@$build_machine find $root -type d -maxdepth 1 |" or
            die "Cannot kick off remote find on $build_machine: $!";
        while(<FIND>){
            $tmp = $_;
            chop $tmp;
            if("$tmp" ne "$root"){
                $tmp =~ s/^.*\///;
                push @dirs, $tmp;
                # print "$tmp ";
            }
        }
        # print "\n";
        @dirs = sort bkwd_cmp @dirs;
    }
    return @dirs;
}

sub find_latest{
    my($root) = @_;
    my(@dirs) = ();
    my(@entries) = ();
    my($majr, $minr, $plvl);

    @entries = get_dirs("$root");

    foreach $majr (@entries){
        if($majr =~ /^v\d$/ || $majr =~ /^v\d\d$/){
            @entries = get_dirs("$root/$majr");
            foreach $minr (@entries){
                if($minr =~ /^\d\d$/){
                    @entries = get_dirs("$root/$majr/$minr");
                    foreach $plvl (@entries){
                        if($plvl =~ /^\d\d$/){
                            return ($majr, $minr, $plvl);
                        }
                    }
                }
            }
        }
    }
    return ("", "", "");
}

sub get_release_dir{
    my($mf) = @_;
    my($rdir, $l);

    $rdir = "";

    if( -f $mf){
        open FP, "$mf" or die "Cannot open $mf: $! :";
        while (<FP>){
            $l = $_;
            chop $l;
            if($l =~ /^\s*#\s*RELEASE_DIR\s*=\s*(\S+)/){
               $rdir = $1;
           }
        }
        close FP;
    }

    return $rdir;
}

#$scm_dir = "/homes/brian/src/sbe";

if(!defined($scm_dir)){
    my($majr, $minr, $plvl) = find_latest($scm_root);
    if($majr eq ""){
        print STDERR "Failed to locate latest SCM root beneath '$scm_root'\n";
        exit(-1);
    }
    $scm_dir = "$scm_root/$majr/$minr/$plvl/scripts";
}

if ($#ARGV >= 1 && $ARGV[0] eq "-use"){
    shift;
    if(!($ARGV[0] =~ /^(v\d)-(\d\d)-(\d\d)$/)){
        print STDERR "-use vx-yy-zz (not $ARGV[0])\n";
        exit -1;
    }
    $scm_dir = "$scm_root/$1/$2/$3/scripts";
    shift;
}

require "crel.pl";
require "prerelease.pl";
require "release.pl";
require "modvers.pl";
require "rbuild.pl";
require "rpop.pl";
require "modules.pl";
require "pbuild.pl";
require "publish.pl";
require "patch-unlock.pl";

while($#ARGV >= 1 && $ARGV[0] eq "-disable"){
    $prunestr .= " " . $ARGV[0] . " " . $ARGV[1];
    shift;
    prune_arch($ARGV[0]);
    shift;
}

sub find_build_all{
    my($pwd);

    $pwd = `pwd`;
    chop $pwd;

    while(1){
        # print "PWD: $pwd\n";
        if(-f "$pwd/SCM.BUILD.ALL"){
            print "Y\n";
            exit 0;
        }
        if("$pwd" eq "/"){
            print "N\n";
            exit 0;
        }
        $pwd =~ s/\/[^\/]+$//;
        if("$pwd" eq ""){
            $pwd = "/";
        }
    }
}

sub find_mds_fakey_fakey{
    my($pwd, $mds_ff);

    $pwd = `pwd`;
    chop $pwd;

    while(1){
        # print "PWD: $pwd\n";

        $mds_ff = "$pwd/Makefile.slingshot.fakeyfakey";
        
        if(-f "$mds_ff"){
            print "$mds_ff\n";
            exit 0;
        }
        if("$pwd" eq "/"){
            print "\n";
            exit 0;
        }
        $pwd =~ s/\/[^\/]+$//;
        if("$pwd" eq ""){
            $pwd = "/";
        }
    }
}

sub need{
    my($req) = @_;
    if($#ARGV < $req){
        print STDERR "Insufficient arguments for $ARGV[0]\n";
        exit -1;
    }
}


###########################################################################

if($#ARGV < 0){
    print STDERR "Bogus params\n";
    exit -1;
}

$cmd_arg_needs{"-crel"} = 1;
$cmd_arg_needs{"-repop"} = 3;
$cmd_arg_needs{"-repop-with-tests"} = 3;
$cmd_arg_needs{"-prerelease"} = 1;
$cmd_arg_needs{"-release"} = 2;
$cmd_arg_needs{"-rpop"} = 1;
$cmd_arg_needs{"-modvers"} = 0;  # Handled differently
$cmd_arg_needs{"-release-list"} = 0;
$cmd_arg_needs{"-rbuild"} = 2;
$cmd_arg_needs{"-brbuild"} = 2;
$cmd_arg_needs{"-repop-rbuild"} = 2;
$cmd_arg_needs{"-repop-rbuild-with-tests"} = 2;
$cmd_arg_needs{"-find-build-all"} = 0;
$cmd_arg_needs{"-find-mds-fakey-fakey"} = 0;
$cmd_arg_needs{"-publish"} = 1;
$cmd_arg_needs{"-patch-unlock"} = 1;

while($ARGV[0] eq "-override"){
    need(2);
    if(!($ARGV[2] =~ /^v\d+-\d\d-\d\d$/)){
        print STDERR "Bogus version specification $ARGV[2]\n";
        exit -1;
    }
    my($ktmp) = $ARGV[1];
    $ktmp =~ s/\/$//g;

    $main::overrides{$ktmp} = $ARGV[2];

    print STDERR "Add override key '$ktmp' value $ARGV[2]\n";

    shift;
    shift;
    shift;
}


if($#ARGV >= 0 && $ARGV[0] =~ /^-/){
    if($ARGV[0] eq "-crel" ||
       $ARGV[0] eq "-prerelease" ||
       $ARGV[0] eq "-release" ||
       $ARGV[0] eq "-repop" ||
       $ARGV[0] eq "-repop-with-tests" ||
       $ARGV[0] eq "-rpop" ||
       $ARGV[0] eq "-modvers" ||
       $ARGV[0] eq "-release-list" ||
       $ARGV[0] eq "-rbuild" ||
       $ARGV[0] eq "-repop-rbuild" ||
       $ARGV[0] eq "-repop-rbuild-with-tests" ||
       $ARGV[0] eq "-brbuild" ||
       $ARGV[0] eq "-publish" ||
       $ARGV[0] eq "-patch-unlock" ||
       $ARGV[0] eq "-find-build-all" ||
       $ARGV[0] eq "-find-mds-fakey-fakey"){

        need($cmd_arg_needs{"$ARGV[0]"});


	if(defined($cmd)){
	    print STDERR "Multiple commands specified, '$cmd' and '$ARGV[0]'\n";
	    exit -1;
	}
	$cmd = $ARGV[0];

	if($cmd_arg_needs{"$ARGV[0]"} == 0){
        }
	elsif($cmd_arg_needs{"$ARGV[0]"} == 1){
	    $arg0 = $ARGV[1];
	    shift;
	}
	elsif($cmd_arg_needs{"$ARGV[0]"} == 2){
	    $arg0 = $ARGV[1];
	    $arg1 = $ARGV[2];
	    shift;
	    shift;
	}
	elsif($cmd_arg_needs{"$ARGV[0]"} == 3){
	    $arg0 = $ARGV[1];
	    $arg1 = $ARGV[2];
	    $arg2 = $ARGV[3];
	    shift;
	    shift;
	    shift;
	}
	else{
	    print "Can't handle needing $cmd_arg_needs{$ARGV[0]}\n";
            exit -1;
        }
    }
    else{
    }
}
else{
    print STDERR "Huh?\n";
    exit -1;
}

if(!defined($cmd)){
    print STDERR "No recognised command specified\n";
    exit -1;
}
if($cmd eq "-crel"){
    crel($arg0);
}
elsif($cmd eq "-release"){
    release($ssh,
            $builder,
            $build_machine,
            $scm_dir,
            $prunestr,
            $arg0,
            $arg1);
}
elsif($cmd eq "-publish"){
    publish($ssh,
            $builder,
            $build_machine,
            $scm_dir,
            $arg0,
            $arg1,
            @ARGV);
}
elsif($cmd eq "-patch-unlock"){
    patch_unlock($ssh,
                 $builder,
                 $build_machine,
                 $scm_dir,
                 $arg0,
                 @ARGV);
}
elsif($cmd eq "-prerelease"){
    prerelease($scm_dir, $arg0);
}
elsif($cmd eq "-repop"){
    repopulate($ssh,
               $builder,
               $build_machine,
               $scm_dir,
               $prunestr,
               $arg0,  # Module name
               $arg1,  # Version
               $arg2, # Workdir
               0);
}
elsif($cmd eq "-repop-with-tests"){
    repopulate($ssh,
               $builder,
               $build_machine,
               $scm_dir,
               $prunestr,
               $arg0,  # Module name
               $arg1,  # Version
               $arg2,  # Workdir
               1);
}
elsif($cmd eq "-rpop"){
    release_populate("FAKE", $arg0);
}
elsif($cmd eq "-modvers"){
    my($d);
    if(0){
        print STDERR "Global overrides(1a):\n";
        foreach $d  (keys %main::overrides){
            print STDERR "      $d $main::overrides{$d}\n";
        }
        print STDERR "**********************************************************************\n";
    }
    modvers(@ARGV);
}
elsif($cmd eq "-release-list"){
    my(@lines) = get_release_list();
    for($i = 0; $i <= $#lines; $i++){
        printf "%s\n", $lines[$i];
    }
}
elsif($cmd eq "-rbuild"){
    rbuild($build_area, $scm_dir, $arg0, $arg1, $cmd);
}
elsif($cmd eq "-brbuild"){
    rbuild($build_area, $scm_dir, $arg0, $arg1, $cmd);
}
elsif($cmd eq "-repop-rbuild"){
    rbuild($build_area, $scm_dir, $arg0, $arg1, $cmd);
}
elsif($cmd eq "-repop-rbuild-with-tests"){
    rbuild($build_area, $scm_dir, $arg0, $arg1, $cmd);
}
elsif($cmd eq "-find-build-all"){
    find_build_all();
}
elsif($cmd eq "-find-mds-fakey-fakey"){
    find_mds_fakey_fakey();
}

exit 0;

