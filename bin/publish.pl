#!/usr/bin/env perl
#
# $Name:  $ $Header: /homes/bob/cvsroot/sbe/publish.pl,v 1.21 2017/07/07 10:54:54 brian Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

sub publish{
    my($ssh, $builder, $build_machine, $scm_dir, $pub_dir, $pdf, @argv) = @_;
    my($user, $line, $desc, $base, $patches, $n, $v, $host, $im, $i, $via_ssh,);
    my($rc, $base_rpm, $rpm, @base_rpms, @rpms, $arch, $d, $tmp, $dl_arch);
    my($j, $k, $patch_rpm, @patch_rpms, $d1, $tmp1, @arches, $cand_dir);
    my($changes_extract, $sig, $subject, $pversion, $baseless);
    my($home)=$ENV{"HOME"};
    my($rcmd) = "$ssh $builder\@$build_machine";
    my($verbose) = 0;

    $user = "";
    $via_ssh = 0;
    $pdf = "";

    for($i = 1; $i <= $#argv; $i++){
        if("$argv[$i]" eq "-user"){
            $user = $argv[$i+1];
            $i++;
        }
        elsif("$argv[$i]" eq "-via_ssh"){
            $via_ssh = 1;
        }
        elsif("$argv[$i]" eq "pdf"){
            $pdf = $argv[$i];
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

    if(!($pub_dir =~ /^\//)){
        $pub_dir = "/slingshot/PUBLISHED/" . $pub_dir;
    }
    if(! -d "$pub_dir"){
        print STDERR "Publishing directory '$pub_dir' doesn't exist\n";
        exit -1;
    }

    if(! -f "$pub_dir/info"){
        print STDERR "Info file '$pub_dir/info' doesn't exist\n";
        exit -1;
    }
    open FPI, "$pub_dir/info" or die "Failed to open '$pub_dir/info': $!";
    while(<FPI>){
        chop;
        $line = $_;
        if($line =~ /^\s*$/){
            next;
        }
        if($line =~ /^\s*\#/){
            next;
        }
        if(($n,$v) = $line =~ /^\s*(\S+)\s*=\s*(\S.*)\s*$/){
            $v =~ s/\s+$//;
            # print "'$n' = '$v'\n";

            if("$n" eq "DESC"){
                if(defined($desc)){
                    print STDERR "Multiple DESC definitions in info file\n";
                    exit -1;
                }
                $desc = $v;
            }
            elsif("$n" eq "BASE"){
                if(defined($base)){
                    print STDERR "Multiple BASE definitions in info file\n";
                    exit -1;
                }
                $base = "$v";
            }
            elsif("$n" eq "PATCHES"){
                if(defined($patches)){
                    print STDERR "Multiple PATCHES definitions in info file\n";
                    exit -1;
                }
                $patches = "$v";
            }
            else{
                print STDERR "Unknown directive '$n' in info file\n";
                exit -1;
            }
        }
        else{
            printf STDERR "Garbage line in info file: '$line'\n";
            exit -1;
        }
    }
    close FPI;
    if(!defined($desc)){
        print STDERR "No DESC in info file\n";
        exit -1;
    }

    if(!defined($base)){
        print STDERR "No BASE in info file\n";
        exit -1;
    }

    if(!defined($patches)){
        print STDERR "No PATCHES in info file\n";
        exit -1;
    }

    # print "Description: $desc\n";
    # print "       Base: $base\n";
    # print "    Patches: $patches\n";

    $baseless = 0;

    if("$base" eq "N/A"){
        #
        # The BASE directory is N/A, this looks like a PATCH only
        # release thingy. The first of these was CSS for Portico,
        # perhaps this is one of those.
        #
        $baseless = 1;
    }
    else{
        if(!($base =~ /^\//)){
            $base = "/slingshot/$base";
        }

        if(! -d "$base"){
            print STDERR "Base directory '$base' doesn't exist\n";
            exit -1;
        }
        if(! -d "$base/RPMS"){
            print STDERR "No RPMS directory in base directory '$base'\n";
            exit -1;
        }
    }

    $cand_dir = "";
    my $last=0;
    for($im = 0; $im < 10; $im++){
    for($i = 0; $i < 100; $i++){
        $d1 = sprintf "/slingshot/$patches/v1/%02d/%02d", $im, $i;
        if(! -d "$d1/RPMS"){
            $last=1;
            last;
        }
        if(-f "$d1/CANDIDATE"){
            @patch_rpms = glob "$d1/RPMS/*.rpm";
            if($#patch_rpms < 0){
                print STDERR "No RPMS in $d1/RPMS";
                exit -1;
            }
            $pversion = "";
            foreach $patch_rpm (@patch_rpms){
                if($patch_rpm =~ /[\.-]p(\d+-\d+)\./){
                    $pversion = "p" . $1;
                    $last=1;
                    last;
                }
                if($patch_rpm =~ /[\.-]p(\d+)-1-(\d+)\./){
                    $pversion = "p" . $1 . "-" . $2;
                    $last=1;
                    last;
                }
            }
            if("$pversion" eq ""){
                printf STDERR "Cannot work out pXX-Y version in $d1/RPMS majorv=%d minorv=%d\n", $im, $i;
                exit -1;
            }

            $cand_dir = "$d1";


            $subject = sprintf "[PUBLISHED] $desc has a new patch, $pversion, available under $pub_dir/PATCHES";
            $changes_extract = "";
            open FPI, "$d1/SRC/CHANGES" or die "Cannot open CHANGES file in patch dir: $!";
            while(<FPI>){
                chop;
                $line = $_;
                if($line =~ /^v\d-\d\d-(\d\d)/ && int($1) != $i){
                    last;
                }
                $changes_extract .= "$line\n";
            }
            close FPI;
            $last=1;
            last;
        }
    }if($last==1){last;}}



    if($via_ssh == 0){
        $rc = system("$ssh",
                     "$builder\@$build_machine",
                     "$scm_dir/scm.pl",
                     "-publish",
                     "$pub_dir",
                     "$pdf",
                     "-user", "$user",
                     "-via_ssh");
        $rc >>= 8;
        if($rc == 0){
            if("$cand_dir" ne ""){
                $rc = system("$ssh",
                             "$builder\@$build_machine",
                             "head -0 $cand_dir/CANDIDATE >/dev/null 2>&1");
                $rc >>= 8;
                if($rc != 0){
                    #
                    # The candidate file is gone, do a mail
                    #
                    $sig = "";
                    if(-f "$home/.sig"){
                        if(open FP, "$home/.sig"){
                            while(<FP>){
                                $sig .= $_;
                            }
                            close FP;
                        }
                    }

                    open MAIL, "| $ssh $user\@$build_machine mail -s \\'$subject\\' release-targets\@openmindnetworks.com" or die "Failed to send automatic mail: $!";
                    print MAIL "From the CHANGES file:\n";
                    print MAIL "$changes_extract\n";
                    print MAIL "$sig\n";
                    close MAIL;
                    if($? != 0){
                        print STDERR "Seemed to fail sending automatic mail\n";
                        $rc = -1;
                    }
                }
            }
        }
        exit $rc;
    }

    @arches = ();
    @base_rpms = ();
    if($baseless == 0){
        push @base_rpms, glob "$base/RPMS/*.rpm";

        if($#base_rpms < 0){
            print STDERR "No RPMS under base directory '$base'\n";
            exit -1;
        }

        if(! -d "$pub_dir/BASE"){
            `mkdir -p $pub_dir/BASE`;
            if($? != 0){
                print STDERR "Failed to create directory '$pub_dir/BASE'\n";
                exit -1;
            }
        }
        `chmod +w $pub_dir/BASE`;

        foreach $base_rpm (@base_rpms){
            if(($base_rpm =~ /\.([^\.]+)(\.i386|\.i686|\.x86_64)\.rpm/)){
                if($2 eq "\.x86_64"){
                    $arch = "x64.as7";
                }
                else{
                    $arch = $1;
                }
                push @arches, "$arch";
                $dl_arch = $arch;
                $dl_arch =~ tr/[A-Z]/[a-z]/;
                $d = "$pub_dir/BASE/$arch";
                if(! -d "$d"){
                    `mkdir -p $d`;
                    if($? != 0){
                        print "FAILED\n";
                        print STDERR "Failed to create base arch directory: $d\n";
                        exit -1;
                    }
                }
                `chmod +w $d`;
                if($? != 0){
                    print STDERR "Failed to chmod +w on base arch directory: $d\n";
                    exit -1;
                }

                print "$arch: ";
                $tmp = `/slingshot/MOS-base/LATEST/scripts/deploylist.pl -$dl_arch $base`;
                if($? != 0){
                    print "FAILED\n";
                    print STDERR "deploylist.pl failed\n";
                    exit -1;
                }
                @rpms = split /\s+/, "$tmp";
                $j = $#rpms + 1;
                $i = 0;
                $k = 0;
                print "RPMS: ";
                foreach $rpm (@rpms){
                    $i++;
                    printf "%2d/%-2d\b\b\b\b\b", $i, $j;
                    $tmp = `basename $rpm`;
                    chop $tmp;
                    if(! -f "$d/$tmp"){
                        $k++;
                        `cp $rpm $d/$tmp`;
                        if($? != 0){
                            print "\n";
                            print STDERR "Failed to copy $tmp to base arch directory: $d\n";
                            exit -1;
                        }
                    }
                }
                `chmod a-w $d`;
                printf "%d/%d copied \n", $k, $j;
            }
            else{
                print STDERR "Zoikes, unrecognised architecture in RPM: $base_rpm\n";
                exit -1;
            }
        }
        `chmod a-w $pub_dir/BASE`;
    }

    print "Patches: ";

    for($im = 0; $im < 10; $im++){
    for($i = 0; $i < 100; $i++){
        $d1 = sprintf "/slingshot/$patches/v1/%02d/%02d", $im, $i;
        if(-d "$d1/RPMS" && ! -f "$d1/CANDIDATE"){
            @patch_rpms = glob "$d1/RPMS/*.rpm";
            printf "%02d(%1d/%1d)\b\b\b\b\b", $im, $i, $#patch_rpms + 1;
            if($#patch_rpms >= 0){

                foreach $patch_rpm (@patch_rpms){
                    if(($patch_rpm =~ /\.([^\.]+)(\.i386|\.i686|\.x86_64)\.rpm/) == 0){
                        print STDERR "Cannot work out arch from: $patch_rpm\n";
                        exit -1;
                    }

                    if($2 eq "\.x86_64"){
                        $arch = "x64.as7";
                    }
                    else{
                        $arch = $1;
                    }

                    $d = "$pub_dir/PATCHES/$arch";
                    if(! -d "$d"){
                        `mkdir -p $d`;
                        if($? != 0){
                            print "FAILED\n";
                            print STDERR "Failed to create patches arch directory: $d\n";
                            exit -1;
                        }
                    }
                    `chmod +w $d`;
                    if($? != 0){
                        print STDERR "Failed to chmod +w on patches arch directory: $d\n";
                        exit -1;
                    }

                    $tmp1 = `basename $patch_rpm`;
                    chop $tmp1;
                    if(! -f "$d/$tmp1"){
                        `cp $patch_rpm $d/$tmp1`;
                        if($? != 0){
                            print "FAILED\n";
                            printf STDERR "Failed to copy patch %s to patches directory: $tmp\n", "$tmp1";
                            exit -1;
                        }
                    }
                    `chmod a-w $d`;
                }
            }
        }
        printf "\r%70s\r", "";
    }}
    #printf "v1-%02d-%02d\n", $im, $i;

    $last=0;
    $j = -1;
    for($im = 0; $im < 10; $im++){
    for($i = 0; $i < 100; $i++){
        $d1 = sprintf "/slingshot/$patches/v1/%02d/%02d", $im, $i;
        if(-d "$d1/RPMS"){
            if(-f "$d1/CANDIDATE"){
                $last=1;
                last;
            }
            $j = $i;
        }
    }if($last==1){last;}}
    printf "v1-%02d-%02d\n", $im, $i;

    if($im != 10){
        printf "A Candidate Patch is available as v1-%02d-%02d\n", $im, $i;
        printf "The relevant portion of the CHANGES file is:\n";
        printf "%s\n", $changes_extract;
        printf "------------------------------------------------------\n";

        printf "Do you want to publish this patch? ";


        if(yn != 0){
            print "Aborted\n";
            exit -1;
        }
        `chmod +w $d1`;
        if($? != 0){
            print STDERR "Failed to add write access to $d1\n";
            exit -1;
        }
        `rm -f $d1/CANDIDATE`;
        if($? != 0){
            print STDERR "Failed to remove CANDIDATE in $d1\n";
            exit -1;
        }
        `chmod -w $d1`;
        if($? != 0){
            print STDERR "Failed to remove write access from $d1\n";
            exit -1;
        }
        $j++;

        @patch_rpms = glob "$d1/RPMS/*.rpm";
        if($#patch_rpms >= 0){
            if ($pdf){
                print "Release notes pdf export is enabled\n";
                my $cmd = "/slingshot/sbe/LATEST/scripts/publish_rn_pdf.py" . ' -r ' . $pub_dir . ' -n ' . $patch_rpms[0];
                system ($cmd) == 0 or die "Release notes PDF gen. command was unable to run to completion:\n$cmd\n";
            }
            else{
                print "Release notes pdf export is disabled\n";
            }

            foreach $patch_rpm (@patch_rpms){
                if(($patch_rpm =~ /\.([^\.]+)(\.i386|\.i686|\.x86_64)\.rpm/) == 0){
                    print STDERR "Cannot work out arch from: $patch_rpm\n";
                    exit -1;
                }

                if($2 eq "\.x86_64"){
                    $arch = "x64.as7";
                }
                else{
                    $arch = $1;
                }

                $d = "$pub_dir/PATCHES/$arch";
                if(! -d "$d"){
                    `mkdir -p $d`;
                    if($? != 0){
                        print "FAILED\n";
                        print STDERR "Failed to create patches arch directory: $d\n";
                        exit -1;
                    }
                }
                `chmod +w $d`;
                if($? != 0){
                    print STDERR "Failed to chmod +w on patches arch directory: $d\n";
                    exit -1;
                }

                # print "$patch_rpm\n";
                $tmp1 = `basename $patch_rpm`;
                chop $tmp1;
                if(! -f "$pub_dir/PATCHES/$arch/$tmp1"){
                    `chmod +w $pub_dir/PATCHES/$arch`;
                    `cp $patch_rpm $pub_dir/PATCHES/$arch/$tmp1`;
                    if($? != 0){
                        print "FAILED\n";
                        printf STDERR "Failed to copy patch %s to patches directory: $tmp\n", "$tmp1";
                        exit -1;
                    }
                    `chmod -w $pub_dir/PATCHES/$arch`;
                }
            }
        }
    }

    if($j != -1){
        $d1 = sprintf "/slingshot/$patches/v1/%02d/%02d", $im, $j;
        `diff $d1/SRC/CHANGES $pub_dir/PATCHES/CHANGES >/dev/null 2>/dev/null`;
        if($? != 0){
            `chmod +w $pub_dir/PATCHES`;
            if($? != 0){
                print STDERR "Zoikes, cannot add write permissions to $pub_dir/PATCHES\n";
            }
            `rm -f $pub_dir/PATCHES/CHANGES`;
            `cp $d1/SRC/CHANGES $pub_dir/PATCHES/CHANGES`;
            `chmod a-w $pub_dir/PATCHES/CHANGES $pub_dir/PATCHES`;
            `chmod +w $pub_dir/PATCHES`;
        }
    }

    exit 0;

    print "How about this on $host: ";
    if(yn != 0){
        print "Shame\n";
        exit -1;
    }
    else{
        print "Great\n";
        exit 0;
    }



}

return 1;
