#!/usr/bin/perl -w

=head1 NAME

viewTimesheet.pl - reads timesheet file and outputs contents with date & time

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 JUNK

## greasemonkey script?
## perl?
## shell?
wget http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000204552&borrower2=2323
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
  document.borrower_form.borrpara1.focus();
function borrower_form_Validator(theForm) {
  if (theForm.borrpara1.value.length == 0) {
    theForm.borrpara1.focus();
  if (theForm.borrpara2.value.length == 0) {
    theForm.borrpara2.focus();

less /usr/lib/perl5/site_perl/5.8.3/Finance/Bank/IE/BankOfIreland.pm

=cut

use WWW::Mechanize;
#use HTML::TokeParser;
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
# 1. get login page, fill in login/pin, submit login
my $BASEURL = "http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh";
my $BORROWER="D2000000204552";
my $PIN=2323;
my $MAILTO="jamesc\@dspsrv.com";
my $MAILPROG="mail -r jamesc\@dspsrv.com";
# renew 2 - our pc doesn't get switched on every day.
my $RENEW_DAYS=3; # no days before book is due to renew it
my $ANNOY_DAYS=3; # annoy befoire due


# list of author/title/date due back
##http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000204552&borrower2=2323
my $url_loans = $BASEURL . "?enqtype=BORROWER&enqpara1=loans&language=&borrower=" . $BORROWER . "&borrower2=" . $PIN;
my $LOG="";
my $STATUS="";
my $NEWSTATUS="";
my $ACTION = "get login page";
my $MSG;

# we use $MSG as last msg logged sometimes
sub logmessage {
    $MSG = shift;
    $LOG .= $MSG;
    print $MSG;
}

$mech->get( $url_loans );
die "couldn't even " . $ACTION . "\n" if !$mech->success();
#print "what's a uri?" . $mech->uri() . "\n";
#print "status: " . $mech->status() . "\n";
#print "is_html: " . $mech->is_html() . "\n";
#print "title: " . $mech->title() . "\n";
#print "forms:" . Dumper($mech->forms()) . "\n";
#print "links:" . $mech->links() . "\n";
#print "links:" . Dumper($mech->links()) . "\n";

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

#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=1&borrower=D2000000204552&borrower2=2323><IMG SRC="/catalogue-new-v5/../catalogue/buttons/loans-button2.gif" BORDER=0 HSPACE=3 ALT="Loans"></A>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=charges&language=1&borrower=D2000000204552&borrower2=2323><IMG SRC="/catalogue-new-v5/../catalogue/buttons/fines-button2.gif" BORDER=0 HSPACE=3 ALT="Charges"></A>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=reservations&language=1&borrower=D2000000204552&borrower2=2323><IMG SRC="/catalogue-new-v5/../catalogue/buttons/reservations-button2.gif" BORDER=0 HSPACE=3 ALT="Reservations"></A>

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
  
####
# foreach book


#<PRE>
#Author                 Title                                       Date due back
#--------------------------------------------------------------------------------<BR>
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Powell+Micelle&title=Mosaics&item=04311116779004&rcn=0431111677&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=2&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=08/05/06&renewdate=25/06/06&i_category=15&homebranch=44&awaybranch=44>Powell Micelle         Mosaics                                       17/07/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Nesbit,+E.&title=Five+Children+and+It&item=05633606584003&rcn=0563360658&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=2&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=08/05/06&renewdate=25/06/06&i_category=16&homebranch=44&awaybranch=44>Nesbit, E.             Five Children and It                          17/07/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Birkinshaw+Marie&title=Bounce&item=07214818179001&rcn=0721481817&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=3&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=12/04/06&renewdate=25/06/06&i_category=16&homebranch=44&awaybranch=44>Birkinshaw Marie       Bounce                                        17/07/06
#
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44>Rowling J. K.          Harry Potter and the half-blood prince        19/06/06
#</A><A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=1&author=Cabot+Meg&title=Princess+Diaries+Mia+goes+fourth&item=14050341229001&rcn=1405034122&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=3&reservations=0&itemreserved=0&stopfines=0&freeissues=0&overdue=-21&duedate=17/07/06&issuedate=12/04/06&renewdate=25/06/06&i_category=21&homebranch=44&awaybranch=44>Cabot Meg              Princess Diaries Mia goes fourth              17/07/06
#</A>
#</PRE>


# use links/forms/content to verify we got the page content okay and that what we expect to be there is there.
#my $content = $mech->content( format => "text" );

#my $link=$mech->find_link( text => "download" );
#my $link=$mech->find_link( text_regex => qr/download/i );
#my $link=$mech->find_link( url => "download" );


#my $link=$mech->find_link( url_regex => qr/author=/i );
#print Dumper($link);
#$link=$mech->find_link( url_regex => qr/&author=/i );
#print Dumper($link);
#$link=$mech->find_link( url_regex => qr/&author=/i, n => 1 );
#print Dumper($link);
#$link=$mech->find_link( url_regex => qr/&author=/i, n => 2 );
#print Dumper($link);


#for(my $i=0;$i<50;$i++){
#    my $link=$mech->find_link( url_regex => qr/&author=/i, n => $i );
#    print Dumper($link);
#}


# a link:
#$VAR4 = bless( [
#                 'dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44',
#                 'Rowling J. K. Harry Potter and the half-blood prince 19/06/06',
#                 undef,
#                 'a',
#                 $VAR1->[4],
#                 {
#                   'href' => 'dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renewals&language=&author=Rowling+J.+K.&title=Harry+Potter+and+the+half-blood+prince&item=07475810889014&rcn=0747581088&borrower=D2000000204552&borrower2=2323&renewable=0&category=&renewcount=1&reservations=1&itemreserved=0&stopfines=0&freeissues=0&overdue=7&duedate=19/06/06&issuedate=08/05/06&renewdate=26/05/06&i_category=16&homebranch=44&awaybranch=44'
#                 }
#               ], 'WWW::Mechanize::Link' );


my(@date) = (localtime)[3,4,5];
$date[2]+=1900; $date[1]+=1;
my $today = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
$date[2]%=100;
my $today2 = sprintf("%04d.%02d.%02d", $date[2], $date[1], $date[0] );
print $today . " " . $today2 . "\n";


my $nowts = time();


my ($count_books, $count_renew, $count_renew_fail, $count_overdue, $count_coming_up) = (0,0,0,0,0);

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
#<A HREF="dun_laog-cat.sh?enqtype=BORROWER&enqpara1=renew-title&language=&renewdate=25%2F06%2F06&borrower=D2000000204552&borrower2=2323&hire_flag=0&fine_flag=0&item=04311116779004&issuedate=08%2F05%2F06&duedate=17%2F07%2F06&title=Mosaics&hire_charge=0.00&fine=&new_date=17%2F07%2F06&renewcount=2&borrower_status=&borrower_account=2.20"><IMG SRC="/catalogue-new-v5/../catalogue/buttons/renew-button2.gif" BORDER=0 ALT="Yes, renew"></a>
#<A HREF="dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000204552&borrower2=2323"><IMG SRC="/catalogue-new-v5/../catalogue/buttons/cancel-button2.gif" BORDER=0 ALT="No, don't renew"></a>

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
            $bookstatus = "    OVERDUE! " . -$days . " days.";
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




# check books status (date due)  and renew if needed
processbooks(1); 




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
 

# TODO: get fines etc ..
#<A HREF=dun_laog-cat.sh?enqtype=BORROWER&enqpara1=charges&language=1&borrower=D2000000204552&borrower2=2323><IMG SRC="/catalogue-new-v5/../catalogue/buttons/fines-button2.gif" BORDER=0 HSPACE=3 ALT="Charges"></A>
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





if ($count_coming_up>0 || $count_overdue>0 || $count_renew>0) {
    my $SUBJECT="";
    $SUBJECT .= $count_overdue . " books OVERDUE. " if ($count_overdue>0);
    $SUBJECT .= $count_renew_fail . " renew FAILed. " if ($count_renew_fail>0);
    $SUBJECT .= $count_renew . " books renewed. " if ($count_renew>0);
    $SUBJECT .= $count_coming_up . " books coming due. " if ($count_coming_up>0);
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
