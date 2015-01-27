#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/modvers.pl,v 1.38 2011/05/25 13:45:34 brian Exp $
#

use strict 'vars';

sub build_overrides{
    my($wa) = @_;
    my($dir, $mf, @oa, $d, $tmp, $line);
    my(%rdirs);

    %rdirs = ();

    @oa = ();
    
    open FIND, "find $wa -type f -name Module.versions.template -print |" or die "Cannot kick off find: $!";
    while(<FIND>){
        chop;
        $dir = $_;
        $dir =~ s/\/[^\/]*$//;
        $mf = $dir . "/Makefile";
        if(-f $mf){
            open FP, "$mf" or die "Cannot open '$mf': $!\n";
            while(<FP>){
                chop;
                $line = $_;
                if(($d) = $line =~ /^\s*\#\s*RELEASE_DIR\s*=\s*(\S+)/){
                    if(defined $rdirs{"$d"}){
                        $tmp = $rdirs{"$d"};
                        print STDERR "Two workareas claim to be instances of '$d'\n";
                        print STDERR "    1) $tmp\n";
                        print STDERR "    2) $dir\n";
                        exit -1;
                    }
                    if(-d "$dir/FAKE_RELEASE_AREA"){
                        $dir .= "/FAKE_RELEASE_AREA"
                    }
                    $rdirs{"$d"} = $dir;
                }
            }
            close FP;
        }
        
    }
    close FIND;
    return %rdirs;
}

sub modvers{
    my(@args) = @_;
    my($vname, $dbase, $l, $majr, $minr, $plvl, $dir, $i, $wkdir, $ofile, %wao);
    my($d, $tmp, $txt, $branch, $done, $br_refs, $nbr_refs, $initial_branch);
    my($max, $tmp1, $f, $mad);
    my(%vname_hash);

    %wao = ();
    %vname_hash = ();

    if(0){
        print STDERR "Global overrides(2):\n";

        foreach $d  (keys %main::overrides){
            print STDERR "      $d $main::overrides{$d}\n";
        }
        print STDERR "**********************************************************************\n";
    }


    
    $mad = "\$(MOS_ALL_DIRS)";
    
    if(0){
        for($i = 0; $i <= $#args; $i++){
            print "Args[$i] to modvers: $args[$i]\n";
        }
    }
    
    while($#args >= 0 && $args[0] =~ /^-/){
        if($args[0] eq "-workarea"){
            if($#args < 1){
                print STDERR "Need directory name for -workarea\n";
                exit -1;
            }
            shift @args;
            if(! -d $args[0]){
                print STDERR "$args[0] isn't a directory\n";
                exit -1;
            }
            %wao = build_overrides($args[0]);
            foreach $d  (keys %wao){
                if(defined($main::overrides{"$d"})){
                    print STDERR "Override for $d is overriding the discovered workarea\n";
                }
            }
        }
        shift @args;
    }
    if($#args < 0 || $#args >1){
        printf STDERR "Bogus args, expected one or two, actually %d\n",  $#args + 1;
        exit -1;
    }
    $wkdir = shift @args;
    if($#args == 0){
        $ofile = shift @args;
    }
    else{
        $ofile = "-";
    }

    $br_refs = 0;
    $nbr_refs = 0;

    open FP, "$wkdir/Module.versions.template" or
      die "Failed to open $wkdir/Module.versions.template: $!";
    if($ofile ne "-"){
        open FPO, ">$ofile" or
          die "Failed to open $ofile for output: $!";
    }
    $tmp = '$Name: v2-31-43 $';
    $tmp =~ s/\$Name:\s*//;
    $tmp =~ s/\s*\$$//;
    
    if(!($tmp =~ /v\d-\d\d-\d\d/)){
        $tmp = "Local Work Area";
    }
    $txt  = "#\n";
    $txt .= "# SBE Version: '$tmp'\n";
    $txt .= "#\n";

    if($ofile ne "-"){
        print FPO $txt;
    }
    else{
        print $txt;
    }

    while(<FP>){
        $l = $_;
        chop $l;
        if($l =~ /^\s*\#/){
            next;
        }
        if($l =~ /^\s*$/){
            next;
        }
        $txt = "";

        if((($vname, $dbase, $branch) = $l =~ /^\s*(\S+)\s*=\s*\[\s*(\S+)\s+(\S+)\s*\]\s*/) == 3){
            $br_refs++;

            if($br_refs == 1){
                $tmp = `head -1 $wkdir/CHANGES`;
                if($tmp =~ /^v\d-\d\d-\d\d-[a-z](..)/){
                    $initial_branch = 0;
                    if(("$1" eq "00") || ("$1" eq "xx")){
                        #
                        # 
                        #
                        # BK: Loosening up the restriction that attempted
                        # to make the initial release on the branch identical
                        # to the non-branched version. This is having
                        # less and less value.
                        #
                        # $initial_branch = 1;
                    }
                }
                else{
                    print STDERR "There are branch references but top of CHANGES is bogus\n";
                    exit -1;
                }
            }

            $tmp = `grep '\x24Header: ' $dbase/v*/Makefile`;
            if(!($tmp =~ /cvsroot\/(.*)\/Makefile,v\s/)){
                print "Cannot work out module from Makefile\n";
                exit -1;
            }
            $tmp = $1;

            open CVS, "cvs -Q -z9 co -r $branch -p $tmp/CHANGES |" or
              die "Cannot start cvs: $!";
            $tmp = "";
            while(<CVS>){
                if($tmp eq "" && $_ =~ /^v\d-\d\d-\d\d-([a-z]\d\d)\s*$/){
                    $tmp = $1;
                }
            }
            close(CVS);

            if("$tmp" ne ""){
                $dir = "$dbase/BRANCHES/$tmp";
                if($initial_branch){
                    $dir =~ s/\d\d$/00/;
                }
                if($dir =~ /00$/){
                    if(! -d "$dir"){
                        $dir =~ s/\/BRANCHES\/.*$//;
                    }
                }

            }
            else{
                $dir = $dbase;
            }

            ($tmp) = $dbase =~ /^(.*)\/v\d\/\d\d\/\d\d.*/;

            if(defined($wao{"$tmp"})){
                $dir = $wao{"$tmp"};
                print STDERR "Workarea override: '$dbase' --> $dir\n";
            }
        }
        elsif((($vname, $dbase) = $l =~ /^\s*(\S+)\s*=\s*\[\s*(\S+)\s*\]\s*/) == 2){
            $nbr_refs++;
            $dbase =~ s/\/$//g;
            if(defined($main::overrides{"$dbase"})){
                $dir = $main::overrides{"$dbase"};
                $dir =~ s/-/\//g;
                $dir = "$dbase/$dir";
                print STDERR "Version override for '$dbase' as $dir\n";

            }
            elsif(defined($wao{"$dbase"})){
                $dir = $wao{"$dbase"};
                print STDERR "Workarea override: '$dbase' --> $dir\n";
            }
            else{
                ($majr, $minr, $plvl) = find_latest($dbase);
                if($majr eq ""){
                    print STDERR "Cannot determine latest release area for: $dbase\n";
                    exit -1;
                }
                $dir = "$dbase/$majr/$minr/$plvl";
            }
        }
        elsif($l =~ /^output>\s+(\S.*$)/){
            $txt = "$1\n";
            while($txt =~ /\{(\S+)\}/){
                $tmp = $1;
                if(!defined ($vname_hash{"$tmp"})){
                    print STDERR "Unrecognised variable: $tmp\n";
                    exit -1;
                }
                $txt =~ s/\{\S+\}/$vname_hash{"$tmp"}/;
            }
            if($txt =~ /\`(.*)\`/){
                $tmp = `$1`;
                $txt =~ s/\`(.*)\`/$tmp/;
            }
        }
        else{
            print STDERR "Ungrokable line in Module.versions.template: $l\n";
            exit -1;
        }

        if($txt eq ""){
            $txt = "$vname=$dir\n";
            $vname_hash{"$vname"} = "$dir";
            $mad = "\$($vname) $mad";

            if(-f "$dir/misc/Metaversions" || -f "$dir/rpm.info"){
                $txt .= "include \$($vname)/misc/Metaversions\n";
            }

            $txt .= check_for_makefile_exp($dir, "\$($vname)");
        }
        
        if($ofile ne "-"){
            print FPO $txt;
        }
        else{
            print $txt;
        }
    }
    if(!($wkdir =~ /^\//)){
        $tmp = `pwd`;
        chop $tmp;
        $tmp .= "/$wkdir";
    }
    else{
        $mad = "$mad $wkdir";
        $tmp = $wkdir;
    }

    $mad = "$mad $tmp";

    $txt  = "#\n";
    $txt .= "#__MODVERS_WKDIR__ $tmp\n";
    $txt .= "#\n";
    $txt .= "MOS_ALL_DIRS:=$mad\n";
    $txt .= "#\n";
    $txt .= "# DELETE FROM HERE FOR Metaversions\n";
    $txt .= "#\n";


    $txt .= check_for_makefile_exp($wkdir, $tmp);
    if($ofile ne "-"){
        print FPO $txt;
    }
    else{
        print $txt;
    }

    if($ofile ne "-"){
        close FPO;
    }
    if($nbr_refs != 0 && $br_refs != 0){
        print STDERR "Mixture of branched and non-branched references in Module.versions.template\n";
        exit -1;
    }
}

sub check_for_makefile_exp{
    my($dir, $rep) = @_;
    my($txt);
    if(-f "$dir/Makefile.exp"){
        $txt= "EXPORTED_MAKEFILES += $rep/Makefile.exp\n";
    }
    elsif(-f "$dir/misc/Makefile.exp"){
        $txt = "EXPORTED_MAKEFILES += $rep/misc/Makefile.exp\n";
    }
    else{
        $txt = "";
    }
    $txt =~ s/\/\//\//g;
    return $txt;
}

return 1;
