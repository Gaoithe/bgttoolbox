#!/usr/bin/perl -w

use strict;

my ($verbose,$timeout,$scripttorun);
$timeout=120; # default

while ($ARGV[0] =~ /-/) {
    if ($ARGV[0] =~ /-v/) { 
        $verbose = shift;
    } elsif ($ARGV[0] =~ /-t/) { 
        shift;
        $timeout = shift;
    } elsif ($ARGV[0] =~ /-s/) { 
        shift;
        $scripttorun = shift;
    } else {
        print "unknown option: " . shift() . "\n";
    }
}

my $files = \@ARGV;

unless ($$files[0]) { die "usage $0 [-t <timeout>] [-s script to run] <list of files to monitor>\n"; }

my (%oldsearch,%search);

while (1) {

    foreach my $file (@{$files}) {
        #print "file $file\n";
        my $search_result = `tail -30 $file | grep 'Now'`;
        $search{$file} = $search_result;
        if ($? != -1){
            #print "compare:".$search{$file}."and".$oldsearch{$file}{'search'}."\n";

            if (!defined($oldsearch{$file}{'search'}) || ($search{$file} ne $oldsearch{$file}{'search'})){
                #print "file $file ".$search{$file}."\n";
                $oldsearch{$file}{'search'} = $search{$file};
                $oldsearch{$file}{'time'} = time;
                print "file $file ".$search{$file}."o".$oldsearch{$file}{'time'}."o".$oldsearch{$file}{'search'}."\n";
            } else {

                # TODO: no change timeout alarm
                my $delta = time - $oldsearch{$file}{'time'};
                if ($delta > $timeout) {
                    print "ALERT: file $file not changed in $delta secs\n";
                    if (!defined($oldsearch{$file}{'notify'})){
                        if (defined($scripttorun)){
                            #`$scripttorun $file $delta`;
                            `xterm -title "ALERT: $file" -e "tail -30 $file;/bin/bash" &` 
                        }
                        $oldsearch{$file}{'notify'} = $?;
                    }
                }
            }



        } else {
            print "humm?\n";
        }
    }

    sleep 5;
}



