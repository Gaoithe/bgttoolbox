#!/usr/bin/perl

use strict;
use warnings;


my($file) = $ARGV[0];
if (!$file)  {
    die("Usage: timesheetread.pl timesheetfile");
}

open(FILE,"<$file");

foreach (<FILE>)  {
  chomp($_);
  if (m/^(\d+):(.*):(.*)$/) {
    print scalar(localtime($1)) . "\t". $1 . "\t" . $2 . "\t" . $3 . "\n";
  } else {
    print STDERR "Ignoring badly formatted line: $_\n";
  }
}
