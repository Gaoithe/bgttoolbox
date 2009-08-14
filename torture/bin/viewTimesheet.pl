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

  # open easytimer timesheet file and view it, 
  # also show datestamps of times all days of month
  ./viewTimesheet.pl -warnmissing -verbose ~/.easytimer/timesheet

  ## DONE: passin multiple timesheet files or config files

  # ascii barfic view of a month  (limited to viewing data from one file)
  cat ~/.easytimer/archive/timesheet*.08.2004* |sort >~/.easytimer/timesheetall.08.2004
  ./sbin/viewTimesheet.pl -g ~/.easytimer/timesheetall.08.2004 

  ## TODO: add up counts for multiple files passed in and show overall summary

=head1 DESCRIPTION

This script allows user to view date & time info in timesheet file.
Also, with -w or -m (-warnmissing) option, outputs 9am, lunchtimes, 5:30pm every day (for full month).
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

my($infile, %conf, $key, $line, $header );

## Get the arguments
my ($verbose, $warnmissing, $graph);
while ($ARGV[0] =~ /-/) {
    if ($ARGV[0] =~ /-v/) { 
	$verbose = shift;
    } elsif ($ARGV[0] =~ /-w/) { 
	$warnmissing = shift;
    } elsif ($ARGV[0] =~ /-m/) { 
	$warnmissing = shift;
    } elsif ($ARGV[0] =~ /-g/) { 
	$graph = shift;
    } else {
	die "unknown option: " . shift;
    }
}

$verbose=1 if ((!defined($graph) || !$graph) && (!defined($warnmissing) || !$warnmissing) );

my $view = 1;
my @weekday = ( "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" );

print "hour:  x0xx 1   2   3   4   5   6   7  x8xx 9  10  11  12  13  14  15  16  17  18xx19  20  21  22  23xx\n".
    "Day md\n" if ($graph);

my (%graphdata,$countref);

# do it once anyway even if argv undefined
do {
    my $timesheetfile = readConfOrTimesheetFile(shift);
    $countref = processOneTimesheet($timesheetfile);
} until !defined($ARGV[0]);


if ($graph) {
    #print "\n chart key: " . $graphdata{charkey} . "\n";
    #for(uniq sort @{$graphdata{chartkey}}) {
    foreach $key (keys %{$graphdata{chartkey}}) {
	print $key.",";
    }
    print " \n"; # gnehehehehehe hehehehhe :)
}






sub readConfOrTimesheetFile {
    my $infile = shift;

    unless ($infile) {
	#die("Usage:\n\t$0 conffile\n");
	print("Usage:\n\t$0 [-v[erbose] [-w[arnmissing] conffile\n\t OR\n\t$0 timesheetfile\n\n");
	my $tfile = "$ENV{HOME}/.easytimer/timesheet";
	my(@date) = (localtime)[3,4,5];
	my $today_file = sprintf("%s.%04d.%02d.%02d", $tfile,
				 $date[2]+1900, $date[1]+1, $date[0] );
	return $today_file;
    } else {
	$_ = $infile;
	if (m/.conf$/) {
	    # magical oh config file. alright "do what I mean" behaviour
	    %conf = &parseConf($infile);
	    ## Parse the conffile
	    return $conf{"timesheet"};
	} else {
	    # otherwise assume it's a timsheet file
	    return $infile;
	}
    }
}

#       0    1    2     3     4    5     6     7     8
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
#    localtime(time);
	# day, month, year $date[0],$date[1]+1,$date[2]+1900;
sub timePrint {
    my $secs = shift;
    my $minutes = int ($secs / 60);
    $secs -= $minutes * 60;
    my $hours = int ($minutes / 60);
    $minutes -= $hours * 60;
    return sprintf("%02d:%02d:%02d",$hours,$minutes,$secs);
}

sub processOneTimesheet {
    my $timesheetfile = shift;

    print "Looking at Timesheet $timesheetfile \n" if ($verbose);

    ## Read in the timesheet file and print it
    open(TS, "<".$timesheetfile) 
	or die("Error opening ". $timesheetfile . "\n");

    my $lasttimestamp = 0;
    my ($yesterday530pm_ts, $yesterday530pm_str) = (0, "");

    # TBD diff times and total entries
    my ( %count, %totalsec, $lasttime, $lastproj);

    if ($graph) {
	#print "Day    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24\n";
	
        # I actially have timesheet entries starting midnight (either I or easytimer puts them in wrap over day)
	# so can't use minutes == 0 to rely on if we started something or not
	$graphdata{begin}=1; 
	$graphdata{min}=0; 
	$graphdata{char}=".";
    }

    my @today0am_date;
    while ($line = <TS>)  {
	chomp($line);
	next if !$line;
	my @lines = split(/:/,$line);
	#my $line_str = gmtime($lines[0]);
	my $line_date = localtime($lines[0]);

	# perl note: increment undefined value => get 1?
	# add up total entries & total times logged
	$count{$lines[1]}++;
	if ($lasttime && $lastproj) {
	    $totalsec{$lastproj} += $lines[0]-$lasttime;
	}
	$lasttime=$lines[0];
	$lastproj=$lines[1];

	my @timestamp_datetime = localtime($lines[0]);
	@today0am_date = localtime($lines[0]);
	@today0am_date[0..2] = (0, 0, 0); # midnight today 0:00:00
	my $today0am_ts = &mktime(@today0am_date);
	my $today9am_ts = $today0am_ts + 9*60*60;
	my $today9am_str = localtime($today9am_ts);
	my $today530pm_ts = $today9am_ts + 8*60*60 + 1*30*60;
	my $today530pm_str = localtime($today9am_ts);

	# check for missing days
	while ($warnmissing && $lasttimestamp + 24*60*60 < $lines[0]) {
	    
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

	    #warn "last $lasttimestamp today $today0am_ts\n";
	    if ($graph && $graphdata{min}!=0) {
		graphFromTo(\%graphdata, 24 * 60 + 15); #char,oldmin,min
		print "\n";
		$graphdata{begin}=1;
		$graphdata{min}=0;
		$graphdata{weekday}=$weekday[$today0am_date[6]];
		$graphdata{mday}=sprintf("%02d",$today0am_date[3]);
		##$graphdata{char}=".";
	    }

	    if ($warnmissing) {
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

	} else {

	    if ($graph) {
		#$graphdata{time}=$lines[0];
		$graphdata{weekday}=$weekday[$today0am_date[6]];
		$graphdata{mday}=sprintf("%02d",$today0am_date[3]);
		my ($m,$h) = @timestamp_datetime[1..2];
		graphFromTo(\%graphdata, $h * 60 + $m);
		$graphdata{char} = substr( $lines[1], 0, 1 ); # first char of project
		$graphdata{charkey} .= $lines[1]." ";
		#push( @{$graphdata{chartkey}}, ($lines[1]));
		$graphdata{chartkey}{$lines[1]} = $graphdata{charkey};
		#print "graphdata $h $m project is ::" . $lines[1] . "::char is ::".$graphdata{char}."::" . "\n";
	    }
	}
	

	$line = $line . "\n";
	$line = $line_date . "==" . $line if ($view);
	if ($verbose) {
	    print $line;
	}

	$yesterday530pm_ts = $today530pm_ts;
	$yesterday530pm_str = $today530pm_str;
	$lasttimestamp = $lines[0];
    }

    if ($graph && $graphdata{min}!=0) {
	graphFromTo(\%graphdata, 24 * 60 + 15); #char,oldmin,min
	print "\n";
	$graphdata{begin}=1;
	$graphdata{min}=0;
	$graphdata{weekday}=$weekday[$today0am_date[6]];
	$graphdata{mday}=sprintf("%02d",$today0am_date[3]);
	#$graphdata{char}=".";
    }

    close(TS);

    #TODO could do if now not too far away from last time (3/4 hrs)
    # then add this time to that $totalsec{$lastproj}
    if ($lastproj ne "non_work") {
	print "Warning: last entry not non_work, total for $lastproj not accurate.\n";
    }

    # show daily summary
    if ($verbose) {
	print "\n";
	foreach my $key (keys(%count)) {
	    print "$count{$key} $key entries total time ".
		timePrint($totalsec{$key})."\n";
	}
    }
    
    return \%count;
    #return \%graphdata;
}

sub graphFromTo {
    my $graphdata = shift;
    my $tomin = shift;

    # debug

    # remember not to do a timeslot repeatedly
    $graphdata->{oldmin} = $graphdata->{min}
        if (!defined($graphdata->{oldmin}) || 
	    $graphdata->{begin} ||
	    $graphdata->{min} > $graphdata->{oldmin} );

    if ($graphdata->{begin}){
	if (defined($graphdata->{weekday})) {
	    print $graphdata->{weekday}." ";
	} else {
	    print "DDD ";
	}
	if (defined($graphdata->{mday})) {
	    print $graphdata->{mday}." ";
	} else {
	    print "?? ";
	}
	$graphdata->{begin} = 0;
    }

    #print STDERR "From To " . $graphdata->{oldmin} .",". $graphdata->{oldmin}/15 .",". $graphdata->{min} .",". $tomin;

    $graphdata->{min} = $tomin - ($tomin%15);	
    # careful to avoid duplicate timeslot assignment
    # e.g. 0:00 - 9:10 => 0 15 30 45 60 ... 540
    #      9:10 - 9:30 => 540(=9:00) 555 570  (we have used 540(=9:00) twice
    # by rounding we avoid dupes
    # e.g. 0:00 - 9:10(round to 9:00) => 0 15 30 45 60 ... 525 (and not 540 see <$graphdata->{min})
    #      9:10 - 9:30 => 540(=9:00) 555 570 

    # for every 15 min timeslot print action
    #$graphdata->{oldmin} = (($graphdata->{oldmin} + 14.999) / 15 ) * 15;
    #print STDERR "Ano " . $graphdata->{oldmin} .",". $graphdata->{min} . "\n";

    for(my $m=$graphdata->{oldmin};$m<$graphdata->{min};$m+=15) {
	print $graphdata->{char};
    }
    $graphdata->{oldmin}=$graphdata->{min}; # remember where we finished here
}


###############
## Sub-routines
###############

## sub parseConf - reads config file into a hash
sub parseConf() {
    my $infile = shift;
    my($line,%conf);
    open(CONF, "<$infile") or die("Error opening $infile\n");
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

#Thu 29 ..................................................TTTTTTTTTTTTTTTTTTTTTTTnnnnnnnnnnnnnnnnnnnnnn
# one short
