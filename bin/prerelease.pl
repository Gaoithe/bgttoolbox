#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/prerelease.pl,v 1.3 2010/08/31 15:13:46 brian Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

sub prerelease_chksum{
    my($wkdir) = @_;
    my($sum);

    $sum = `cvs -Q status $wkdir | egrep "File:|Working revision" | sed -e '{N\ns/\\n//\n}' | LC_ALL=C sort | egrep -v "CHANGES|Module.versions.release" | md5sum`;
    
    chop $sum;
    $sum =~ s/^(\S+).*$/$1/;

    return "$sum";
}
