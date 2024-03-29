#!/usr/bin/env perl
#
# $Name: v2-31-43 $
# $Header: /homes/bob/cvsroot/sbe/get_release_list.pl,v 1.25 2010/05/19 19:56:25 ray Exp $
#
# This module provides the functionality to read "Release.list" and augment it
# with "magic" lines.
#

$^W = 1;
use strict 'vars';
$| = 1;

sub get_release_list {

    my(@lines, $line, @files, $f, $f1);

    @lines = ();
    if(! -f "Release.list"){
        print STDERR "No Release.list file\n";
        exit -1;
    }

    for $f ("Release.list", glob("Release.list.*.custom")){
        open FP, "$f" or die "Cannot open $f : $!";
        while(<FP>){
            chop;
            $line = $_;
            $line =~ s/^\s*//;
            $line =~ s/\s*$//;
            if($line =~ /^#/ || $line =~ /^$/){
                next;
            }
            push @lines, $line
        }
        close FP;
    }

    if(-f "Metaversions"){
        push @lines, "F Metaversions misc/Metaversions";
    }

    if(-f "ARCH.SUPPORT"){
        push @lines, "F ARCH.SUPPORT misc/ARCH.SUPPORT";
    }

    if(-f "build.auto.plan"){
        push @lines, "F build.auto.plan misc/build.auto.plan";
    }

    if(-f "RPM.VERSION"){
        push @lines, "F RPM.VERSION misc/RPM.VERSION";
    }

    if(-f "Deliverables"){
        push @lines, "F Deliverables misc/Deliverables";
    }

    if(-f "Makefile.exp"){
        push @lines, "F Makefile.exp misc/Makefile.exp";
    }

    if(-d "cconf"){
        push @lines, "D cconf cconf";
    }

    if(-d "gparams"){
        push @lines, "D gparams gparams";
    }

    if(-f "stats.snmp"){
        push @lines, "F stats.snmp snmp/stats.snmp";
    }

    if(-f "stats.txt_part"){
        push @lines, "F stats.txt_part snmp/stats.txt_part";
    }

    if(-f "stats.html_part"){
        push @lines, "F stats.html_part snmp/stats.html_part";
    }

    if(-f "pstats.txt_part"){
        push @lines, "F pstats.txt_part snmp/pstats.txt_part";
    }

    if(-f "pstats.html_part"){
        push @lines, "F pstats.html_part snmp/pstats.html_part";
    }

    if(-f "events.snmp"){
        push @lines, "F events.snmp snmp/events.snmp";
    }

    if(-f "events.txt_part"){
        push @lines, "F events.txt_part snmp/events.txt_part";
    }

    if(-f "events.html_part"){
        push @lines, "F events.html_part snmp/events.html_part";
    }

    if(-f "alarms.snmp"){
        push @lines, "F alarms.snmp snmp/alarms.snmp";
    }

    if(-f "alarms.txt_part"){
        push @lines, "F alarms.txt_part snmp/alarms.txt_part";
    }

    if(-f "alarms.html_part"){
        push @lines, "F alarms.html_part snmp/alarms.html_part";
    }

    if(-d "migration"){
        push @lines, "D migration migration";
    }

    if(-f "deployment.fletch.list"){
        push @lines, "F deployment.fletch.list misc/deployment.fletch.list"
    }

    if(-f "deployment.fletch.spec_list"){
        push @lines, "F deployment.fletch.spec_list misc/deployment.fletch.spec_list"
    }
# Misc files

    @files = ();

    push @files, glob("*.fletch");
    push @files, glob("*.libdeps");
    push @files, glob("*.ndd");
    push @files, glob("*.pyxdef");
    push @files, glob("*.pxi");
    push @files, glob("*_gen_fletch.ccd");
    push @files, glob("*.tbx_logic_info");
    push @files, glob("*.ced");
    push @files, glob("*.menu");
    push @files, glob("*.tree");
    push @files, glob("*.leaf");
    push @files, glob("cdi-extract.*");
    push @files, glob("Deliverables.*.custom");
    push @files, glob("*_glider_defn_gen.ccd");
    push @files, glob("*.glider");

    foreach $f (@files){
        push @lines, "F $f misc/$f";
    }

    foreach $f (glob("*.ccd")) {
        $f1 = $f;
        $f1 =~ s/\.ccd$//;
        if(!in_array("$f1\.ccd", \@lines) and !auto_generated($f)) {
            push @lines, "F $f misc/$f";
        }
    }

# Include files

    @files = ();

    push @files, glob("corrib_base_gen_*.h");

    foreach $f (@files){
        push @lines, "F $f inc/$f";
    }

# Java files

#   @files = ();

#   push @files, glob(".../*.class");

#   foreach $f (@files){
#       push @lines, "F $f java/$f";
#   }

    return @lines;
}

sub auto_generated {
    my ($file) = @_;

    open F, $file or print STDERR "Failed to open $file : $!";
    my ($line);

    while (<F>) {
        chop;
        $line = $_;
        if($line =~ /^\s*$/) {
            next;
        }
        if($line =~ /^#\s*IS_AUTOGENERATED_SO_ALLOW_AUTODELETE=YES/) {
            close F;
            return 1;
        }
    }
    close F;

    return 0;
}

sub in_array {
    my ($needle, $haystack) = @_;

    foreach my $hay_strand (@{$haystack}) {
        if ($hay_strand =~ /$needle\s/) {
            return 1;
        }
    }

    return 0;
}

return 1;
