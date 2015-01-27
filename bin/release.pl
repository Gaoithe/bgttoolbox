#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/release.pl,v 1.60 2010/07/21 10:31:26 cormac Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

sub auto_check{
    my($tswitch) = @_;
    if("$tswitch" eq "auto" || "$tswitch" eq "semi-auto" || "$tswitch" eq "auto-need-tag"){
        return 1;
    }
    return 0;
}

sub sanitise_env{
    my($cvsroot) = $ENV{"CVSROOT"};
    if(!defined($cvsroot)){
        print STDERR "\$CVSROOT is not setup in the environment. Bailing\n";
        exit -1;
    }
    my($term) = $ENV{"TERM"};
    if(!defined($term)){
        print STDERR "\$TERM is not defined.\n";
        exit -1;
    }
    # print "TERM: $term\n";
    my($lines) = $ENV{"LINES"};
    if(!defined($lines)){
        print STDERR "\$LINES is not defined.\n";
        exit -1;
    }
    my($columns) = $ENV{"COLUMNS"};
    if(!defined($columns)){
        print STDERR "\$COLUMNS is not defined.\n";
        exit -1;
    }

    return($cvsroot, $term, $lines, $columns);
}

sub get_build_lock{
    my($ssh, $builder, $build_machine, $mod) = @_;
    my($tmp, $token);
    my($me) = `whoami`;
    my($host) = `hostname`;
    my($gotit);
    my($tmpfile, $elapsed);
    my(@atmp);

    chop $host;

    $host =~ s/\..*//g;

    if(-x "/usr/ucb/whoami"){
        $me = `/usr/ucb/whoami`;
    }
    else{
        $me = `whoami`;
    }
    chop $me;

    $tmpfile = sprintf ".%s.%s.%s", $me, $host, $$;

    for($gotit = 0; $gotit == 0;){
        $token = sprintf "%s %s %s %d", $me, $host, $mod, time();
        $tmp = `$ssh $builder\@$build_machine cat BUILD.TOKEN 2>/dev/null`;
        if($? != 0){
            `$ssh $builder\@$build_machine "echo $token >$tmpfile; if ln $tmpfile BUILD.TOKEN 2>/dev/null; then rm $tmpfile; else rm $tmpfile; exit -1; fi"`;
            if($? == 0){
                $gotit = 1;
            }
        }
        else{
            chop $tmp;
            (@atmp) = split /\s+/, $tmp;
            $tmp = time() - $atmp[3];

            $elapsed = sprintf "%02d:%02d:%02d",
              int($tmp / 3600),
                int($tmp / 60) % 60,
                  $tmp % 60;

            printf "Waiting for %s building %s from %s started %s ago\r",
              $atmp[0],
                $atmp[2],
                  $atmp[1],
                    $elapsed;
            `sleep 1`;
        }
    }
    printf "%78s\r", "";}

sub release_build_lock{
    my($ssh, $builder, $build_machine) = @_;

    `$ssh $builder\@$build_machine rm BUILD.TOKEN 2>/dev/null`;
    
    if($? != 0){
        print STDERR "Zoikes, removing BUILD.TOKEN from build machine failed\n";
    }
}

sub wkdir_sanity_check{
    my($wkdir) = @_;
    my($f, $l, $s, $i, $err);

    $err = 0;

    if( ! -d $wkdir ){
        print STDERR "$wkdir is not a directory\n";
        exit -1;
    }

    foreach $f ("Makefile", "Module.versions.template", "Module.versions.release", "CHANGES", "Deliverables"){
        if(! -f "$wkdir/$f"){
            print STDERR "Expected file '$wkdir/$f' missing in $wkdir\n";
            exit -1;
        }
    }

    if (! -d "$wkdir/CVS"){
        print STDERR "Hmmm, directory '$wkdir' doesn't look like a CVS work area\n";
        exit -1;
    }

    open FP, "cvs -Q -z9 status $wkdir |" or die "Cannot run cvs command: $! :";
    while (<FP>){
        $l = $_;
        chop $l;

        if((($f, $s) = $l =~ /^File:\s+(\S+)\s+Status:\s+(\S.*)$/) == 2){
            if("$s" ne "Up-to-date"){
                print STDERR "File: $wkdir/$f is not 'Up-to-date'\n";
                $err++;
            }
        }
    }
    close FP;

    open FP, "cvs -q -n -z9 update $wkdir |" or die "Cannot run cvs command: $! :";
    $i = 0;
    while (<FP>){
        $l = $_;
        chop $l;

        if($l =~ /^\?/){
            next;
        }

        $i++;

        print STDERR "$l\n";
    }
    close FP;

    if($i != 0){
        print STDERR "Doesn't look like $wkdir is up to date\n";
        $err = 1;
    }

    if($err){
        exit -1;
    }
}

sub release{
    my($ssh, $builder, $build_machine, $scm_dir, $prunestr, $wkdir, $tswitch) = @_;
    my($f, $l, $s, $rdir, $majr, $minr, $plvl, $c_majr, $c_minr, $c_plvl);
    my($vers, $done, $tmp, $tag, $tag2, $err, $mail_txt, $line, $subject, $rc);
    my($sig, $auto_flag, $started, $branch_name, $branch_tree, $branch_base);
    my($branch_d1, $branch_d2, $branch_d3, $branch_d4, $i, $base_tag, $c_tag);
    my($omn_user, $remote_dir, $rpm_rev, $rbuild, $last_tag);
    my($home)=$ENV{"HOME"};
    my($rcmd) = "$ssh $builder\@$build_machine";
    my(@trqs) = ();
    my(@bugs) = ();
    my(%trq_hash) = ();
    my(%bug_hash) = ();
    my($cvsroot, $term, $lines, $columns);

    $branch_name = "";

    ($cvsroot, $term, $lines, $columns) = sanitise_env();

    if(!($cvsroot =~ /ext:(\S+)\@/)){
	print STDERR "Cannot workout OMN user from '$cvsroot' (expected ...ext:XXX\@...)\n";
	exit -1;
    }

    $omn_user = $1;

    if(0){
        print "CVSROOT: $cvsroot\n";
        print "   TERM: $term\n";
        print "  LINES: $lines\n";
        print "COLUMNS: $columns\n";
        print "  wkdir: $wkdir\n";
        print "tswitch: $tswitch\n";
        exit 0;
    }
       
    $tag2 = "";
    $err = 0;
    $rc = 0;
    $auto_flag = 0;

    wkdir_sanity_check($wkdir);

    if(!(open FP, "$wkdir/CHANGES" )){
        print STDERR "Failed to open CHANGES file for analysis\n";
        exit -1;
    }
    
    $done = 0;
    $tmp = "";
    while(<FP>){
        chop;
        $line = $_;
        if($done == 0){
            if(!($line =~ /^\s+/ || $line eq "") && $tmp ne ""){
                $done = 1;
            }
            else{
                $tmp .= $line . " ";
            }
        }
    }
    close FP;

    $tmp =~ tr/[a-z]/[A-Z]/;

    while(($tmp =~ /(TRQ|BUG)[\# :]*(\d+)/) != 0){
        if("$1" eq "TRQ" && !defined($trq_hash{"$2"})){
            push @trqs, $2;
            $trq_hash{"$2"} = 1;
            print "Found TRQ $2\n";
        }
        elsif("$1" eq "BUG" && !defined($bug_hash{"$2"})){
            push @bugs, $2;
            $bug_hash{"$2"} = 1;
            print "Found BUG $2\n";
        }
        $tmp =~ s/(TRQ|BUG)//;
    }
    
    if( -f "$wkdir/BRANCH.INFO" && "$tswitch" ne "auto"){
        #
        # It is a BRANCH and *not* an AUTO release. Make sure at
        # least 1 TRQ is referenced. 
        #

        if($#trqs  == -1){
            print STDERR "At least one TRQ must be mentioned in BRANCH CHANGES files\n";
            exit -1;
        }
    }

    $rdir = get_release_dir("$wkdir/Makefile");

    if($rdir eq ""){
        print STDERR "No '# RELEASE_DIR = XXX' like in $wkdir/Makefile\n";
        exit -1;
    }

    get_build_lock($ssh, $builder, $build_machine, $wkdir);
    
    if( -f "$wkdir/BRANCH.INFO"){
        open FP, "$wkdir/BRANCH.INFO" or die "Failed to open $wkdir/BRANCH.INFO: $!";
        while(<FP>){
            chop;
            $line = $_;
            if($line =~ /^\s*\#/){
                next;
            }
            if($line =~ /^\s*$/){
                next;
            }
            if($line =~ /^\s*NAME\s*=\s*(\S+)/){
                $branch_name = $1;
            }
            elsif($line =~ /^\s*BASE\s*=\s*(v\d-\d\d-\d\d-[a-z]00)/){
                $branch_base = $1;
            }
            else{
                print STDERR "Unexpected line '$line' in BRANCH.INFO\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
        }
        close FP;
        if(!defined $branch_name){
            print STDERR "Never encountered 'NAME = XXX' line in BRANCH.INFO\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }
        if(!defined $branch_base){
            print STDERR "Never encountered 'BASE = XXX' line in BRANCH.INFO\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }
        $base_tag = $branch_base;
        $branch_base =~ s/\-/\//g;
        $branch_d1 = "$rdir/$branch_base";
        $branch_d1 =~ s/\/[a-z]00$//;
        $branch_d2 = "$branch_d1/BRANCHES";
        $branch_d3 = "$rdir/$branch_base";
        $branch_d3 =~ s/([a-z])00$/BRANCHES\/$1/;
        $branch_d4 = "$branch_d3" . "00";
        

        `$rcmd "[ -d $branch_d2 ]"`;
        if($?){
            print "No BRANCHES directory, first time this module has been branched [y/n]: ";
            if(auto_check("$tswitch") == 0){
                if(yn != 0){
                    print "Aborting\n";
                    release_build_lock($ssh, $builder, $build_machine);
                    exit -1;
                }
            }
            else{
                print "Y\n";
            }
            `$rcmd "chmod +w $branch_d1; mkdir $branch_d2; chmod a-w $branch_d1; chmod a+rx $branch_d2"`;
            if($? != 0){
                print "Failed to create $branch_d1 directory\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
        }

        $last_tag = "";
        $tmp = $base_tag;
        $tmp =~ s/00$//;
        open FP, "cvs -Q -z9 log $wkdir/CHANGES |" or die "Cannot run cvs command: $! :";
        while (<FP>){
            $l = $_;
            chop $l;
            if($l =~ /^\s+($tmp\d\d):\s/){
                if("$last_tag" eq ""){
                    $last_tag = $1;
                }
                elsif("$last_tag" lt "$1"){
                    $last_tag = $1;
                }
            }
        }
        close FP;
        if("$last_tag" eq ""){
            $tag = $base_tag;
        }
        else{
            if((($tag, $tmp) = $last_tag =~ /^(.*)(\d\d)$/) == 0){
                print STDERR "Zoikes, cannot get branch number from '$last_tag'\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
            if(auto_check("$tswitch") == 0){
                $tmp = int($tmp) + 1;
            }
            else{
                $tmp = int($tmp);
            }
            # print "Next val: $tmp\n";
            $tag = sprintf "$tag%02d", $tmp;
            # print "Next tag: $tag\n";
        }
        
        if("$tag" eq "$base_tag"){
            print "Initial release of this branch [y/n]: ";
            if(auto_check("$tswitch") == 0){
                if(yn != 0){
                    print "Aborting\n";
                    release_build_lock($ssh, $builder, $build_machine);
                    exit -1;
                }
            }
            else{
                print "Y\n";
            }
        }

        $l = `head -1 $wkdir/CHANGES`;
        if($? != 0){
            print STDERR "Can't 'head' the CHANGES file\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }
        
        if((($c_tag) = $l =~ /^(v\d-\d\d-\d\d-[a-z]\d\d)/) == 0){
            print STDERR "Can't grok the CHANGES file\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }

        if("$c_tag" ne "$tag"){
            print STDERR "CHANGES implies '$c_tag' release area implies '$tag'\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }

        print "New release is $tag [y/n]: ";
        if(auto_check("$tswitch") == 0){
            if(yn != 0){
                print "Aborting\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
            if(check_tag($wkdir, $tag, 0) != 0){
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }

            `cvs -Q -z9 tag  $tag $wkdir`;
            if($? != 0){
                print STDERR "Failed to add tag '$tag' to $wkdir\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
        }
        else{
            if($tswitch eq "semi-auto"){
                $auto_flag = 2;
            }
            else{
                $auto_flag = 1;
            }
            print "Y\n";
            if($tswitch eq "auto-need-tag"){
                `cvs -Q -z9 tag $tag $wkdir`;
                if($? != 0){
                    print STDERR "Failed to add tag '$tag' to $wkdir\n";
                    release_build_lock($ssh, $builder, $build_machine);
                    exit -1;
                }
            }
            if(check_tag($wkdir, $tag, 1) == 0){
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }

        }

    }
    elsif(auto_check("$tswitch") == 0){
        while(1){
            $vers = `$rcmd perl $scm_dir/scm.pl -crel $rdir`;
            if($? != 0){
                print STDERR "Failed to locate current release directory\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
                
            }
            ($majr, $minr, $plvl) = $vers =~ /^\s*(\S+)\s+(\S+)\s+(\S+)/;

            $remote_dir = "$rdir/$majr/$minr/$plvl";

            $tag = "$majr-$minr-$plvl";
            $tmp = do_cand_check("$rcmd", 
                                 "$remote_dir",
                                 "$tag",
                                 "$wkdir");
            if($tmp < 0){
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }

            if($tmp == 0){
                # No Tag removed, press on
                last;
            }
        }

        $l = `head -1 $wkdir/CHANGES`;
        if($? != 0){
            print STDERR "Can't 'head' the CHANGES file\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }
        
        if((($c_majr, $c_minr, $c_plvl) = $l =~ /^(v\d)-(\d\d)-(\d\d)/) != 3){
            print STDERR "Can't grok the CHANGES file\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }

        if($majr eq "*"){
            
            print "No existing release so this release is v1-00-00 [y/n]: ";
            if(yn != 0){
                print "Aborting\n";
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
            $majr = "v1";
            $minr = "00";
            $plvl = "00";
        }
#        else if($rdir =~ /^\/slingshot\/PATCHES\//){   
#            $plvl = sprintf "%02d", $plvl + 1;
#            print "This a release in the PATCHES tree.\n";
#            print "New version will be: $majr-$minr-$plvl Ok? ";
#            if(yn != 0){
#                print "Aborting\n";
#                 release_build_lock($ssh, $builder, $build_machine);
#                exit -1;
#            }
#        }
        else{
            for($done = 0; ! $done;){
                print "Current release: $majr-$minr-$plvl\n";

                print "What type of release is this [major/minor/patch]: ";
                if($tswitch ne ""){
                    $l = $tswitch;
                    print "$l\n";
                }
                else{
                    $l = <STDIN>;
                    chop $l;
                }
                if($l eq "major"){
                    ($tmp) = $majr =~ /v(\d+)/;
                    $majr = sprintf "v%d", $tmp + 1;
                    $minr = "00";
                    $plvl = "00";
                    $done = 1;
                }
                elsif($l eq "minor"){
                    $minr = sprintf "%02d", $minr + 1;
                    $plvl = "00";
                    $done = 1;
                }
                elsif($l eq "patch"){
                    $plvl = sprintf "%02d", $plvl + 1;
                    $done = 1;
                }
                if($done == 0){
                    print STDERR "You must specify one of patch/minor/major\n";
                    release_build_lock($ssh, $builder, $build_machine);
                    exit(-1);
                }
            }
        }
        
        if("$majr-$minr-$plvl" ne "$c_majr-$c_minr-$c_plvl"){
            print STDERR "CHANGES implies: $c_majr-$c_minr-$c_plvl\n";
            print STDERR "  You asked for: $majr-$minr-$plvl\n";
            print STDERR "Sort it out\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }

        $tag = "$majr-$minr-$plvl";

        if(check_tag($wkdir, $tag, 0) != 0){
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }

        if($rdir =~ /\/slingshot\/PATCHES\//){
            open FP, "cvs -Q -z9 log $wkdir/CHANGES |" or die "Failed to cvs log on CHANGES file: $!";
            #
            # Keep going until we hit a line "total revisions..."
            #
            $started = 0;
            $rpm_rev = 1;
            while(<FP>){
                chop $_;
                $line = $_;
                if($line =~ /total revisions/){
                    last;
                }
                if($started == 0){
                    if($line =~ /^symbolic names:/){
                        $started = 1;
                    }
                }
                else{
                    if($line =~ /^\s+$tag-(\d+):/){
                        if(int($1) >= $rpm_rev){
                            $rpm_rev = int($1) + 1;
                        }
                    }
                }
            }
            close FP;
            $tag2 = "$tag-$rpm_rev";
        }

        `cvs -Q -z9 tag  $tag $wkdir`;
        if($? != 0){
            print STDERR "Failed to add tag '$tag' to $wkdir\n";
            release_build_lock($ssh, $builder, $build_machine);
            exit -1;
        }
        
        if("$tag2" ne ""){
            `cvs -Q -z9 tag  $tag2 $wkdir`;
            if($? != 0){
                print STDERR "Failed to add tag '$tag2' to $wkdir\n";
                `cvs -Q -z9 tag -d $tag $wkdir`;
                if($? != 0){
                    print STDERR "Sheesh, even failed to remove the first tag: $tag\n";
                }
                release_build_lock($ssh, $builder, $build_machine);
                exit -1;
            }
        }
    }
    else{
        if($tswitch eq "auto"){
            $auto_flag = 1;
        }
        else{
            $auto_flag = 2;
        }
        if(!(open CVS, "cvs -Q -z9 log $wkdir/CHANGES |")){
            print STDERR "Cannot perform log on  $wkdir/CHANGES\n";
            $rc = -1;
        }
        else{
            $tag = "";
            while(<CVS>){
                chop;
                $line = $_;
                if((($majr, $minr, $plvl) = $line =~ /^\s+(v\d)-(\d\d)-(\d\d): /) == 3){
                    $tmp = "$majr-$minr-$plvl";
                    if($tag eq "" || "$tmp" gt "$tag"){
                        $tag = $tmp;
                    }
                }
            }
            close CVS;
            
        }
    }
        
    if($rc == 0){

        if(defined $branch_name){
            $rbuild = "-brbuild";
        }
        else{
            $rbuild = "-rbuild";
        }

        my($rcmd) = "$ssh $builder\@$build_machine";
        $rc = system("$ssh", 
                     "$builder\@$build_machine", 
                     "LINES=$lines COLUMNS=$columns TERM=$term perl $scm_dir/scm.pl $prunestr $rbuild $wkdir $tag");
        $rc >>= 8;
        if($rc != 0){
            print STDERR "Removing tag due to release failure\n";
            `cvs -Q -z9 tag -d $tag $wkdir`;
            if($? != 0){
                print STDERR "Sheesh, even failed to remove the tag: $tag\n";
            }
            if("$tag2" ne ""){
                `cvs -Q -z9 tag -d $tag $wkdir`;
                if($? != 0){
                    print STDERR "Sheesh, even failed to remove the second tag: $tag2\n";
                }
            }
        }
        else{
            if(!(open FP, "$wkdir/CHANGES" )){
                print STDERR "Failed to send automatic mail\n";
                $rc = -1;
            }
            else{
                $mail_txt = "";
                $done = 0;
                $started = 0;
                while(<FP>){
                    chop;
                    $line = $_;
                    if($done == 0){
                        if(!($line =~ /^\s+/ || $line eq "") && $mail_txt ne ""){
                            $done = 1;
                        }
                        else{
                            if($line =~ /^$tag/){
                                $started = 1;
                            }
                            if($started) {
                                $mail_txt .= $line . "\n";
                            }
                        }
                    }
                }
                close FP;
                $subject = "$wkdir $tag released";
                $sig = "";
                if(-f "$home/.sig"){
                    if(open FP, "$home/.sig"){
                        while(<FP>){
                            $sig .= $_;
                        }
                        close FP;
                    }
                }
            
                print "Sending release announce mail\n";
                if($auto_flag == 1){
                    $subject = "[AUTO][RELEASE] $subject";
                }
                elsif($auto_flag == 2){
                    $subject = "[SEMI-AUTO][RELEASE] $subject";
                }
                else{
                    $subject = "[RELEASE] $subject";
                }

                if("$branch_name" ne ""){
                    $subject = "$subject" . " [BRANCH-NAME: $branch_name]";
                }
                
                open MAIL, "| $ssh $omn_user\@$build_machine mail -s \\'$subject\\' release-targets\@openmindnetworks.com" or die "Failed to send automatic mail: $!";
                print MAIL "From the CHANGES file:\n";
                print MAIL "$mail_txt\n";
                if($#trqs  != -1){
                    print MAIL "\n";
                    print MAIL "TRQs mentioned:\n";
                    for($i = 0; $i <= $#trqs; $i++){
                        if (int($trqs[$i]) > 9999) {
                            # OTRS  > 4-digit TRQs
                            printf MAIL "    TRQ#: %d http://otrs/otrs/show_bug.cgi?id=%07d\n", $trqs[$i], $trqs[$i];
                        }
                        else {
                            # legacy Truckzilla 4-digit TRQs
                            printf MAIL "    TRQ#: %d http://truckzilla/show_bug.cgi?id=%d\n", $trqs[$i], $trqs[$i];
                        }
                    }
                }

                if($#bugs  != -1){
                    print MAIL "\n";
                    print MAIL "BUGs mentioned:\n";
                    for($i = 0; $i <= $#bugs; $i++){
                        printf MAIL "    BUG#: %d http://bugzilla/bugzilla/show_bug.cgi?id=%d\n", $bugs[$i], $bugs[$i];
                    }
                }
                if($#bugs  != -1 || $#trqs != -1){
                    print MAIL "\n";
                }
                print MAIL "$sig\n";
                close MAIL;
                if($? != 0){
                    print "Seemed to fail sending automatic mail\n";
                    $rc = -1;
                }
            }
        }
    }
    release_build_lock($ssh, $builder, $build_machine);
    exit $rc;
}

sub prerelease{
    my($scm_dir, $wkdir) = @_;
    my($cvsroot, $term, $lines, $columns, $omn_user, $prev, $l, @lines);
    my($sum, $v);

    ($cvsroot, $term, $lines, $columns) = sanitise_env();

    if(!($cvsroot =~ /ext:(\S+)\@/)){
	print STDERR "Cannot workout OMN user from '$cvsroot' (expected ...ext:XXX\@...)\n";
	exit -1;
    }

    $omn_user = $1;

    wkdir_sanity_check($wkdir);
    $l = `head -1 $wkdir/CHANGES`;
    chop $l;
    if((($v) = $l =~ /^(v\d-\d\d-\d\d)\s+PLEASE-RELEASE-ME/) != 1){
        print STDERR "First line of $wkdir/CHANGES is not magic: $l\n";
        exit -1;
    }

    $sum = prerelease_chksum($wkdir);

    # print "V: $v S: $sum\n";
    `mv $wkdir/CHANGES $wkdir/CHANGES.orig`;
    
    if(!(open FPI, "$wkdir/CHANGES.orig")){
        `mv $wkdir/CHANGES.orig $wkdir/CHANGES`;
        die "Failed to open $wkdir/CHANGES for writing: $!";
    }
    
    if(!(open FPO, ">$wkdir/CHANGES")){
        `mv $wkdir/CHANGES.orig $wkdir/CHANGES`;
        die "Failed to open $wkdir/CHANGES for writing: $!";
    }
    <FPI>;
    printf FPO "%s PLEASE-RELEASE-ME %s\n", $v, $sum;
    while(<FPI>){
        print FPO "$_";
    }
    close FPI;
    close FPO;
    `rm $wkdir/CHANGES.orig`;
    `cvs -Q -z9 ci -m "automated tagging for prerelease" $wkdir/CHANGES `;
    if($? != 0){
        print STDERR "Failed to commit new changes\n";
        exit -1;
    }
    print "Prerelease signature applied\n";
}

sub repopulate{
    my($ssh, $builder, $build_machine, $scm_dir, $prunestr, $modname, $version, $wkdir, $with_tests) = @_;
    my($f, $l, $s, $rdir, $majr, $minr, $plvl, $c_majr, $c_minr, $c_plvl);
    my($vers, $done, $tmp, $tag, $tag2, $err, $mail_txt, $line, $subject, $rc);
    my($sig, $auto_flag, $started, $branch_name, $branch_tree, $branch_base);
    my($branch_d1, $branch_d2, $branch_d3, $branch_d4, $i, $base_tag, $c_tag);
    my($omn_user, $remote_dir, $rpm_rev);
    my($home)=$ENV{"HOME"};
    my($rcmd, $pwd, $cmd);

    my($cvsroot, $term, $lines, $columns);

    $tag = $version;

    ($cvsroot, $term, $lines, $columns) = sanitise_env();

    if(!($cvsroot =~ /ext:(\S+)\@/)){
	print STDERR "Cannot workout OMN user from '$cvsroot' (expected ...ext:XXX\@...)\n";
	exit -1;
    }

    $omn_user = $1;

    if(0){
        print "CVSROOT: $cvsroot\n";
        print "   TERM: $term\n";
        print "  LINES: $lines\n";
        print "COLUMNS: $columns\n";
        exit 0;
    }
       
    $tag2 = "";
    $err = 0;
    $rc = 0;
    $auto_flag = 0;

    if( -d $wkdir ){
	print STDERR "$wkdir already exists\n";
	exit -1;
    }
    print "Creating work directory: ";
    `mkdir -p $wkdir`;
    if($? != 0){
        print "FAILED\n";
        print STDERR "Failed to create $wkdir\n";
        exit -1;
    }
    print "OK\n";

    $pwd = `pwd`;
    chop $pwd;

    if(!(chdir "$wkdir")){
        print STDERR "Failed to chdir to $wkdir\n";
        exit -1;
    }
    print "Checking out $modname: ";
    `cvs -Q co -r $version $modname`;
    if($? != 0){
        print "FAILED\n";
        print STDERR "Failed to checkout version $version of $modname\n";
        exit -1;
    }
    print "OK\n";

    print "Copying Module.versions.release to Module.versions: ";
    `cp $modname/Module.versions.release $modname/Module.versions`;
    if($? != 0){
        print "FAILED\n";
        print STDERR "Failed to copy Module.versions.release to Module.versions\n";
        exit -1;
    }
    print "OK\n";

    $rdir = get_release_dir("$modname/Makefile");

    if($rdir eq ""){
	print STDERR "No '# RELEASE_DIR = XXX' like in $wkdir/Makefile\n";
	exit -1;
    }

    if($with_tests){
        $cmd = "-repop-rbuild-with-tests";
    }
    else{
        $cmd = "-repop-rbuild";
    }


    get_build_lock($ssh, $builder, $build_machine, $modname);
    print "Kicking off $cmd\n";
    $rcmd = "$ssh $builder\@$build_machine";
    $rc = system("$ssh", 
                 "$builder\@$build_machine", 
                 "LINES=$lines COLUMNS=$columns TERM=$term perl $scm_dir/scm.pl $prunestr $cmd $modname $tag");

    release_build_lock($ssh, $builder, $build_machine);

    $rc >>= 8;
    chdir("$pwd");
    if($rc != 0){
        print STDERR "Failed to build $version of $modname\n";
    }
    else{
        `rm -rf $wkdir`;
    }
    exit $rc;
}

sub check_tag{
    my($wkdir, $tag, $should_be_there) = @_;
    my($l);

    open FP, "cvs -z9 log $wkdir/CHANGES 2>&1 |" or die "Cannot run cvs command: $! :";
    while (<FP>){
        $l = $_;
        chop $l;
        if($l =~ /^symbolic names:/){
            while (<FP>){
                $l = $_;
                chop $l;
                if($l =~ /^\S/){
                    last;
                }
                if($l =~ /\s+([^:]+):/){
                    $l = $1;
                    if($l eq $tag){
                        if($should_be_there == 0){
                            print STDERR "The '$tag' tag is already applied\n";
                        }
                        return -1;
                    }
                }
            }
            last;
        }
    }
    close FP;
    if($should_be_there != 0){
        print STDERR "The '$tag' tag is not applied\n";
    }
    return 0;
}

sub do_cand_check{
    my($rcmd, $release_dir, $tag, $wkdir) = @_;
    
    if($release_dir =~ /^\/slingshot\/PATCHES\//){   
        `$rcmd "[ -f $release_dir/CANDIDATE -a ! -f $release_dir/CANDIDATE.UNLOCKED ]"`;
        if($? == 0){
            print "LOCKED-CANDIDATE release currently exists\n";
            print "Ask Team-Test about unlocking it\n";
            return -1;
        }
        `$rcmd "[ -f $release_dir/CANDIDATE ]"`;
        if($? == 0){
            print "CANDIDATE release currently exists, re-release ontop of it [y/n]: ";
            if(yn != 0){
                print "Aborting\n";
                return -1;
            }
            print STDERR "Removing CANDIDATE release area\n";
            `$rcmd "chmod -R +w $release_dir"`;
            if($?){
                print STDERR "Yikes, chmod -R +w $release_dir failed\n";
                return -1;
            }
        
            `$rcmd "rm -rf $release_dir"`;
            if($?){
                print STDERR "Yikes, rm -rf  $release_dir failed\n";
                return -1;
            }
        
            print STDERR "Removing existing candidate tag\n";
            `cvs -Q -z9 tag -d $tag $wkdir`;
            if($? != 0){
                print STDERR "Failed to remove the tag on the CANDIDATE\n";
                exit -1;
            }
            return 1;
        }
    }
    return 0;
}
    
return 1;
