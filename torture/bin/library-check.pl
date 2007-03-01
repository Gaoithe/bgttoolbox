#!/usr/bin/perl -w

=head1 NAME

library-check.pl - login to deansgrange library, renew books when close to due date, report status

=head1 SYNOPSIS

run daily as a cron job

set library account details in script:

my $BORROWER="D200000011111";
my $PIN=7777;
my $MAILTO="me\@trashmail.net";
my $MAILPROG="mail -r me\@trashmail.net"; # my qmail is configured not-so-goodly :-7
my $RENEW_DAYS=3; # no days before book is due to renew it
my $ANNOY_DAYS=3; # annoy before due

=head1 DESCRIPTION

We forgot to renew our books in time AGAIN.

This script logs in to deansgrange library using your account number and pin.
Gets info on each book that is out.
Checks date for each book.
Attempts to renew each book (if renewal is needed).
Reports status by email if anything interesting happened. (renewal success/failed or if books overdue)

My first go using WWW::Mechanize seems to have gone alright really all things considered.
WWW::Mechanize itself very nicely done, clean interface, all the right things.
Please note that I have not done many right things with this script!

=head1 INSTALLATION/USE

If you use this then BEWARE: it might work for a while, but someday the cron will
just not happen or network will go down or _something_ will occur which will make the script
not work or fail to email AND ...*!horrors!*... your books will go overdue and you will be fined!
So as with anything: use with caution.

Will run on any system that can do perl and send email.
Use perl's cpan to install WWW::Mechanize and other needed perl modules.
Best on linux of course.

Set it up to run daily as cron (or Windows scheduled task).

On my Suse 9.1 e.g. 
sudo cp library-check.pl /usr/local/bin/
sudo cp run-library-check.sh /etc/cron.daily/

run-library-check.sh looks like this:

  #!/bin/bash

  BORROWER=D2000000111111
  PIN=1111
  MAILTO="me@foo.org,fi@call.ok"
  MAILPROG="mail -r me@goo.org"
  # my qmail is configured not-so-goodly :-7

  # add path for library-check.pl script for cron user
  # export $PATH=$PATH:/usr/local/bin

  # use -M to force mail to be sent every time script is run (good for testing)
  #library-check.pl -M -m "$MAILPROG" $BORROWER $PIN $MAILTO

  # while loop around library-check with sleep in case network is down 
  # check return value $?

  RETVAL=77
  while [[ $RETVAL != 0 ]] ; do
    library-check.pl -m "$MAILPROG" $BORROWER $PIN $MAILTO
    RETVAL=$?
    if [[ $RETVAL != 0 ]] ; then
       echo Failed to run. :-7 RETVAL is $RETVAL. Sleep 600 and try again. 
       sleep 600
       echo Here we go again ...
    fi
  done
 
  echo Success. I think.
  date

=head1 TODO

DONE: (in run script) If network down then should sleep and retry later.
Fatal errors should mail a (maybe different) user (the maintainer of the cron) and log to system log.
Put config items as command-line options.
Use WWW:Mechanizes onerror as well as just checking for errors.
Tidy.
Blog.

=head1 JUNK

wget http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000111111&borrower2=7777
less dun_laog-cat.sh\?enqtype\=BORROWER 

jamesc@dhcppc0:~/tmp> egrep -i "form|input" dun_laog-cat.sh\?enqtype\=BORROWER 
<HEAD><TITLE>Borrower Information</TITLE></HEAD>
<FORM METHOD=POST onsubmit="return borrower_form_Validator(this)" name="borrower_form">
<INPUT TYPE=hidden NAME=enqtype VALUE=BORROWER>
<INPUT TYPE=hidden NAME=enqpara1 VALUE=query>
<INPUT TYPE=hidden NAME=language VALUE=>
<INPUT NAME=borrpara1 TYPE=text SIZE=14 MAXLENGTH=14>
<INPUT NAME=borrpara2 TYPE=PASSWORD SIZE=4 MAXLENGTH=4></P>
<INPUT TYPE=SUBMIT VALUE="Search">&nbsp;&nbsp;
<INPUT TYPE=reset VALUE="Clear Entry">
<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&language="><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/borrower-button2.gif" HSPACE=3 BORDER=0 ALT="Borrower Information"></A>
</FORM>

=head1 AIE! Web page hs changed Feb 2007

login here:
http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh

form  name ="borr_entry" method="post" onsubmit="return borrower_valid(this)" action="">
<input type="hidden" name="session_no" value="10040"/>
<input type="hidden" name="time" value=""/>
<input type="hidden" name="enqtype" value="MENU"/>
<input type="hidden" name="enqpara1" value="query"/>
<input type="hidden" name="from" value=""/>
<span class="bold">Please enter your library card number</span>
<input name="borrpara1" type="text " size="14" maxlength="14" value=""/>
<script language="javascript" type="TEXT/JAVASCRIPT">
<!--
document.borr_entry.borrpara1.value = "";
document.borr_entry.borrpara1.focus();
// -->
</script>
<label for="borrpara2"><span class="bold">and PIN</span></label>
<input name="borrpara2" id="borrpara2" type="password" size="4" maxlength="4" value=""/>
<input type="hidden" name="end" value="1">
<br/>
<input type="submit" value="Login" title="Login button" />
<input type="reset" value="Clear" title="Clear button" />
<br/>
</form>

=cut

use WWW::Mechanize;
use strict;
use Carp;
use Data::Dumper;

use Time::Local;
use POSIX qw(mktime);

#use HTML::Parser;
use HTML::PullParser;


my $mech = WWW::Mechanize->new();

###
### BEWARE: points of failure (silent if not on box)
### machine off, network off, cron fails, machine email fails 
### TODO: don't die if cannot get login page or login, try email error instead.
###

##############################
##############################
##############################
# set default config
my $BASEURL0 = "http://libcat.dlrcoco.ie/";
my $BASEURL = #"http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh";
    "http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh";
my $BORROWER="D2000000111111";
my $PIN=7777;
my $MAILTO="me\@somewhere.org, you\@somewhere.org";
my $MAILPROG="mail -r me\@somewhere.org"; # my qmail is configured not-so-goodly :-7

# our pc doesn't get switched on every day.
my $RENEW_DAYS=3; # no days before book is due to renew it
my $ANNOY_DAYS=3; # annoy before due

my $verbose=0;
my $send_email_regardless=0;

##############################
##############################
##############################
# arg parse and usage
my $usage = <<END;
usage: $0 [-v] [-m <email_prog>] [-r <renew_days>] [-a <annoy_days>] <borrower_number> <pin> <email>
e.g. $0 -m "mail -r me\@somehost.org" D2000000111111 7777 "me\@somehost.org"
  -v         verbose print
  -M       send email regardless (every day - annoying!)
END

if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}

if ($ARGV[0]) {
while ($ARGV[0] =~ "^-") {

    if ($ARGV[0] =~ "-m") {
        $MAILPROG = shift(@ARGV);
        $MAILPROG = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-v") {
        $verbose = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-M") {
        $send_email_regardless = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-a") {
        $ANNOY_DAYS = shift(@ARGV);
        $ANNOY_DAYS = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-r") {
        $RENEW_DAYS = shift(@ARGV);
        $RENEW_DAYS = shift(@ARGV);
    }

}}

if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}

$BORROWER = shift(@ARGV);
$PIN = shift(@ARGV);
$MAILTO = shift(@ARGV);

#die "$0 test -m \"$MAILPROG\" -r $RENEW_DAYS -a $ANNOY_DAYS $BORROWER $PIN $MAILTO $usage";


##############################
##############################
##############################
# setup
my $LOG="";
my $STATUS="";
my $NEWSTATUS="";
my $ACTION;
my $MSG;

# we use $MSG as last msg logged sometimes
sub logmessage {
    $MSG = shift;
    $LOG .= $MSG;
    print $MSG;
}


##############################
##############################
##############################
# 1. get front page, fllow borrower info link wih session t login page, 
#    fill in login/pin, submit login

$ACTION = "get login page";
my $url_loans = $BASEURL0;
$mech->get( $url_loans );
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
die "couldn't even " . $ACTION . "\n" if !$mech->success();

#	<li> <a title="Link to Borrower Information" href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175" target="_top">Borrower Information</a></li>
$ACTION="Find Borrower Information link";
my $bi_link=$mech->find_link( text_regex => qr/Borrower Information/i );
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
die "couldn't even " . $ACTION . "\n" if (!$mech->success() || !$bi_link);

$ACTION="Follow Borrower Info link: " . $bi_link->url();
$mech->get($bi_link->url());
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
die "couldn't even " . $ACTION . "\n" if (!$mech->success());

## first time not logged in, returns login page.
# <FORM METHOD=POST onsubmit="return borrower_form_Validator(this)" name="borrower_form">
# Please enter your borrower number 
# <INPUT NAME=borrpara1 TYPE=text SIZE=14 MAXLENGTH=14>
# and PIN</B><INPUT NAME=borrpara2 TYPE=PASSWORD SIZE=4 MAXLENGTH=4></P>
# <INPUT TYPE=SUBMIT VALUE="Search">&nbsp;&nbsp

goto SkipLogin if ($mech->title() eq "Borrower Loans and Renewals"); 

# login
$ACTION="submit login details";

logmessage("action $ACTION");

$mech->submit_form(form_name => 'borr_entry',
		   fields => { borrpara1 => $BORROWER, 
			       borrpara2 => $PIN });
		   #button => 'Login');

logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
die "couldn't " . $ACTION . "\n" if !$mech->success();

##############################
##############################
##############################
# 2. next is personal info page name, etc...
# goto "Loans"

#<ul>
#<li><a title="Link to Catalogue Homepage " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_viewpoint.sh?session_no=10175" target="_top">Catalogue Homepage</a></li>
#<li><a title="Link to Your Details " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=BORROWER&amp;enqpara1=details" target="_top" class="subnav">Your Details</a></li>
#<li><a title="Link to Your Account " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=BORROWER&amp;enqpara1=account" target="_top" class="subnav">Your Account </a></li>
#
#<li><a title="Link to Your Loans " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=LOANS&amp;enqpara1=loans"target="_top" class="subnav">Your Loans</a></li>
#<li><a title="Link to Your Loans History " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=LOAN&amp;enqpara1=history" target="_top" class="subnav">Your Loans History</a></li>
#<li><a title="Link to Your Reservations " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=BORROWER&amp;enqpara1=reservations" target="_top" class="subnav">Your Reservations</a></li>
#<li><a title="Link to Your Comments " href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_comments.sh?session_no=10175&amp;time=&amp;enqtype=BORROWER&amp;enqpara1=view-comments&amp;from=BORROWER" target="_top" class="subnav">Your Comments</a></li>

#<a title="Link to loans" href="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh?session_no=10175&amp;time=&amp;enqtype=LOANS&amp;enqpara1=loans">
#<span class="bold">Loans</span>
#</a>


SkipLogin:

$ACTION="Find and Follow loans link";
$mech->follow_link( text_regex => qr/Loans/i );
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
die "couldn't " . $ACTION . "\n" if (!$mech->success() || !$bi_link);



##############################
##############################
##############################
# 3. Check book status
#     send annoy email if books are due soon (2days) or if books are OVERDUE :-( 
#     RENEW each book if it is on? the renew date!!! :)
#     send email if action was taken (renew - reporting status) or can't renew
  

##############################
##############################
##############################
# some date/timestamp preparation
my(@date) = (localtime)[3,4,5];
$date[2]+=1900; $date[1]+=1;
my $today = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
$date[2]%=100;
my $today2 = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
print $today . " " . $today2 . "\n";

my $nowts = time();


my ($count_books, $count_renew, $count_renew_fail, $count_overdue, $count_coming_up) = (0,0,0,0,0);

# save where we are in case of failure
#$mech->_push_page_stack();
#    $LOG.=Dumper($mech->content());
# restore where we were
#$mech->_pop_page_stack();


my $min_days = 1000; # goes negative
my $max_days = 0;

##############################
##############################
##############################
# globals in: $mech, $LOG, $MSG, system stuff
# globals out: $count_xxx $min_days $max_days, status for each book in $STATUS 

=head1 each book listed in table (in renew form)

<form method="post" action="http://libcat.dlrcoco.ie/cgi-bin/vps2.5_borrower.sh" name="bulk_renew" id="bulk_renew">
<input type="hidden" name="session_no" value="10175">
<input type="hidden" name="enqtype" value="BORROWER">
<input type="hidden" name="enqpara1" value="bulk-renewals">
<input type="HIDDEN" name="borrower" value="D2000000204552">
<input type="HIDDEN" name="borrower2" value="2323">
<input type="HIDDEN" name="family" value="">

<table width='100%' border='0' cellspacing='5' cellpadding='0'>

*chomp*

<tr>
<td width="10%" valign="top" align="left">23/03/07                 </td>
<td width="40%" valign="top" align="left">Horrid Henry and the Secret Club <span class="bold">by</span> Simon Francesca</td>
<td width="20%" valign="top"> </td>
<td width="20%" valign="top" align="right">0.00</td>
<td width="10%" valign="top" align="center"><input type='CHECKBOX' name='loan_list0' value='18588129259051' checked='checked'></td>
</tr>

*chomp*

<td colspan='5' align='center'>You are able to renew ALL the items you have on loan.</td>

<td align='center'><input type='submit' VALUE='Renew'></td>

=cut

sub processbooks {
    my $do_renew = shift;

## find all of these
## <input type='CHECKBOX' name='loan_list0' value='18588129259051' checked='checked'>

    my $renew_form = $mech->form_name( "bulk_renew" );

    my $html = $mech->content();

    ##my $p = new HTML::TreeExtract;
    #my $p = HTML::Parser->new();
    #$p->parse($html);
    #$p->eof;

    #my @FORM_TAGS = qw(form input textarea button select option);
    my $p = HTML::PullParser->new(doc => \$html,
				  start => 'event, tagname, @attr',
				  end   => 'event, tagname',
				  text  => '@{text}',
    #			      start => 'tag, attr',
    #	  	              end   => 'tag',
    #			      report_tags => \@FORM_TAGS,
				  ignore_elements => [qw(script style)],
				  ) || die "Can't HTML::PullParser: $!";

    # 1. go to bulk_renew form
    # 2. go to each <tr> (1st/last <tr> are informational
    # 3. get book date, name, ?, fine, checkbox

    my $book_count = 0;
    my $tr_count = 0;
    my @books; # array of hash

    my $book_detail_count = 0;
    my $td_count = 0;

    while (my $t = $p->get_token) {
	#...do something with $token
	#print "token: " . Dumper($t);  

	# next unless ref $t; # skip text
	if (ref $t) {
	    my %ht = @$t;
	    #print "tag: " . $t->[1] . "\n";

	    if ($t->[1] eq "form") {
		print "form name: " . %ht->{'name'} . "\n";

		if (%ht->{'name'} eq "bulk_renew") {
		    # 1. got bulk_renew form
		    logmessage( "parse bulk_renew form");

		    while ($t = $p->get_token) {
			if (ref $t) {
			    my %ht = @$t;
			    #print "tag: " . $t->[1] . "\n";
			    if ($t->[1] eq "tr" && $t->[0] eq "start") {
				# 2. got <tr> (1st/last <tr> are informational
				$tr_count++;
				$td_count=0;
				#logmessage( "got tr" . $tr_count . "\n");
			    } elsif ($t->[1] eq "td" && $t->[0] eq "start") {
				# 3. get book date, name, ?, fine, checkbox
				$td_count++;
			    } elsif ($t->[1] eq "input" && %ht->{'type'} eq "CHECKBOX") { # checkbox
				#print "type: " . %ht->{'type'} . "\n";
				#print "name: " . %ht->{'name'} . "\n";

				# 3. get book date, name, ?, fine, checkbox
				#print "input: " . Dumper($t);  
				$books[$tr_count]->{'isabook'} = 1;
				$books[$tr_count]->{'checkbox_name'} = %ht->{'name'};
				$book_count++;
				$count_books++;

			    }
			} else {
			    # 3. get book date, name, ?, fine, checkbox
			    if ($tr_count > 0 && $td_count < 20) {
				# store text as book detail
				$books[$tr_count]->{$td_count} .= $t;
				#print "books[$tr_count]->{$td_count} = $t\n";
				$book_detail_count++;
			    }
			}

		    }
		}
	    }

	} #else {
	#    #print "text: " . $t . "\n";
	#}

    }


    # now we have a nice @books array hash
    # entries are all contents of <tr>
    # not all entries are books

    #print Dumper(@books); # array of hash
    logmessage ( "Found $book_count books.\n");
    
    my $found_book = 0;
    my $renew_all_books = 0;
    foreach my $book (@books) {
	if ($book->{'isabook'}) {

	    $found_book++;
	    logmessage("book: " . $book->{'checkbox_name'}
		       . " fine: " . $book->{'4'}
	               . " due: " . $book->{'1'}
		       . " title: " . $book->{'2'} . "\n");

# e.g.
# book: loan_list5 fine: 0.00
# due: 23/03/07                 
# title: Swallows and amazons by Ransome Arthur

	    my @bookdate = ($book->{'1'} =~ m/(\d\d)\/(\d\d)\/(\d\d)/);

	    my(@bookd) = localtime();
	    @bookd[0..2] = (0,0,0);
	    @bookd[3..5] = ($bookdate[0], $bookdate[1]-1, $bookdate[2]+100);
	    my $bookts = &mktime(@bookd);
	    my $days = int(($bookts - $nowts) / (60*60*24));

	    $min_days = $days if ($days < $min_days);
	    $max_days = $days if ($days > $max_days);
	    
	    my $bookstatus = "";
	    # check for coming up to renew
	    if ($days < 0 || $days <= $RENEW_DAYS) {
		# OVERDUE or within REVIEW period
		if (!$do_renew) {
		    $bookstatus = "    NEEDS RENEW. " . $days . " days.";
		} else {

		    # TODO the renew is easier or harder?
		    # always do all at once? => easier, one form submit
		    logmessage("marking all books for renew");
		    $renew_all_books = 1;
		}
	    }

	    if ($days <= $ANNOY_DAYS) {
		
		if ($days <0) {
		    # OVERDUE!
		    # bugfix: don't override RENEW message
		    $bookstatus .= "    OVERDUE! " . -$days . " days.";
		    $count_overdue++;
		} else {
		    $bookstatus = "    NOTIFY coming due soon. " . $days . " days.";
		    $count_coming_up++;
		}
	    }

	    logmessage("bookstatus: " . $bookstatus . "\n");
	    logmessage("days: " . $days . "\n");
	    print "bookstatus: " . $bookstatus . "\n";
	    print "days: " . $days . "\n";
	    $STATUS .= "bookstatus: " . $bookstatus . "\n";
	    $STATUS .= "days: " . $days . "\n";

	} else {
	    if ($found_book > 0) {
		logmessage("message: " . $book->{'1'} );
		# informational, e.g. 'You are able to renew ALL the items you have on loan.'
		# just the 1th element after go through books
	    }
	}

    }

    return $renew_all_books;

}



##############################
##############################
##############################
# check books status (date due)  and renew if needed
my $do_renew = processbooks(1); 
my $renewhtml = "";

my ($old_count_books, $old_count_coming_up, $old_count_renew,
    $old_count_overdue, $old_min_days, $old_STATUS);

if ($do_renew) {
    $ACTION="renew all books (because one is close to due)";
    $mech->submit_form(form_name => 'bulk_renew');
    $STATUS .= "couldn't " . $ACTION . "\n" if (!$mech->success());
    logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
    $renewhtml = $mech->content();
    logmessage("Renew results follow: " . $renewhtml);

    # NOW get status again if we have changed it by renewing something
    $old_count_books = $count_books;
    $old_count_coming_up = $count_coming_up;
    $old_count_renew = $count_renew;
    $old_count_overdue = $count_overdue;
    $old_min_days = $min_days;
    $old_STATUS = $STATUS;

    $ACTION="Find and Follow loans link";
    $mech->follow_link( text_regex => qr/Loans/i );

    #$mech->reload();
    if (!$mech->success()){
        logmessage( "ERROR: couldn't " . $ACTION . "\n"); 
    } else {
        logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");
        # note that $count_renew; and $count_renew_fail are not zeroed
        ($count_books, $count_overdue, $count_coming_up) = (0,0,0);
        my $min_days = 1000; # goes negative
        my $max_days = 0;
        processbooks(0); # process books and retrieve status only
    }

}
 


##############################
##############################
##############################
# send email
if ($send_email_regardless || $count_coming_up>0 || $count_overdue>0 || $count_renew>0) {
    my $SUBJECT="";
    $SUBJECT .= $count_overdue . " books OVERDUE. " if ($count_overdue>0);
    $SUBJECT .= $count_renew_fail . " renew FAILed. " if ($count_renew_fail>0);
    $SUBJECT .= $count_renew . " books renewed. " if ($count_renew>0);
    $SUBJECT .= $count_coming_up . " books coming due. " if ($count_coming_up>0);
    $SUBJECT = "library-check.pl -M option on. send email regardless." if ($SUBJECT eq "" && $send_email_regardless);
    $SUBJECT = "JAmes's LOGIC is FLAWed" if ($SUBJECT eq "");

    my $HELLO = "Hello,\nThis is your Automated Library Check Tool speaking.\n".
                               "I have detected or done something.\n".
                               "Books out: $count_books\n";

    if ($min_days<0) {
        $HELLO .= "Something is overdue by " . -$min_days . " days. tut. tut.\n";
    } else {
        $HELLO .= "Closest days due: $min_days\n";
    }
 
    if ($MAILTO && ($MAILTO |= "")) {
        open(MAIL, "|$MAILPROG '$MAILTO' -s \"library check $SUBJECT\"");
        print MAIL ("$HELLO\n$STATUS\n");
        #print MAIL ("\nCHARGES: $CHARGES\n") if ($CHARGES);
        print MAIL ("\nBEFORE renew:\n$old_STATUS\n") if ($count_renew>0);
        print MAIL ("\n\n$LOG\n");
        close(MAIL);
    }
}
