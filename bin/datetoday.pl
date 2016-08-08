#! /bin/perl
# http://stackoverflow.com/questions/38825424/perl-get-time-stamp-of-a-file-and-check-is-this-today-or-not

if($#ARGV < 0){
    print STDERR "Usage: $0 <file>  ARGC:$#ARGV\n";
    exit -1;
}
my $f = $ARGV[0];

use File::stat;
my $ts = stat($f)->mtime;
print "ts:$ts";
print " date/time " . localtime($ts) . "\n";

my $time = localtime;
my @time = localtime;
print "time:$time\n";    
print "time array: " . join (":", (@time)) . "\n";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
use Time::Local;
my $btime = timelocal(0,0,0,$mday,$mon,$year);
my $etime = timelocal(59,59,23,$mday,$mon,$year);
print "btime:$btime " . localtime($btime) . " etime:$etime " . localtime($etime) . "\n";
print "year:$year\n";

if (($ts >= $btime) && ($ts <= $etime)) {
   print "File:$f time $ts (".localtime($ts).") is TODAY.\n";
} else {
   print "File:$f time $ts (".localtime($ts).") is NOT today.\n";
   if ($ts < $btime) {
       print "File is BEFORE today. $ts < $btime\n";
   } elsif ($ts > $etime) {
       print "File is in FUTURE. $ts > $etime\n";
   } else {
       print "KERBOOM.\n"
   }
}


#Can't locate Time/Piece.pm in @INC . . $ sudo cpan -i Time::Piece
use Time::Piece;
my $file_date = localtime($ts);

if ($file_date->date eq localtime->date) {
    print "file:$f was created today.\n";
}


