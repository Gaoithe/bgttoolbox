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
use HTML::TokeParser;
use strict;
use Carp;
use Data::Dumper;

my $mech = WWW::Mechanize->new();

##############################
##############################
##############################
# 1. get login page, fill in login/pin, submit login
my $BASEURL = "http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh";
my $BORROWER="D2000000204552";
my $PIN=2323;

my $ACTION = "get login page";
# list of author/title/date due back
##http://libcat.dlrcoco.ie/cgi-bin/dun_laog-cat.sh?enqtype=BORROWER&enqpara1=loans&language=&borrower=D2000000204552&borrower2=2323
my $url_loans = $BASEURL . "?enqtype=BORROWER&enqpara1=loans&language=&borrower=" . $BORROWER . "&borrower2=" . $PIN;

$mech->get( $url_loans );
die "couldn't even " . $ACTION . "\n" if !$mech->success();
print "what's a uri?" . $mech->uri() . "\n";
print "status: " . $mech->status() . "\n";
print "is_html: " . $mech->is_html() . "\n";
print "title: " . $mech->title() . "\n";
#print "forms:" . Dumper($mech->forms()) . "\n";
#print "links:" . $mech->links() . "\n";
#print "links:" . Dumper($mech->links()) . "\n";


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
print "status: " . $mech->status() . "\n";
print "title: " . $mech->title() . "\n";

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
print "status: " . $mech->status() . "\n";
print "title: " . $mech->title() . "\n";


SkipLogin:

# renew 2 - our pc doesn't get switched on every day.
my $RENEW_DAYS=2; # no days before book is due to renew it
my  $ANNOY_DAYS=2; # annoy befoire due

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

my @links = $mech->find_all_links(url_regex => qr/&author=/i);
foreach my $link (@links) {
    #print Dumper($link);
    print $link->[1]."\n";
}

#    if ( my $l = $agent->find_link( text => $account )) {
#        $agent->follow_link( text => $account )
#          or croak( "Couldn't follow link to account number $account" );
#    } else {
#        croak "Couldn't find a link for $account";
#    }
