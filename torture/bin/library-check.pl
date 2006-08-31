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

=cut

use WWW::Mechanize;
use strict;
use Carp;
use Data::Dumper;

use Time::Local;
use POSIX qw(mktime);

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
my $BASEURL = "http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh";
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
# 1. get login page, fill in login/pin, submit login

#login, then list of author/title/date due back (or login skipped if logged in already)
##http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000111111&borrower2=7777
$ACTION = "get login page";
my $url_loans = $BASEURL . "?enqtype=BORROWER&enqpara1=loans&language=&borrower=" . $BORROWER . "&borrower2=" . $PIN;

$mech->get( $url_loans );
die "couldn't even " . $ACTION . "\n" if !$mech->success();

logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");

## first time not logged in, returns login page.
# <FORM METHOD=POST onsubmit="return borrower_form_Validator(this)" name="borrower_form">
# Please enter your borrower number 
# <INPUT NAME=borrpara1 TYPE=text SIZE=14 MAXLENGTH=14>
# and PIN</B><INPUT NAME=borrpara2 TYPE=PASSWORD SIZE=4 MAXLENGTH=4></P>
# <INPUT TYPE=SUBMIT VALUE="Search">&nbsp;&nbsp

goto SkipLogin if ($mech->title() eq "Borrower Loans and Renewals"); 

# login
$ACTION="submit login details";
$mech->submit_form(form_name => 'borrower_form',
                                           fields => { borrpara1 => $BORROWER, 
                                                              borrpara2 => $PIN },
                                           button => 'Search');

die "couldn't " . $ACTION . "\n" if !$mech->success();
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");

##############################
##############################
##############################
# 2. next is personal info page name, etc...
# goto "Loans"

#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=1&borrower=D2000000111111&borrower2=7777><IMG SRC="/catalogue-new-v5/../catalogue/buttons/loans-button2.gif" BORDER=0 HSPACE=3 ALT="Loans"></A>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=charges&language=1&borrower=D2000000111111&borrower2=7777><IMG SRC="/catalogue-new-v5/../catalogue/buttons/fines-button2.gif" BORDER=0 HSPACE=3 ALT="Charges"></A>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=reservations&language=1&borrower=D2000000111111&borrower2=7777><IMG SRC="/catalogue-new-v5/../catalogue/buttons/reservations-button2.gif" BORDER=0 HSPACE=3 ALT="Reservations"></A>

#<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=DEFAULT&enqpara1=ANY&language=1"><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/home-button2.gif" HSPACE=3 BORDER=0 ALT="Home"></A>
#<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=AUTHOR&language=1"><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/author-button2.gif" HSPACE=3 BORDER=0 ALT="Author Search"></A>
#<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=TITLE&language=1"><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/title-button2.gif" HSPACE=3 BORDER=0 ALT="Title Search"></A>
#<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=KEYWORD&language=1"><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/keyword-button2.gif" HSPACE=3 BORDER=0 ALT="Keyword Search"></A>
#<A HREF="/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&language=1"><IMG SRC="/catalogue-new-v5/../catalogue/../catalogue/buttons/borrower-button2.gif" HSPACE=3 BORDER=0 ALT="Borrower Information"></A>
$ACTION="go to Loans page (list of books)";
$mech->get( $url_loans );

die "couldn't " . $ACTION . "\n" if !$mech->success();
logmessage( $ACTION .  "status: " . $mech->status() . ", title: " . $mech->title() . "\n");

SkipLogin:


##############################
##############################
##############################
# 3. Check book status
#     send annoy email if books are due soon (2days) or if books are OVERDUE :-( 
#     RENEW each book if it is on? the renew date!!! :)
#     send email if action was taken (renew - reporting status) or can't renew
  

#<PRE>
#Author                 Title                                       Date due back
#--------------------------------------------------------------------------------<BR>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Powell+Micelle&title=Mosaics&item=04311116779004&rcn=0431111677&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=2&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=08/05/06&renewdate=25/06/06&i_category=15&homebranch=44&awaybranch=44>Powell Micelle         Mosaics                                       17/07/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Nesbit,+E.&title=Five+Children+and+It&item=05633606584003&rcn=0563360658&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=2&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=08/05/06&renewdate=25/06/06&i_category=16&homebranch=44&awaybranch=44>Nesbit, E.             Five Children and It                          17/07/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Birkinshaw+Marie&title=Bounce&item=07214818179001&rcn=0721481817&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=3&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=12/04/06&renewdate=25/06/06&i_category=16&homebranch=44&awaybranch=44>Birkinshaw Marie       Bounce                                        17/07/06
#
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44>Rowling J. K.          Harry Potter and the half-blood prince        19/06/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Cabot+Meg&title=Princess+Diaries+Mia+goes+fourth&item=14050341229001&rcn=1405034122&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=3&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=12/04/06&renewdate=25/06/06&i_category=21&homebranch=44&awaybranch=44>Cabot Meg              Princess Diaries Mia goes fourth              17/07/06
#</A>
#</PRE>


# use links/forms/content to verify we got the page content okay and that what we expect to be there is there.
# a link:
#$VAR4 = bless( [
#                 'dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44',
#                 'Rowling J. K. Harry Potter and the half-blood prince 19/06/06',
#                 undef,
#                 'a',
#                 $VAR1->[4],
#                 {
#                   'href' => 'dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000111111&borrower2=7777&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44'
#                 }
#               ], 'WWW::Mechanize::Link' );


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

##############################
##############################
##############################
# globals out:             $count_renew_fail++;     or $count_renew++;
# return bookstatus
sub renewbook {
    my $link = shift;
    my $days = shift;
    #global $count_renew, $count_renew_fail;
    #global $mech;
    #global $STATUS;

        # save where we are in case of failure
        $mech->_push_page_stack();

        # renew the BOOK!
        my $bookstatus = "    ATTEMPT RENEW. " . $days . " days.";

        $ACTION="go to Book page (to renew)";
        $mech->get($link->url());
        if (!$mech->success()){
            logmessage( "ERROR: couldn't " . $ACTION . "\n") ;
            $count_renew_fail++;
        } else {
            logmessage( $ACTION . " status: " . $mech->status() . ", title: " . $mech->title() . "\n");

            # Click renew button
#<B>If you want to renew this item click on the 'Renew' button below. If not, click 'Cancel' or select one of the links at the bottom of the page.</B>
#<A HREF="dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renew-title&language=&renewdate=25%2F06%2F06&borrower=D2000000111111&borrower2=7777&hire_flag=0&fine_flag=0&item=04311116779004&issuedate=08%2F05%2F06&duedate=17%2F07%2F06&title=Mosaics&hire_charge=0.00&fine=&new_date=17%2F07%2F06&renewcount=2&borrower_status=&borrower_account=2.20"><IMG SRC="/catalogue-new-v5/../catalogue/buttons/renew-button2.gif" BORDER=0 ALT="Yes, renew"></a>
#<A HREF="dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000111111&borrower2=7777"><IMG SRC="/catalogue-new-v5/../catalogue/buttons/cancel-button2.gif" BORDER=0 ALT="No, don't renew"></a>

            $ACTION="Find renew link";
            my $renew_link=$mech->find_link( url_regex => qr/renew-title/i );
            if (!$mech->success() || !$renew_link){
                logmessage( "ERROR: couldn't " . $ACTION . "\n"); 
                $count_renew_fail++;
#e.g.
#<B>Sorry, this item cannot be renewed as it has been reserved by other library members.</B>
#<BR><BR>Please select a link to the approproate screen.

# $mech->content() call needs HTML::TreeBuilder
                my $renew_fail_content = $mech->content( format => "text" );
                $renew_fail_content =~ s/Please select.*//m;

            } else {
                $ACTION="Click renew link";
                $mech->get($renew_link->url());

                if (!$mech->success()){
                    logmessage( "ERROR: couldn't " . $ACTION . "\n"); 
                    $count_renew_fail++;
                } else {
                    logmessage( $ACTION . " status: " . $mech->status() . ", title: " . $mech->title() . "\n");  

                    ## 
                    ## TODO one last check to see if renew was okay?
                    ## This part not tested.
                    $LOG.=Dumper($mech->content());

                    $count_renew++;

                }

            }
  
        }

        $bookstatus = "    RENEW $MSG.";

        # restore where we were
        $mech->_pop_page_stack();
    return $bookstatus;
}


my $min_days = 1000; # goes negative
my $max_days = 0;

##############################
##############################
##############################
# globals in: $mech, $LOG, $MSG, system stuff
# globals out: $count_xxx $min_days $max_days, status for each book in $STATUS 
sub processbooks {
    my $do_renew = shift;

my @links = $mech->find_all_links(url_regex => qr/&author=/i);
foreach my $link (@links) {
    #print Dumper($link);
    #print $link->[1]."\n";
    my $book = $link->[1];
    $count_books++;
    my @bookdate = ($book =~ m/.* (\d\d)\/(\d\d)\/(\d\d)$/);
    #print Dumper(@bookdate);

    my(@bookd) = localtime();
    @bookd[0..2] = (0,0,0);
    @bookd[3..5] = ($bookdate[0], $bookdate[1]-1, $bookdate[2]+100);
    my $bookts = &mktime(@bookd);
    my $days = int(($bookts - $nowts) / (60*60*24));
    #print "bookts: " . $bookts . "nowts: " . $nowts . "\n";
    #print "days: " . $days . "\n";

    $min_days = $days if ($days < $min_days);
    $max_days = $days if ($days > $max_days);

    my $bookstatus = "";
    # check for coming up to renew
    if ($days < 0 || $days <= $RENEW_DAYS) {
        # OVERDUE or within REVIEW period
        if (!$do_renew) {
            $bookstatus = "    NEEDS RENEW. " . $days . " days.";
        } else {
            $bookstatus = renewbook($link,$days);
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

    print $book."\n";
    $STATUS .= $book;
    print $bookstatus . "\n";
    $STATUS .= $bookstatus . "\n";

}
}




##############################
##############################
##############################
# check books status (date due)  and renew if needed
processbooks(1); 




##############################
##############################
##############################
# NOW get status again if we have changed it by renewing something
my $old_count_books = $count_books;
my $old_count_coming_up = $count_coming_up;
my $old_count_renew = $count_renew;
my $old_count_overdue = $count_overdue;
my $old_min_days = $min_days;
my $old_STATUS = $STATUS;

if ($count_renew>0) {
    $ACTION="reload  Loans page (to get updated list of books)";
    $mech->reload();
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
# get charges/fines etc ..
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=charges&language=1&borrower=D2000000111111&borrower2=7777><IMG SRC="/catalogue-new-v5/../catalogue/buttons/fines-button2.gif" BORDER=0 HSPACE=3 ALT="Charges"></A>
my $CHARGES="";
$ACTION="find fines/charges page";
my $charges_link=$mech->find_link( url_regex => qr/enqpara1=charges/i );
if (!$mech->success() || !$charges_link){
    logmessage( "ERROR: couldn't " . $ACTION . "\n"); 
} else {
    logmessage( $ACTION . "\n");

    $ACTION="goto fines/charges page";
    $mech->get($charges_link->url());
    if (!$mech->success()){
        logmessage( "ERROR: couldn't " . $ACTION . "\n"); 
    } else {
        logmessage( $ACTION . " status: " . $mech->status() . ", title: " . $mech->title() . "\n");  
        my $charges_content = $mech->content( format => "text" );
        $charges_content =~ s/Click here.*//m;
        $CHARGES = $charges_content;
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
        print MAIL ("\nCHARGES: $CHARGES\n") if ($CHARGES);
        print MAIL ("\nBEFORE renew:\n$old_STATUS\n") if ($count_renew>0);
        print MAIL ("\n\n$LOG\n");
        close(MAIL);
    }
}
