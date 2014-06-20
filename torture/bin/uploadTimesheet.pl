#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
use IO::Select;
use Mail::Send;
use Sys::Hostname;
use Time::Local;

## Declare our variables
my($conf, %conf, $key, $hostname, $sock, $line, $header, $bytes, %proj);

# Setup up mail variables
my ( $login ) = getpwuid( $< );
my $mail_from = "$login\@doolin.com";
my $mailtype = "sendmail";
my $mailarg = "-f ".$mail_from;


## Get the arguments or die!
$conf = $ARGV[0];
unless ($conf) { mail_and_die("1: Usage:\n\tuploadTimesheet.pl conffile\n"); }


## Parse the conffile
%conf = &parseConf($conf);


## Try to get our hostname to give it to the server
$hostname = hostname();
$hostname = $hostname? $hostname : $conf{"user"};
## TODO: Hostname should really be untainted

# Don't upload empty timesheet files!
mail_and_die("0: Empty timesheet file " . $conf{ "timesheet" })
  if ( -z $conf{ "timesheet" });


# Open timesheet file (before opening socket - treat socket gently)
open(TS, "<".$conf{"timesheet"}) 
    or mail_and_die("1: Error opening ". $conf{"timesheet"} . "\n");

## Open sesame
$sock = new IO::Socket::INET(PeerAddr => $conf{"server"},
				PeerPort => $conf{"port"},
				Proto => "tcp",
				Type => SOCK_STREAM)
	or mail_and_die("1: Couldn't connect to ".$conf{"server"}
				.":".$conf{"port"}."\n");


## Read in the timesheet file and write it to the socket
$header = $conf{"user"} . ":" . time() . "\n";
$bytes = $sock->syswrite($header, length($header));

while ($line = <TS>)  {
    chomp($line);
    next if $line =~ /^\s*$/;
    $line = $line . "\n";
    $bytes = $sock->syswrite($line, length($line));
    unless($bytes) {
	close($sock);
	mail_and_die("1: Couldn't write to socket\n");
    }
}
## Send '.' to end writing section
$bytes = $sock->syswrite(".\r\n", 3);
unless($bytes) {
    close($sock);
    mail_and_die("1: Couldn't write to socket\n");
}

## Read project list
while (defined(my $row = $sock->getline)) {
    last if ($row =~ /^\.\n$/);
    chomp($row);
    $proj{$row} = 1;
}

## Write out the new project list
open(PF, ">".$conf{"projects"}) 
    or mail_and_die("2: Error opening ". $conf{"projects"} . "\n");
foreach my $name (keys(%proj) ) {
    print PF "$name\n";
}

## Finish up, close files and socket
close($sock);
close(TS);
close(PF);


####################
## Archive timesheet
####################

# check for archive directory
if (!(-e $conf{"archive"}) ) {
    my $err = mkdir($conf{"archive"});
    if ($err != 1) {
	print "Error creating archive directory: $!\n";
	mail_and_die("2: Timesheet not archived.\n");
    }
}
my(@date) = (localtime)[3,4,5];
my $timesheet_name = $conf{"timesheet"};
$timesheet_name =~ s/.*\///;
my $archive_file = sprintf("%s/%s.%02d.%02d.%04d", $conf{"archive"},
	$timesheet_name, $date[0],$date[1]+1,$date[2]+1900);

# check to see if this timesheet already exists in the archive
if (-e $archive_file) {
    my $i = 0;
    my $flag;
    while (!$flag) {
	$i++;
	next if (-e "$archive_file.$i");
	$archive_file = sprintf("%s.%d",$archive_file,$i);
	$flag = 1;
    }
}

# archive the file
system("mv ".$conf{"timesheet"}." $archive_file");

###############
## Sub-routines
###############

## sub parseConf - reads config file into a hash
sub parseConf($) {
    my($line,%conf);
    open(CONF, "<$conf") or mail_and_die("1: Error opening $conf\n");
    while ($line = <CONF>) {
        my @line = split(/=/, $line);
	chomp($line[0]) if (defined $line[0]);
	chomp($line[1]) if (defined $line[1]);
	##TODO: All items from conf should be untainted
        $conf{$line[0]} = $line[1];
    }
    close(CONF);
    return %conf;
}

sub mail_and_die {

    my $msg = shift;

    my $mail_to = $conf{"email"};
    if (!defined($conf{"email"})) {
	my $login = getlogin();
	$mail_to = "$login\@localhost.localdomain" 
    }

    my $mail = new Mail::Send;
    $mail->set('To', $mail_to);
    $mail->set('From',$mail_from);
    $mail->set('Subject','Timesheet upload failed!');

    my $mailprog = $mail->open($mailtype,$mailarg);
    print $mailprog "Timesheet upload failed.  N.B. please fix these errors!\n".
		    "If a level '1' error, you need to upload your ".
		    "timesheet again,\notherwise if a level '2' error, ".
		    "please ensure that you have a projects\nfile and your ".
		    "timesheet has been archived correctly.\n\n";
    print $mailprog $msg;
    print $mailprog "\nPlease do not upload another day's timesheet until ".
		    "these errors have been fixed.\nNote, this script may ".
		    "be set to run from crontab.\n";
    $mailprog->close;

    if ($sock) { close($sock); }
    die($msg);
}
