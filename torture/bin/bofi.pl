#!/usr/bin/perl -w
#
# demo of Finance::Bank::IE::BankOfIreland interface
use lib $ENV{HOME} . "/src/perl";
use Finance::Bank::IE::BankOfIreland;

# fill out as appropriate
my %config = (
              "user" => "xxxxxx",
              "pin" => "xxxxxx",
              "contact" => "xxxx",
              "dob" => "dd/mm/yyyy",
              "croak" => 1
             );

my @accounts = Finance::Bank::IE::BankOfIreland->check_balance( \%config );

use Data::Dumper;

# display account balance
foreach ( @accounts ) {
    printf "%8s : %s %8.2f\n",
	  $_->{account_no}, $_->{currency}, $_->{balance};

    print Dumper($_);
}

# display recent activity
foreach ( @accounts ) {
use Data::Dumper;
print Dumper($_);
    my @activity = Finance::Bank::IE::BankOfIreland->account_details( $_->{account_no} );
    for my $line ( @activity ) {
        my @cols = @{$line};
        # cols are date, comment, dr, cr, balance
        # last three may contain blanks
        # date contains non-breaking spaces (blech)
        for my $col ( 0..$#cols) {
            printf( "[%s]", $cols[$col]);
        }
        print "\n";
    }
}

my @activity = Finance::Bank::IE::BankOfIreland->account_details( "####9151" );
    for my $line ( @activity ) {
        my @cols = @{$line};
        # cols are date, comment, dr, cr, balance
        # last three may contain blanks
        # date contains non-breaking spaces (blech)
        for my $col ( 0..$#cols) {
            printf( "[%s]", $cols[$col]);
        }
        print "\n";
    }

##
#htt:ps://www.365online.com/servlet/Dispatcher/selacc.htm?row=001
#https://www.365online.com/servlet/Dispatcher/selacc.htm?row=001
#https://www.365online.com/servlet/Dispatcher/cc_selacc.htm?row=004
#https://www.365online.com/servlet/Dispatcher/cc_error.htm?row=003
#https://www.365online.com/servlet/Dispatcher/cc_error.htm?row=002
