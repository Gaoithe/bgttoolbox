#!/usr/bin/perl

=head1 NAME

viewTimesheet.pl - reads timesheet file and outputs contents with date & time

=head1 SYNOPSIS

  # see the "usage" message, open default timesheet and view it 
  ./viewTimesheet.pl

  # open easytimer configfile, find timesheet file name there, open that timesheet and view it
  ./viewTimesheet.pl /etc/easytimer.conf

  # open easytimer timesheet file and view it
  ./viewTimesheet.pl ~/.easytimer/timesheet

=head1 DESCRIPTION

This script allows user to view date & time info in timesheet file.
Also outputs 9am, lunchtimes, 5:30pm every day (for full month).
Useful for editing timesheets where there are missing entries.

=head2 Operation

Default timesheet is $ENV{HOME}/.easytimer/timesheet 
Otherwise parse config file and look for timesheet= entry.
Otherwise try open file passed in on command line.

Gets first time in timesheet file.
Then figures out first working day of that month.
Prints non_work entries for all days which have no close real timesheet entries.

=head2 Limitations, TBDs, not TBDs

Very very very verbose output. Reduce this (add option).

Was more useful when I forgot more to fill in timesheet.
Still useful on occasion.
I believe possibly everyone in office has an equivalent script/method to 
retrospectively fill in timesheets so this may help reduce duplication of effort?

=cut

use strict;
use warnings;
use IO::Select;
use Time::Local;
use POSIX qw(strftime);
use POSIX qw(mktime);

## Declare our variables
my($conf, %conf, $key, $line, $header );

## Get the arguments or die!
$conf = $ARGV[0];
unless ($conf) {
    #die("Usage:\n\t$0 conffile\n");
    print("Usage:\n\t$0 conffile\n\t OR\n\t\t$0 timesheetfile\n");
    $conf{"timesheet"} = "$ENV{HOME}/.easytimer/timesheet";
    my(@date) = (localtime)[3,4,5];
    my $today_file = sprintf("%s.%04d.%02d.%02d", $conf{"timesheet"},
			     $date[2]+1900, $date[1]+1, $date[0] );
    $conf{"timesheet"} = $today_file;
} else {
    $_ = $conf;
    if (m/timesheet/) {
        $conf{"timesheet"} = $conf;
    } else {
        ## Parse the conffile
        %conf = &parseConf($conf);
    }
}

my $view = 1;

####################
## Date & Time
####################

#       0    1    2     3     4    5     6     7     8
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
#    localtime(time);
	# day, month, year $date[0],$date[1]+1,$date[2]+1900;

print "Looking at Timesheet $conf{timesheet} \n";

####################
## Read in the timesheet file and print it
####################

open(TS, "<".$conf{"timesheet"}) 
    or die("Error opening ". $conf{"timesheet"} . "\n");

my $lasttimestamp = 0;
my ($yesterday530pm_ts, $yesterday530pm_str) = (0, "");

while ($line = <TS>)  {
    chomp($line);
    my @lines = split(/:/,$line);
    #my $line_str = gmtime($lines[0]);
    my $line_date = localtime($lines[0]);

    my @today0am_date = localtime($lines[0]);
    @today0am_date[0..2] = (0, 0, 0); # midnight today 0:00:00
    my $today0am_ts = &mktime(@today0am_date);
    my $today9am_ts = $today0am_ts + 9*60*60;
    my $today9am_str = localtime($today9am_ts);
    my $today530pm_ts = $today9am_ts + 8*60*60 + 1*30*60;
    my $today530pm_str = localtime($today9am_ts);
        
    # check for missing days
    while ($lasttimestamp + 24*60*60 < $lines[0]) {

	if ($lasttimestamp == 0) {
	    my @startofmonth_date = localtime($lines[0]);
	    @startofmonth_date[0..3] = (0, 0, 0, 1); # 1st day of month 0:00:00
	    $lasttimestamp = &mktime(@startofmonth_date) - 1; # day b4 1st day of month 23:59:59
	    next;
	}

	my @last9am_date = localtime($lasttimestamp + 24*60*60); # 9am next day
	@last9am_date[0..2] = (0, 0, 9); # that day 9:00:00
	my $last9am_ts = &mktime(@last9am_date);
        my $last9am_str = localtime($last9am_ts);
	my $last530pm_ts = $last9am_ts + 8*60*60 + 1*30*60;
        my $last530pm_str = localtime($last530pm_ts);
        
	if ($last9am_date[6] >= 1 && $last9am_date[6] <= 5) { # is a workday
	    #print "Add entry for 9am $last9am_ts $last9am_str\n";
	    #print "Last 5:30am $last530pm_ts $last530pm_str\n";
	    print "$last9am_str==" if ($view); 
	    print "$last9am_ts:non_work:9am there was no entry $last9am_str\n";

	    # an hour is long for lunch but also covers everything else in day
	    my $lastlunch_ts = $last9am_ts + 4*60*60;
	    my $lastlunch_str = localtime($lastlunch_ts);
	    print "$lastlunch_str==" if ($view); 
	    print "$lastlunch_ts:non_work:lunch etc... $lastlunch_str\n";
	    $lastlunch_ts = $last9am_ts + 5*60*60;
	    $lastlunch_str = localtime($lastlunch_ts);
	    print "$lastlunch_str==" if ($view); 
	    print "$lastlunch_ts:non_work:lunch etc... $lastlunch_str\n";

	    print "$last530pm_str==" if ($view);
	    print "$last530pm_ts:non_work:530pm there was no entry $last530pm_str\n";
	}

	#$lasttimestamp = $last9am_ts + 17*60*60; # midnight
	$lasttimestamp = $last530pm_ts; # honesty is the best policy

    }

    # if we are on new day 
    if ($lasttimestamp < $today0am_ts) {
	# if missing entry about 530pm for old day
	if ($lasttimestamp < $yesterday530pm_ts) {
	    print "$yesterday530pm_str==" if ($view);
	    print "$yesterday530pm_ts:non_work:530pm there was no entry $yesterday530pm_str\n";
	}
	# if missing entry about 9am for new day
	if ($today9am_ts < $lines[0]) {
	    print "$today9am_str==" if ($view);
	    print "$today9am_ts:non_work:9am there was no entry $today9am_str\n";
	}
    }

    $line = $line . "\n";
    $line = $line_date . "==" . $line if ($view);
    print $line;

    $yesterday530pm_ts = $today530pm_ts;
    $yesterday530pm_str = $today530pm_str;
    $lasttimestamp = $lines[0];
}

## Finish up, close files
close(TS);


###############
## Sub-routines
###############

## sub parseConf - reads config file into a hash
sub parseConf() {
    my($line,%conf);
    open(CONF, "<$conf") or die("Error opening $conf\n");
    while ($line = <CONF>) {
        my @line = split(/=/, $line);
	chomp($line[0]);
	chomp($line[1]);
	##TODO: All items from conf should be untainted
        $conf{$line[0]} = $line[1];
    }
    close(CONF);
    return %conf;
}
