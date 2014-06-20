#!/usr/bin/perl -w

use Time::Local;
#use POSIX qw(strftime);
use POSIX qw(mktime);

my(@date) = (localtime)[3,4,5];
$date[2]+=1900; $date[1]+=1;
my $today = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
$date[2]%=100;
my $today2 = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
print $today . " " . $today2 . "\n";

my $book = 'Rowling J. K. Harry Potter and the half-blood prince 19/06/06';

use Data::Dumper;

my @bookdate = ($book =~ m/.* (\d\d)\/(\d\d)\/(\d\d)$/);

print Dumper(@bookdate);

print "days" if ($bookdate[0] == $date[0]) ;
print "month" if ($bookdate[1] == $date[1]) ;
print "year" if ($bookdate[2] == $date[2]) ;

my(@bookd) = localtime();
@bookd[0..2] = (0,0,0);
@bookd[3..5] = ($bookdate[0], $bookdate[1]-1, $bookdate[2]+100);
my $bookts = &mktime(@bookd);

my $nowts = time();

print "bookts: " . $bookts . "nowts: " . $nowts . "\n";

$days = ($nowts - $bookts) / (60*60*24);

print "days: " . $days . "\n";
