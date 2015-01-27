#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/rbuild.pl,v 1.56 2008/03/09 12:34:30 brian Exp $
#

require "get_release_list.pl";

sub build_cleanup{
    my($build_area, $modname) = @_;

    `rm -rf $build_area/$modname\_tmp`;
    `rm -rf $build_area/$modname`;
}

sub rbuild{
    my($build_area, $scm_dir, $modname, $tag, $cmd) = @_;
    my($pwd, $rc, $rdir, $tmp, $line, $type, $src, $dst, $modes, $fname);
    my($old_dir, $rbase, $rstub, $bdir, @lines, $is_branch);
    my($sol9_mod, $mtmp, $i, $rdir_prepop, $disable_tests, $needed);
    my(@modules) = get_modules();
    my(@fatmp, $fname1);

    $disable_tests = 0;

    if("$cmd" eq "-repop-rbuild"){
        $disable_tests = 1;
    }
    elsif("$cmd" eq "-repop-rbuild-with-tests"){
        $cmd = "-repop-rbuild";
    }

    print "$modname: Building $modname $tag\n";

    print "$modname: Moving to build area\n";

    chdir("$build_area");
    if($? != 0){
        print STDERR "$modname: Failed to chdir to build_area\n";
        exit -1;
    }

    print "$modname: Checking out tagged module\n";

    `cvs -Q -z9 co -r $tag $modname`;
    if($? != 0){
        print STDERR "$modname: Failed to checkout tagged release\n";
        exit -1;
    }

    #
    # If you must deliver tests during repop, set the 1 to 0
    #
    if($disable_tests && -f "$modname/tests/Makefile"){
        `mv $modname/tests/Makefile $modname/tests/Makefile.orig`;
          open MKF_OLD, "$modname/tests/Makefile.orig" or die "Failed to open $modname/tests/Makefile.orif for test nukage: $!";
        open MKF_NEW, ">$modname/tests/Makefile" or die "Failed to open $modname/tests/Makefile for test nukage: $!";
        print MKF_NEW "#################################################\n";
        print MKF_NEW "#                                               #\n";
        print MKF_NEW "# Makefile munged during repop to disable tests #\n";
        print MKF_NEW "#                                               #\n";
        print MKF_NEW "#################################################\n";
        print MKF_NEW "\n";

        while(<MKF_OLD>){
            chop;
            $tmp = $_;
            if($tmp =~ /^all:/){
                $tmp =~ s/^all:/old_all:/;
            }
            print MKF_NEW "$tmp\n";
        }
        print MKF_NEW "\n";
        print MKF_NEW "all:\n";
        print MKF_NEW "\t\@echo '###########################################'\n";
        print MKF_NEW "\t\@echo\n";
        print MKF_NEW "\t\@echo Tests disabled during repop\n";
        print MKF_NEW "\t\@echo\n";
        print MKF_NEW "\t\@echo '###########################################'\n";
        print MKF_NEW "\n";
        close MKF_NEW;
        close MKF_OLD;
        
    }
    
    $rbase = get_release_dir("$modname/Makefile");

    $is_branch = 0;

    if($tag =~ /^v\d-\d\d-\d\d$/){
        $rstub = $tag;
        $rstub =~ s/-/\//g;
        $rdir = "$rbase/$rstub";
    }
    elsif($tag =~ /^v\d-\d\d-\d\d-[a-z]\d\d$/){
        $rstub = $tag;
        $rstub =~ s/-/\//g;
        $rstub =~ s/([a-z]\d\d)$/BRANCHES\/$1/;
        $rdir = "$rbase/$rstub";
        $is_branch = 1;
    }
    else{
        print STDERR "$modname: unrecognised tag layout '$tag'\n";
        build_cleanup($build_area, $modname);
        exit -1;
    }

    
    $rdir_prepop = "$rdir" . "-PREPOP";
    
    if("$cmd" eq "-repop-rbuild"){
        if(-d "$rdir" && -f "$rdir/.REPOPULATED" && (! -f "$rdir/lnk-removed-after-6-months")){
            print "$modname: $modname $tag ($rdir) has been repopulated already\n";
            build_cleanup($build_area, $modname);
            return;
        }
        if(-d "$rdir" && -d ("$rdir/lnk" || -d "$rdir/RPMS")){
            print "$modname: $modname $tag ($rdir) has not been pruned yet\n";
            build_cleanup($build_area, $modname);
            return;
        }
    }
    else{
        if(-d $rdir){
            print STDERR "$modname: $modname $tag ($rdir) is there already in some form\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
    }

    $pwd = `pwd`;
    chop $pwd;

    if("$cmd" ne "-repop-rbuild"){ # No munge for repopulation
        print "$modname: Creating scratch dir for Module.versions munge\n";
        `mkdir $modname\_tmp`;

        if($? != 0){
            print STDERR "$modname: Failed to create $modname\_tmp\n";
            build_cleanup($build_area, $modname);
            exit(-1);
        }
        chdir "$modname\_tmp";
        `cvs -Q -z9 co $modname/Module.versions.release`;

        if($? != 0){
            print STDERR "$modname: Failed to checkout Module.versions.release for munging\n";
            build_cleanup($build_area, $modname);
            exit(-1);
        }
    
        print "$modname: Populating Module.versions.release\n";

        modvers("$pwd/$modname", "$modname/Module.versions.release");
        
        print "$modname: Checking it in\n";
        `cvs -Q -z9 commit -m 'Updated for release' $modname/Module.versions.release`;
        if($? != 0){
            print STDERR "$modname: Failed to update Module.versions.release\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
        
        print "$modname: Removing existing tag\n";
        `cvs -Q -z9 tag -d $tag $modname/Module.versions.release`;
        if($? != 0){
            print STDERR "$modname: Failed to remove tag Module.versions.release\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
        
        print "$modname: Reapplying tag\n";
        `cvs -Q -z9 tag $tag $modname/Module.versions.release`;
        if($? != 0){
            print STDERR "$modname: Failed to tag Module.versions.release\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
        print "$modname: Cleaning up prior to build\n";
        chdir "$pwd";
        build_cleanup($build_area, $modname);
    }

    print "$modname: Checking out module for build\n";
    `cvs -Q -z9 co -r $tag $modname`;

    if($? != 0){
        print STDERR "$modname: Failed to checkout tagged release (second time)\n";
        build_cleanup($build_area, $modname);
        exit -1;
    }

    `cp $modname/Module.versions.release $modname/Module.versions`;
    if($? != 0){
        print STDERR "$modname: Failed to copy Module.versions.release to Modules.versions\n";
        build_cleanup($build_area, $modname);
        exit -1;
    }

    $rc = pbuild($modname, $scm_dir, $tag);
    if($rc != 0){
        print STDERR "$modname: Failed to do parallel build\n";
        build_cleanup($build_area, $modname);
        exit -1;
    }
    chdir $modname;
    
    if(-d "$rdir" && "$cmd" eq "-repop-rbuild"){
        `chmod +w $rdir/..`;
        `mv $rdir $rdir_prepop`;
        if($? != 0){
            print STDERR "$modname: Failed to move $rdir --> $rdir_prepop\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
    }
    
    if($rdir =~ /^(.*)\/BRANCHES\//){
        $tmp = $1;
        if(! -d "$tmp/BRANCHES"){
            `chmod +w $tmp`;
            `mkdir $tmp/BRANCHES`;
            `chmod -w $tmp`;
        }
    }

    `mkdir -p $rdir`;
    if($? != 0){
	print STDERR "$modname: (1) Failed to create $rdir\n";
	build_cleanup($build_area, $modname);
	`rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
	exit -1;
    }

    print "$modname: Releasing listed files\n";


    @lines = get_release_list();

    foreach $line (@lines){
        if((($type, $src, $dst, $modes) = $line =~ /^([DF])\s+(\S+)\s+(\S+)(.*)$/) == 4){
            $modes =~ s/^\s*(\S+)\s*$/$1/;

            #
            # If the source is a file, the destination is assumed to be
            # a file, if there is a directory stub, get it and make the
            # destination directory. Otherwise do nothing, it's going in
            # the toplevel directoy.
            #
            # If the source is a directory, the destination is a directory
            # so just mkdir it (and it's parents if necessary).
            # 

            if($type eq 'F'){
                if($dst =~ /\//){
                    ($tmp) = $dst =~ /^(.*)\/[^\/]*$/;
                    `mkdir -p $rdir/$tmp`;
                }
            }
            else{
                `mkdir -p $rdir/$dst`;
            }
            if($? != 0){
                print STDERR "$modname: Failed to create '$rdir/$dst\n";
                build_cleanup($build_area, $modname);
                `rm -rf $rdir`;
                if(-d $rdir_prepop){
                    `mv $rdir_prepop $rdir`
                }
                exit -1;
            }

            if($type eq 'F'){
                @fatmp = ();
                push @fatmp, glob("$src");
                foreach $fname (@fatmp){
                    if(! -f "$fname"){
                        next;
                    }
                    `cp $fname $rdir/$dst`;
                    if($? != 0){
                        print STDERR "$modname: Failed to copy $fname to '$rdir/$dst\n";
                        build_cleanup($build_area, $modname);
                        `rm -rf $rdir`;
                        if(-d $rdir_prepop){
                            `mv $rdir_prepop $rdir`
                        }
                        exit -1;
                    }
                    if($modes ne ""){
                        ($fname1) = $fname =~ /([^\/]*)$/;
                        `chmod $modes $rdir/$dst/$fname1`;
                        if($? != 0){
                            print STDERR "$modname: Failed to modify the modes on '$rdir/$dst/$fname1' to '$modes'\n";
                            build_cleanup($build_area, $modname);
                            `rm -rf $rdir`;
                            if(-d $rdir_prepop){
                                `mv $rdir_prepop $rdir`
                            }
                            exit -1;
                        }
                    }
                }
            }
            elsif($modes ne ""){
                print STDERR "$modname: Mode specified in Directory line in Release.list: '$line'\n";
                build_cleanup($build_area, $modname);
                `rm -rf $rdir`;
                if(-d $rdir_prepop){
                    `mv $rdir_prepop $rdir`
                }
                exit -1;
            }
            else{
                $old_dir = `pwd`;
                chop $old_dir;
                if(! -d $src){
                    print STDERR "$modname: Source directory '$src' doesn't exist\n";
                    build_cleanup($build_area, $modname);
                    `rm -rf $rdir`;
                    if(-d $rdir_prepop){
                        `mv $rdir_prepop $rdir`
                    }
                    exit -1;
                }
                chdir $src;
                if($? != 0){
                    print STDERR "$modname: Failed to cd to '$src'\n";
                    build_cleanup($build_area, $modname);
                    `rm -rf $rdir`;
                    if(-d $rdir_prepop){
                        `mv $rdir_prepop $rdir`
                    }
                    exit -1;
                }
                `find . -print | egrep -v '/CVS\$|/CVS/' | cpio -pdum $rdir/$dst 2>&1`;
                if($? != 0){
                    print STDERR "$modname: Failed to copy directory '$src'\n";
                    build_cleanup($build_area, $modname);
                    `rm -rf $rdir`;
                    if(-d $rdir_prepop){
                        `mv $rdir_prepop $rdir`
                    }
                    exit -1;
                }
                chdir $old_dir;
                if($? != 0){
                    print STDERR "$modname: Failed to cd back to '$old_dir'\n";
                    build_cleanup($build_area, $modname);
                    `rm -rf $rdir`;
                    if(-d $rdir_prepop){
                        `mv $rdir_prepop $rdir`
                    }
                    exit -1;
                }
            }
        }
        else{
            print "$modname: Bogus line in Release.list '$line'\n";
            build_cleanup($build_area, $modname);
            `rm -rf $rdir`;
            if(-d $rdir_prepop){
                `mv $rdir_prepop $rdir`
            }
            exit -1;
        }
    }
    
    print "$modname:\n";
    print "$modname: Doing gmake clean prior to releasing source\n";

    open FP, "gmake clean 2>&1 |" or die "Failed to kick off gmake clean: $!";
    while(<FP>){
        print "$modname: $_";
    }
    $rc = $?;
    close(FP);

    if($rc != 0){
        print STDERR "$modname: gmake clean failed\n";
        build_cleanup($build_area, $modname);
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }

    print "$modname: Releasing source\n";
    
    `mkdir $rdir/$tag`;
    if($? != 0){
        print STDERR "$modname: Making $rdir/$tag failed\n";
        build_cleanup($build_area, $modname);
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }
    `find . -print | egrep -v '/RPMS/|/CVS/|/FAKE_RELEASE_AREA/|/FAKE_RELEASE_AREA\$|/CVS\$' | cpio -pdum $rdir/$tag 2>&1`;
    if($? != 0){
        print STDERR "$modname: Copying source failed\n";
        build_cleanup($build_area, $modname);
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }
    `ln -s $tag $rdir/SRC`;
    print "$modname: Adding read permissions to everything in the release area\n";
    `chmod -R a+r $rdir`;
    if($? != 0){
        print STDERR "$modname: Failed to add read permissions to the release area\n";
        build_cleanup($build_area, $modname);
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }
    print "$modname: Adding execute (search) permissions to all dirs in the release area\n";
    `find $rdir -type d -print | xargs chmod a+x`;
    if($? != 0){
        print STDERR "$modname: Failed to add execute (search) permissions to the dirs in the release area\n";
        build_cleanup($build_area, $modname);
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }
    if("$cmd" ne "-repop-rbuild" && $rdir =~ /^\/slingshot\/PATCHES/){
        `touch $rdir/CANDIDATE`;
        if($? != 0){
            print STDERR "$modname: Failed to add CANDIDATE flag file to release area\n";
            build_cleanup($build_area, $modname);
            `chmod -R a+w $rdir`;
            `rm -rf $rdir`;
            if(-d $rdir_prepop){
                `mv $rdir_prepop $rdir`
            }
            exit -1;
        }
    }
    if("$cmd" eq "-repop-rbuild"){
        `touch $rdir/.REPOPULATED`;
    }
    print "$modname: Removing write permissions from release area\n";
    `chmod -R a-w $rdir`;
    if($? != 0){
        print STDERR "$modname: Failed to remove write permissions from release area\n";
        build_cleanup($build_area, $modname);
        `chmod -R a+w $rdir`;
        `rm -rf $rdir`;
        if(-d $rdir_prepop){
            `mv $rdir_prepop $rdir`
        }
        exit -1;
    }
    if("$cmd" eq "-repop-rbuild" && -d "$rdir_prepop/BRANCHES"){
        `chmod +w $rdir_prepop`;
        `chmod +w $rdir`;
        `chmod +w $rdir_prepop/BRANCHES`;
        `mv $rdir_prepop/BRANCHES $rdir`;
        if($? != 0){
            print STDERR "$modname: (1) Failed to move existing BRANCHES tree back\n";
            build_cleanup($build_area, $modname);
            `mv $rdir_prepop $rdir`;
            if($? != 0){
                print STDERR "$modname: (2) Double ZOIKES, failed to move $rdir_prepop to $rdir\n";
            }
            exit -1;
        }
        `chmod +w $rdir/BRANCHES`;
        `chmod -w $rdir`;
    }

    if(-d "$rdir_prepop"){
        `find $rdir_prepop -type d -print | xargs chmod +w`;
        if($? != 0){
            print STDERR "$modname: Failed to add write permissions to $rdir_prepop prior to removal\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
        `rm -rf $rdir_prepop`;
        if($? != 0){
            print STDERR "$modname: Failed to remove $rdir_prepop\n";
            build_cleanup($build_area, $modname);
            exit -1;
        }
    }
    if("$cmd" eq "-repop-rbuild"){
    }
    elsif($is_branch == 0){
        `rm -f $rbase/LATEST $rbase/LATEST_IS*`;
        `ln -s $rstub $rbase/LATEST`;
        if($? != 0){
            print STDERR "$modname: Failed to create LATEST link\n";
            print STDERR "$modname: ***RELEASE AREA IS MESSED UP (no LATEST links)****\n";
            build_cleanup($build_area, $modname);
            `rm -rf $rdir`;
            exit -1;
        }

        `ln -s $rstub $rbase/LATEST_IS-$tag`;
        if($? != 0){
            print STDERR "$modname: Failed to create LATEST_IS link\n";
            print STDERR "$modname: ***RELEASE AREA IS MESSED UP (no LATEST links)****\n";
            build_cleanup($build_area, $modname);
            `rm -rf $rdir`;
            exit -1;
        }
    }

    print "$modname: Cleaning up after build ($pwd) $modname $modname\_tmp\n";
    chdir "$pwd";
    build_cleanup($build_area, $modname);

    $rc = pbuild_defeat_nfs_cache($rdir);
    if($rc != 0){
        print STDERR "$modname: Zoikes, NFS cache fiddling failed\n";
    }
    if("$cmd" eq "-rbuild" || "$cmd" eq "-brbuild"){
        $tmp = sprintf "build_log/%d", time();
        if(open FPO, ">$tmp"){
            printf FPO "%s %s %s\n", $modname, $tag, $rdir;
            close FPO;
        }
    }
    
}

return 1;
