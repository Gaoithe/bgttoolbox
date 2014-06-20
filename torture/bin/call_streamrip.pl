#!/usr/bin/perl

=head1 NAME

call_streamrip.pl - parse m3u and call streamripper

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Operation

oops

jamesc@greeneagle-desktop:~/video/summer2008$ mp3info -t "/home/jamesc/mmp3/-.mp3" 
No MP3 files specified!
jamesc@greeneagle-desktop:~/video/summer2008$ mp3info -x /home/jamesc/mmp3/-.mp3 
File: /home/jamesc/mmp3/-.mp3
Title:                                  Track: 
Artist:  lnt
Album:                                  Year:  
Comment:                                Genre:  [255]
Media Type:  MPEG 2.5 Layer III
Audio:       Variable KB/s, 11KHz (mono)
Emphasis:    none
CRC:         No
Copyright:   No
Original:    Yes
Padding:     No
Length:      1:32

jamesc@greeneagle-desktop:~/video/summer2008$ mp3info -alnt /home/jamesc/mmp3/-.mp3 


jamesc@greeneagle-desktop:~/video/summer2008$ mp3info -x /home/jamesc/mmp3/Michael\ Jackson/Thriller-Number_Ones.mp3 
File: /home/jamesc/mmp3/Michael Jackson/Thriller-Number_Ones.mp3
Title:   Thriller                       Track: 5
Artist:  Michael Jackson
Album:   Number Ones                    Year:  2003
Comment:                                Genre: Pop [13]
Media Type:  MPEG 1.0 Layer III
Audio:       192 KB/s, 44KHz (joint stereo)
Emphasis:    none
CRC:         No
Copyright:   No
Original:    Yes
Padding:     Yes
Length:      5:12


mp3info -F -p"artist:%a\ntitle:%t\ntid:%n\next:%e\n"  /home/jamesc/mmp3/Michael\ Jackson/Thriller-Number_Ones.mp3 
artist:Michael Jackson
title:Thriller
tid:5
ext:none

jamesc@greeneagle-desktop:~/video/summer2008$ mp3info -F -p"artist:%a\nalbum:%l\ntitle:%t\ntid:%n\next:%e\nfname:%f\n"  /home/jamesc/mmp3/Michael\ Jackson/Thriller-Number_Ones.mp3 
artist:Michael Jackson
album:Number Ones
title:Thriller
tid:5
ext:none
fname:Thriller-Number_Ones.mp3


MEH:
callsr_28855_.mp3 does not have an ID3 1.x tag.
callsr_28855_.mp3 does not have an ID3 1.x tag.
callsr_28855_.mp3 does not have an ID3 1.x tag.
mp3info al  tr BAD.mp3 trid  ti  ext .mp3
out /home/jamesc/mmp3//BAD.mp3-.mp3



=cut


use strict;
use warnings;

my $basedir="$ENV{HOME}/mmp3";
mkdir -p $basedir;

## Get the arguments
my ($verbose,$donothing);
my $dne = "";
while ($ARGV[0] =~ /^-/) {
    if ($ARGV[0] =~ /^-v/) { 
	$verbose = shift;
    } elsif ($ARGV[0] =~ /^-n/) { 
	$donothing = shift;
	$dne="echo ";
    } else {
	system ("echo err:unknownopt >>$basedir/callsr.log");
	die "unknown option: " . shift;
    }
}

sub process {
    my $file = shift;

    print "Looking at $file \n" if ($verbose);

##EXTM3U
##EXTINF:0,Blade Runner -01- Main Titles.mp3
#EXTINF:243,16 - The Black Eyed Peas - Bonus Track Do What You Want - Monkey Business

#EXTM3U
#EXTINF:234,Another Part Of Me.mp3
#http://www.monkeymagic.org/index.php?streamsid=4535&c=35-443932684&stag=da9dc54871ccc540&file=.mp3

#http://www.monkeymagic.org/index.php?streamsid=1103&c=35-443932104&stag=PFjUR%2B%2B%2BxUA%3D&file=.mp3
# ../mp3/tom_waits/small_change/01-tom_trauberts_blues.mp3

    ## Read in the timesheet file and print it
    open(TS, "<".$file) 
	or die("Error opening ". $file . "\n");

    my $fname = "gurk"; my $dir = "gurk";
    my ($album,$tr,$trid,$title,$ext) = ("noalbum","notrack","notid","notitle","noext");

    while (<TS>)  {
	chomp; chomp;
	$_ =~ s/$//;

	next if !$_;

        if (m/^\#EXTINF:/) {
	    print "EXTINF $_ eol\n";
	    $title="";
	    ($album,$tr,$trid,$title,$ext) = m/\#EXTINF:[0-9,]+(.*) *- *([0-9]*)(.*) *- *(.*)(\..*)*/;
	    if ($title == "") {
		($album,$tr,$trid,$title,$ext) = m/\#EXTINF:[0-9,]+([0-9]*)(.*) *-* *(.*)(\..*)*/;
	    }

	    $album =~ s/[ -]*$//;
	    $album =~ s/^[ -]*//;
	    $title =~ s/[ -]*$//;
	    $title =~ s/^[ -]*//;
	    $trid  =~ s/[ -]*$//;
	    $trid =~ s/^[ -]*//;
	    $trid =~ s/ /_/g;

	    if ( ! defined $ext ) {
		$ext = ".mp3";
	    } 

	    print "EXTINF al $album tr $tr trid $trid ti $title ext $ext\n";
	    $dir = "$basedir/$album";
            mkdir $dir;
	    my $utitle = $title; $utitle =~ s/ /_/g;
            $fname = $tr . $trid . "-" . $utitle . $ext;
	    print "EXTINF fn $fname\n";
	}

        if (m/^http/) {
	    chomp $_;
	    $_ =~ s/$//;
	    print "http $_ eol\n";
	    #my $cmd = $dne."wget -c \"$_\" -O \"$dir/$fname\"";
	    my $cmd = $dne."wget -c \"$_\" -O \"callsr_${$}_.mp3\"";
	    system ("echo cmd=$cmd >>$basedir/callsr.log");	    
	    system($cmd);

	    #my $mp3info = `${dne}mp3info -x callsr_${$}_.mp3`;
	    #print "mp3info=$mp3info\n";
	    if ($album == "" || $album == "noalbum") {
	        $album = `${dne}mp3info -F -p"%l" callsr_${$}_.mp3`;
            }
	    #my $artist = `${dne}mp3info -F -p"%a" callsr_${$}_.mp3`;
	    if ($title == "" || $title == "notitle") {
		$title = `${dne}mp3info -F -p"%t" callsr_${$}_.mp3`;
	    }
	    if ($trid == "" || $trid == "notid") {
		$trid = `${dne}mp3info -F -p"%n" callsr_${$}_.mp3`;
	    }

	    $dir = "$basedir/$album";
            mkdir $dir;
	    my $utitle = $title; $utitle =~ s/ /_/g;
            $fname = $tr . $trid . "-" . $utitle . $ext;

	    print "mp3info al $album tr $tr trid $trid ti $title ext $ext\n";
	    print "out $dir/$fname\n";

	    $cmd=$dne."mv callsr_${$}_.mp3 \"$dir/$fname\"";
	    system($cmd);
	}

    }

    close(TS);

    if ($verbose) {
	print "\n";
    }
    
}

system ("echo \"process $ARGV[0]\" >>$basedir/callsr.log");
process $ARGV[0];

