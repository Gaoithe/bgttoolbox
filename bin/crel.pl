#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/crel.pl,v 1.2 2005/11/16 18:17:55 lorcan Exp $
#

sub crel{
    my($dir) = @_;
    if(! -d $dir){
        print STDERR "$dir does not exist or isn't a directory\n";
        exit -1;
    }

    my($majr, $minr, $plvl) = find_latest($dir);
    if($majr eq ""){
        $majr = $minr = $plvl = "*";
    }
    print "$majr $minr $plvl\n";
    exit 0;
}


return 1;
