#!/usr/bin/perl -w

# receivesms-tofile.cgi
#   
#  demo/prototype code for kannel sms server http://www.kannel.org
#  configure this script to be triggered by sms server receiving sms
#  this script receives sms and logs details to a file
#  parses received message and calls other url or sends sms
#
#  Doolin Technologies http://www.doolin.com
#
##############################################################################

use CGI qw(fatalsToBrowser); # send fatal error messages to the browser
use strict;

# file to log sms into
my $smsrxlogfile = "/tmp/receivedsms.log";
# server and port of kannel's sendsms service and username/password/smsc name/...
my $kannelurltosend = "http://localhost:13013/cgi-bin/sendsms?username=kannelusername&password=kannelpassword&dlrurl=kanneldlrurl&dlrmask=&smsc=kannelsmsc&from=receivesms-tofile.cgi";

my $cgiq = new CGI; # create new CGI object and store it in $q
my $script = $cgiq->script_name;

print $cgiq->header;

print <<END;
<html><head><title>SMS rx test tool</title>
<link rel="shortcut icon" href="smsrx.png" type="image/x-icon"></head>
</head><body>
<h1>SMS rx test tool</h1>
<hr>
END

# much better to use LWP
sub getURL {
   my $url = shift;
   return `wget "$url" -o /tmp/wget.log -O -`;
}

################## get timestamp and cgi params #################

my $time = time;

my $forminFrom = $cgiq->param('from');
my $forminTo = $cgiq->param('to');
my $forminCmd = $cgiq->param('cmd');
my $forminText = $cgiq->param('text');
my $forminSmscid = $cgiq->param('smscid');
my $formindr1 = $cgiq->param('dr1');
my $formindr2 = $cgiq->param('dr2');
my $forminUser = $cgiq->param('user');
my $forminCoding = $cgiq->param('coding');
my $forminCharset = $cgiq->param('charset');
my $forminUdh = $cgiq->param('udh');

################### log script call / sms receive to file ######

sub logtofile {
    my $text = shift;
    my $logfile=$smsrxlogfile;
    if ($logfile) {
        if (!open(OUTFILE, ">>$logfile")) {
	    print "Can't open $logfile for writing: $!\n";
	    die "Can't open $logfile for writing: $!\n";
	}
        print $text;
        print OUTFILE $text;
        close(OUTFILE);
    }
}


logtofile( time().": script ".$script."\n" );
my $details="";
$details .= "From: " . $forminFrom . ", ";
$details .= "To: " . $forminTo . ", ";
$details .= "Cmd: " . $forminCmd . ", ";
$details .= "Text: " . $forminText . ", ";
$details .= "Smscid: " . $forminSmscid . ", ";
$details .= "dr1: " . $formindr1 . ", ";
$details .= "dr2: " . $formindr2 . ", ";
$details .= "User: " . $forminUser . ", ";
$details .= "Coding: " . $forminCoding . ", ";
$details .= "Charset: " . $forminCharset . ", ";
$details .= "Udh: " . $forminUdh . "\n";
logtofile( $details );

if ($forminFrom ne "") {

    # we can parse message and do stuff
    # e.g. send sms as response
    # e.g. call other scripts
    # e.g. retrieve and/or store info in database

    # keyword parse, then reply to keyword sms with an sms
    my $keywords = "(add|get|set|del|help)";
    if (my ($keyword, $rest) = $forminText =~ m/^($keywords)(.*)$/i) {
        logtofile("Keyword " . $keyword . " match, rest: " . $rest . "\n");
	my $message = "test reply to sms with keyword " . $keyword;
	my $urltosend = $kannelurltosend . "&to=$forminTo&text=$message";
        logtofile("Hit url: " . $urltosend . "\n");
        my $response = getURL $urltosend;
        print "<b>Result: ".$response."</b><hr>";
        logtofile("Result: " . $response . "\n");

    # register pin/serial with account/new account
    # very liberal regexp matches ANY number 
    # (of 5+ digits) (before and after optional non numeric)
    } elsif (my ($begg,$serial,$ing) = 
	       $forminText =~ m/([^0-9]|^)([0-9][0-9][0-9][0-9][0-9][0-9]*)([^0-9]|$)/ ) {

        print "<p>Register serial number " . $serial . "\n" ;
        logtofile("Register serial number " . $serial . "\n");
        my $urltosend = "http://localhost/cgi-bin/addpintoaccount.cgi?phone=$forminFrom&serial=$serial&text=$forminText";
        logtofile("Hit url: " . $urltosend . "\n");
        my $response = getURL $urltosend;
        print "<b>Result: ".$response."</b><hr>";
        logtofile("Result: " . $response . "\n");

    } else { 
        print "no serial, no match, no action"; 
        logtofile("no serial, no match, no action\n");
	# normal services would send sms response indicating message was not parsed
        # IF the mobile user is paying also for the response!
    }

}

print <<END;
</body></html>
END

exit;


=head1 NAME

receivesms-tofile.cgi - receive sms in form of a http call (for kannel)

=head1 DESCRIPTION

kannel can be configured to hit a url upon receipt of sms.

This script sits on that url and logs the details of the sms received 
 to a file when it is accessed.

=head1 USAGE

Install this script in an apache cgi-bin enabled area.
Configure kannel to trigger call to this script upon receipt of sms.

There are more examples that come with kannel.
Look in the contrib directory.
I see a python script smstomail.cgi

I have other over-complicated test scripts that can send or receive sms and
also logs/selects to/from database and shows status information.
This script requires perl's CGI lib which comes with perl base installs.

=head1 INSTALLATION

Hmmm, This might seem over complicated but it is quite simple really.
Don't be scared.
This is very easy stuff once you have done it once.

You will need to be a teeny bit of an admin and developer I think if
 you want to test and install this script.

Refer to kannel, apache and mod_perl documentation for full details. 

  http://www.kannel.org/
  http://httpd.apache.org/
  http://perl.apache.org/
  http://perl.apache.org/docs/2.0/user/intro/start_fast.html#Configuration

=head2 1. install apache, perl and kannel

   Install perl (with cpan CGI) 
   Install apache configured and mod_perl ... or whatever :).
   Install kannel and configure with active or test sms server connections.
    ... whatever again with hand waving

   Easy enough to do these installs with linux package managers e.g. rpms

=head2 2. Place this script into /usr/local/sms-cgi-bin/

   Change permissions so that apache user has permission to run it.
   (debug this after step 3 by checking apache error logs).

=head2 3. Configure a cgi-bin enabled directory which apache will serve up this script under HTTP.

   Edit apache config file
     on suse /etc/httpd/httpd.conf.local
     on redhat /etc/httpd/conf/httpd.conf

   e.g.
   ScriptAlias /sms-cgi-bin "/usr/local/sms-cgi-bin/"
   <Directory "/usr/local/sms-cgi-bin/"
    AllowOverride All
    Options ExecCGI
    Order allow,deny
    Allow from all
   </Directory>

=head2 4. Restart apache (as root)

   on redhat /etc/init.d/httpd restart
   on suse /etc/init.d/apache2 restart

=head2 5. Configure kannel to hit url and call this script (and restart kannel)

  group = sms-service
  keyword = default
  # %u %A (s45 not used)
  get-url = "http://localhost/sms-cgi-bin/receivesms-tofile.cgi?from=%p&to=%P&text=%a&smscid=%i&dr1=%d&user=%n&coding=%c&charset=%C"
  max-messages = 0
  concatenation = true
  #catch-all = true

  restart kannel. (if you run it as a service as root: /etc/init.d/kannel restart)
 
=head1 TEST
 
=head2 1. call script from command line

     perl receivesms-tofile.cgi
     # the script will object to not having cgi params with uninitialized value errors
     # script should make entry in sms log file /tmp/receivedsms.log

=head2 2. call url of script directly

     browse to (or call wget "<url>" or lynx --dump "<url>" on)
     http://localhost/sms-cgi-bin/receivesms-tofile.cgi?from=cmdlinetest&to=12345&text=cmd+line+test
     check apache access and error logs
     check sms log file /tmp/receivedsms.log

     test keyword parsing and serial parsing:
     http://localhost/sms-cgi-bin/receivesms-tofile.cgi?from=cmdlinetest&to=12345&text=add+match+keyword

     http://localhost/sms-cgi-bin/receivesms-tofile.cgi?from=cmdlinetest&to=12345&text=match+serial+12345678

=head2 3. send sms to kannel and check that kannel calls the url of script

     Infinite sms loops are very funny so be careful when testing.

     Check logfile to receive sms exists and apache user can write to it.
     Again watch apache's error_log (/var/log/[httpd|apache*]/error_log).
     Watch kannel's logs.

=head1 DESIGN

This is only a test script after all.

Configuration details should be loaded from a config file.

=cut
