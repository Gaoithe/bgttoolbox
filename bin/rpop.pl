#!/usr/bin/env perl
#
# $Name: v2-31-43 $ $Header: /homes/bob/cvsroot/sbe/rpop.pl,v 1.9 2007/01/26 10:17:49 brian Exp $
#
# This module provides the functionality to populate release areas
#

$^W = 1;
use strict 'vars';
$| = 1;

require "get_release_list.pl";

sub release_populate {
    my($modname, $rdir) = @_;
    my(@lines, $line, $type, $src, $dst, $modes, $rmp, $old_dir, $tmp, $fname);
    my(@fatmp,$fname1);

    if(!($rdir =~ /^\//)){
        $tmp = `pwd`;
        chop $tmp;
        $rdir = "$tmp/$rdir";
    }

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
                return -1;
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
                        return -1;
                    }
                    if($modes ne ""){
                        ($fname1) = $fname =~ /([^\/]*)$/;
                        `chmod $modes $rdir/$dst/$fname1`;
                        if($? != 0){
                            print STDERR "$modname: Failed to modify the modes on '$rdir/$dst/$fname1' to '$modes'\n";
                            return -1;
                        }
                    }
                }
            }
            elsif($modes ne ""){
                print STDERR "$modname: Mode specified in Directory line in Release.list: '$line'\n";
                return -1;
            }
            else{
                $old_dir = `pwd`;
                chop $old_dir;
                if(! -d $src){
                    print STDERR "$modname: Source directory '$src' doesn't exist\n";
                    return -1;
                }
                chdir $src;
                if($? != 0){
                    print STDERR "$modname: Failed to cd to '$src'\n";
                    return -1;
                }
                `find . -print | egrep -v '/CVS\$|/CVS/' | cpio -pdum $rdir/$dst 2>&1`;
                if($? != 0){
                    print STDERR "$modname: Failed to copy directory '$src'\n";
                    return -1;
                }
                chdir $old_dir;
                if($? != 0){
                    print STDERR "$modname: Failed to cd back to '$old_dir'\n";
                    return -1;
                }
            }
        }
        else{
            print "$modname: Bogus line in Release.list '$line'\n";
            return -1;
        }
    }
    return 0;
}
return 1;
