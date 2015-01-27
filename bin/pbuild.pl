#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/pbuild.pl,v 1.45 2011/04/29 17:10:05 brian Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

my(@mach_n_dirs_base)=(
                  "iowa", "/homes/bob/p_build_area", "linux.x86",
                  "hp1", "/usr/bob/p_build_area", "hpux.11i",
                  "as3builder", "/usr/bob/p_build_area", "linux.as3",
                  "as4builder", "/usr/bob/p_build_area", "linux.as4",
#                  "scratchy", "/usr/bob/p_build_area", "linux.fc5",
                  "fc9builder", "/usr/bob/p_build_area", "linux.fc9",
                  "montana", "/usr/bob/p_build_area", "linux.fc5",
                  "as5builder", "/usr/bob/p_build_area", "linux.as5",
                  "as6builder", "/usr/bob/p_build_area", "linux.as6",
#                  "nevada", "/usr/bob/p_build_area", "sol9.sparc",
                       );

my(@mach_n_dirs)=();


sub prune_arch{
    my($tgt) = @_;
    my($i);
        
    for($i = 0; $i < $#mach_n_dirs_base; $i += 3){
        if("$mach_n_dirs_base[$i+2]" eq "$tgt"){
            splice @mach_n_dirs_base, $i, 3;
            return;
        }
    }
    print "Unknown architecture: $tgt\n";
    exit(-1);
}

sub pbuild_defeat_nfs_cache{
    my($rdir) = @_;
    my($i, $j, $host, @dparts);
    my($tmp);

    (@dparts) = split /\//, $rdir;

    print "Defeat NFS caching for $rdir\n";

    for($i = 0; $i <= $#mach_n_dirs; $i += 3){
        $host = $mach_n_dirs[$i];
        $tmp = "";
        for($j = 0; $j <= $#dparts; $j++){
            $tmp = "$tmp/$dparts[$j]";
            print "$host: $tmp\n";
            `ssh bob\@$host "ls $tmp >/dev/null 2>&1"`;
            if($? != 0){
                return -1;
            }
        }
    }
    return 0;
}
sub pbuild_cleanup{
    my($modname) = @_;
    my($host, $remdir, $i);

    for($i = 0; $i <= $#mach_n_dirs; $i += 3){
        $host = $mach_n_dirs[$i];
        $remdir = $mach_n_dirs[$i+1];
        
        `ssh bob\@$host "(cd $remdir; rm -rf $modname)"`;
    }
}

sub pbuild{
    my($modname, $scm_dir, $tag) = @_;
    my($host, $remdir, $arch, $i, $j, $tmp, $rc, $lnk, $scm_tmp, $mktmp);
    my(@args, $branch_name, $l, $f, %supp_archs, $arch_prune, $dir);
    my($t0, $t1, $diff);
    my(@ads_files, $wkdir, $owkdir);
    
    if(-f "$modname/BRANCH.INFO"){
        if(!(open FP, "$modname/BRANCH.INFO")){
            print STDERR "Failed to open $modname/BRANCH.INFO: $!";
            pbuild_cleanup($modname);
            return -1;
        }
          
        $branch_name = "";
        while(<FP>){
            chop;
            $l = $_;
            if($l =~ /^\s*NAME\s*=\s*(\S+)/){
                $branch_name = $1;
            }
        }
        close FP;
        if("$branch_name" eq ""){
            print STDERR "Cannot locate branch name in $modname/BRANCH.INFO\n";
            pbuild_cleanup($modname);
            return -1;
        }
        if(-f "/slingshot/build-plans/LATEST/misc/BRANCHES.ARCH"){
            $f = "/slingshot/build-plans/LATEST/misc/BRANCHES.ARCH";
        }
        elsif(-f "/homes/brian/BRANCHES.ARCH"){
            $f = "/homes/brian/BRANCHES.ARCH";
            print STDERR "******************************************************\n";
            print STDERR "******************************************************\n";
            print STDERR "*                                                    *\n";
            print STDERR "*          using ~brian/BRANCHES.ARCH                *\n";
            print STDERR "*                                                    *\n";
            print STDERR "******************************************************\n";
            print STDERR "******************************************************\n";
        }       
        else{
            print STDERR "Could not locate BRANCHES.ARCH anywhere\n";
            pbuild_cleanup($modname);
            return -1;
        }
        if(!(open FP, "$f")){
            print STDERR "Failed to open $f: $!\n";
            pbuild_cleanup($modname);
            return -1;
        }

        while(<FP>){
            chop;
            $l = $_;
            if($l =~ /^\s*\#/){
                next;
            }
            if($l =~ /^\s*$/){
                next;
            }
            
            if($l =~ /^\s*$branch_name\s*(\S.*)$/){
                foreach $arch (split / /, $1){
                    $supp_archs{"$arch"} = 1;
                }
            }
        }
        close FP;
    }
    $mktmp = "$modname/__Makefile_ARCH_TMP__";
    open MK, ">$mktmp" or die "Failed to open $mktmp: $!";
    print MK "include $modname/Module.versions\n";
    print MK "all:\n";
    print MK "\t\@echo \$(MOS_ALL_DIRS)\n";
    close MK;

    
    $tmp = `gmake -f $mktmp all`;
    chop $tmp;

    `rm -f $mktmp`;

    @ads_files = ();

    foreach $dir (split / /, $tmp){
        $f = "$dir/ARCH.SUPPORT";
        if( -f "$f"){
            push @ads_files, $f;
        }
        $f = "$dir/misc/ARCH.SUPPORT";
        if( -f "$f"){
            push @ads_files, $f;
        }
    }
    
    if(defined($branch_name) && ("$branch_name" ne "")){
        $f = "/slingshot/BRANCHES-ARCH.SUPPORT/$branch_name";
        if( -f "$f"){
            push @ads_files, $f;
        }
    }
    
    #
    # When evaluating what architectures to build, we add a little
    # hack for patches. If we are building a patch *and* the
    # patch contains an ARCH.SUPPORT, then it is considered authorirative
    # and will have the last say (YES or NO) on whether a particular
    # arch is to be built or not. The way this is achieved is a bit
    # hacky.
    #

    $j = $#ads_files + 1;

    for($i = 0; $i <= $j; $i++){
        if($i == $j){
            $f = "$modname/ARCH.SUPPORT";
            if(!($f =~ /PATCHES\//)){
                last;
            }
            if(! -f "$f"){
                last;
            }
        }
        else{
            $f = $ads_files[$i];
        }
        # print "Found one: $f\n";
        if(!(open FP, "$f")){
            print STDERR "Failed to open $f: $!\n";
            pbuild_cleanup($modname);
            return -1;
        }
        while(<FP>){
            chop;
            $l = $_;
            if($l =~ /^\s*(\S+)\s*=\s*(\S+)/){
                print "Got: $1 $2\n";
                if("$2" eq "yes"){
                    # print "Setting $1 to YES\n";
                    if($i == $j || !(defined $supp_archs{"$1"})){
                        $supp_archs{"$1"} = 1;
                    }
                }
                else{
                    # print "Setting $1 to NO\n";
                    $supp_archs{"$1"} = 0;
                }
            }
        }
        close FP;
    }

    for($i = 0; $i <= $#mach_n_dirs_base; $i += 3){
        $host = $mach_n_dirs_base[$i];
        $remdir = $mach_n_dirs_base[$i+1];
        $arch = $mach_n_dirs_base[$i+2];
        if(!(defined($supp_archs{"$arch"}) && $supp_archs{"$arch"} == 0)){
            push @mach_n_dirs, $host, $remdir, $arch;
        }
    }
          
    #
    # We want to build $modname on local disk on all the machines,
    # then merge back the build directories locally and
    # proceed
    #

    `mv $modname/Module.versions  $modname/Module.versions.orig`;

    for($i = 0; $i <= $#mach_n_dirs; $i += 3){
        $host = $mach_n_dirs[$i];
        $remdir = $mach_n_dirs[$i+1];
        
        if(!(open FPO, ">$modname/Module.versions")){
            print STDERR "Failed to create relocated version of Module.versions for $host: $!\n";
            pbuild_cleanup($modname);
            return -1;
        }
        if(!(open FPI, "$modname/Module.versions.orig")){
            print STDERR "Failed to open original version of Module.versions for $host: $!\n";
            pbuild_cleanup($modname);
            return -1;
        }
        $owkdir = "";
        while(<FPI>){
            chop;
            $tmp = $_;
            if($tmp =~ /^\s*\#\s*__MODVERS_WKDIR__\s+(\S+)/){
                $owkdir = $1;
            }
            elsif($tmp =~ /^\s*MOS_ALL_DIRS\s*:=/){
                if("$owkdir" ne ""){
                    $tmp =~ s/$owkdir/$remdir\/$modname\/\./g;
                }
            }
            print FPO "$tmp\n";
        }
        close FPO;
        close FPI;
        

        $tmp=`tar -cf - $modname | ssh  bob\@$host ". ./.profile; (cd $remdir; rm -rf $modname;  tar -xf -);"`;
        $rc = $?;
        # printf "RC: %04x $tmp\n", $rc;
        if(($rc & 0xff) != 0){
            print STDERR "Failed to send source tree to $host $remdir\n";
            pbuild_cleanup($modname);
            return -1;
        }
        
    }

    `mv $modname/Module.versions.orig  $modname/Module.versions`;

    $scm_tmp = $scm_dir;
    $scm_tmp =~ s/\/scripts$//;
    $lnk=`. $scm_dir/mos_shell_locals.sh; echo \$SYS_ARCH`;
    chop $lnk;

    @args = ();
    push(@args, "$scm_tmp/lnk/$lnk/plv");
    for($i = 0; $i <= $#mach_n_dirs; $i += 3){
        $host = $mach_n_dirs[$i];
        $remdir = $mach_n_dirs[$i+1];

        push(@args, "-cmd");
        push(@args, "$host: $modname $tag");
        push(@args, "ssh bob\@$host . ./.profile; (cd $remdir/$modname; gmake spotless all);");
    }
    
    $rc = system(@args);
    if($rc != 0){
        print STDERR "Build failed\n";
        pbuild_cleanup($modname);
        return -1;
    }

    if(0){
        print STDERR "Forcing abort\n";
        pbuild_cleanup($modname);
        return -1;
    }

    $t0 = time();
    for($i = $#mach_n_dirs - 2; $i >= 0; $i -= 3){
        $host = $mach_n_dirs[$i];
        $remdir = $mach_n_dirs[$i+1];

        $t1 = time();

        printf "$modname: %16s: copy ", "$host";

        `ssh bob\@$host ". ./.profile; (cd $remdir;  tar -cf - $modname);" | tar -xf - 2>/dev/null`;
        $rc = $?;
        if(($rc & 0xff) != 0){
            print "FAILED\n";
            print STDERR "Failed to pull build result from $host\n";
            pbuild_cleanup($modname);
            return -1;
        }
        print ": cleanup ";
        `ssh bob\@$host ". ./.profile; (cd $remdir;  rm -rf $modname);"`;
        printf " DONE (%d)\n", time() - $t1;
    }
    printf "$modname: Build produce gathered in %d seconds\n", time() - $t0;
    return 0;
}
        

#pbuild("libtbx", "/usr/brian/wa/sbe", 1);    
#
#exit 0;

return 1;

