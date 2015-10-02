#!/usr/bin/perl
#http://www.perlmonks.org/?node_id=342561

=head1 NAME

check_www.pl - check website is still working AND DNS working page not sneakily served up with register365 ads.

=head1 SYNOPSIS

=head1 USAGE

e.g. check that body contains "Welcome to Glencullen Dundrum MDS"
$ ~/bin/check_www.pl -v http://glencullendundrum.com "Welcome to Glencullen Dundrum MDS"

e.g. in crontab every 6 hours
# every 6 hours test website
* 1,7,13,19 * * * ~/bin/check_www.pl http://glencullendundrum.com "Welcome to Glencullen Dundrum MDS" -m 353861953134 -e gaoithe@gmail.com

=cut

use strict;
use warnings;

use Getopt::Long;
use LWP::Simple;
use Data::Dumper;
use Pod::Usage;
use Mail::Sendmail;
#use MIME::Lite;
use Sys::Hostname;
use Socket;

our $veryverbose;
our $verbose;
our $gUrl="";
our $gGet="";
our $gMsisdn="";
our $gEmail="";

sub add_option_item {
    our ($gUrl,$gGet);
    my $OO = shift;
    print @{[Data::Dumper->Dump([\$OO], ['*OO'])]} if ($veryverbose);
    if (!$gUrl) { 
        $gUrl = $OO->name;
    } elsif (!$gGet) { 
        $gGet = $OO->name;; 
    }
    print("set gUrl=$gUrl gGet=$gGet\n") if ($verbose);
}

sub fail {
    our ($gUrl,$gGet,$gMsisdn,$gEmail);
    my $message = shift;
    # OPEN ALARM. send email
    # TODO: keep persistent fail status per URL on disk to throttle 

    my $host = `hostname`;
    chomp($host);
    my $addr = inet_ntoa(scalar(gethostbyname($host)) || 'localhost');
    my $uname = `uname -a`;
    chomp($uname);
    my $user = `whoami`;
    chomp($user);
    my $date = gmtime();

    if ($gEmail) {

        sendmail(
            From    => "$gEmail",
            To      => "$gEmail",
            Subject => "check_www.pl FAIL url=$gUrl $message ${user}\@${host}",
            Message => "check_www.pl FAIL url=$gUrl\n\
 $message\n\
 date: $date\n
 gGet: $gGet\n\
 user: $user\n\
 host: $host\n\
 addr: $addr\n\
 uname: $uname\n\
",
            );
    }

    if ($gMsisdn) {
        # TODO exec 
        `~/bin/sendsms.pl $gMsisdn "check_www.pl FAIL url=$gUrl $message ${user}\@${host}"`;
    }

    die $message;
}

my $rc = GetOptions(
    q(help|h|?+)        => \my $help,
    q(verbose|v+)       => \$verbose,
    q(msisdn|m:s)       => \$gMsisdn,
    q(email|e:s)        => \$gEmail,
    '<>'                => \&add_option_item,
);

print "DEBUG: OPTIONS rc=$rc help=$help\n" if ($verbose);

if (!$rc || $help || !$gUrl) {
    pod2usage(q(-verbose) => 2,
              q(-sections) => "NAME|SYNOPSIS|USAGE",
              q(code) => 1,
        );
    exit 0;
}

my $h = head($gUrl);
if (!$h) {
    fail "The Server for url=$gUrl is DOWN!!!!" 
} else {
    print "h=$h\n" if ($veryverbose);
    print @{[Data::Dumper->Dump([\$h], ['*h'])]} if ($verbose);
}

# need to use get to check content.
# when dns fails page is served but advertising content.
my $g = get($gUrl);
if (!$g) {
    fail "get $gUrl fail"
} else {
    #print "g=$g\n" if ($veryverbose);
    if ($g =~ $gGet) {
        print "get match success gGet:$gGet\n";
        print "g:$g\n" if ($veryverbose);

        # whip out tags and show summary of plain ascii alpha-numeric content
        $g =~ s/<[^<>]*>//g;
        $g =~ s/[^a-zA-Z0-9 ]//g;
        print "g:$g\n" if ($verbose);

        # test the fail methods
        fail "get match Success."

    } else {
        fail "get match fail gGet:$gGet"
    }        
}
