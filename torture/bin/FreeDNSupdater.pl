#!/usr/bin/perl -w

#--------------------------------------------------------------------------
#FreeDNS updater by Charles Puffer V0.1
#This program licensed under the GNU GPL
#send comments at cpuffer@red-belt.org
#
#For a copy of the GPL and more informaion on FreeSoftware
#on the web go to www.fsf.org
#--------------------------------------------------------------------------

use strict;

use LWP::Simple;
use Sys::Syslog; 

my $domain="NA";
my $code="NA";

my $system='NA';
my $dns='NA';

my $verbose=0;
my $deamon=0;

sub setDNSIP {
    my $content= get("http://freedns.afraid.org/dynamic/update.php?" . $code . "=");
    chomp $content;
    syslog('info', "FreeDNS update of domain: $domain");
    syslog('info', "FreeDNS      useing code: $code");
    &output("-The Return------------------------------------------------\n");
    &output("$content\n");
    &output("-----------------------------------------------------------\n");  
    syslog('info', "FreeDNS           return: $content");
}

sub checkDNSIP {
    # this might be better if ifconfig was used with -a and the match for the address
    # made use of the network part of the expected address. (cpuffer)
    $_=`ifconfig ppp0`;
    chomp;
    &output("-From ifconfig ppp0----------------------------------------\n");
    &output("$_\n");
    &output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n");
    if ( m/addr:(\d+\.\d+\.\d+\.\d+)/ ) {   
	$system=$1;
	&output("The system\'s address is $system\n");    
	&output("----------------------------------------------------------\n");

    }
    else {    
	syslog('err', "FreeDNS update could not get ifconfig ppp0 ip");
	$system="NA"
    }
    
    $_=`host red-belt.org`;
    chomp;
    &output("-From host $domain-----------------------------------------\n");
    &output("$_\n");
    &output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n");
    if ( m/has address (\d+\.\d+\.\d+\.\d+)/ ) {
	$dns=$1;
	&output("The DNS address is $dns\n");
	&output("-----------------------------------------------------------\n");
    }
    else {
	syslog('err', "FreeDNS update could not get host $domain ip");
	$dns="NA"
    }
    

    if ( $system ne "NA" && $dns ne "NA" ) {
	if ( $system eq $dns ) {
	    &output("The addresses are the same no DNS service update needed.\n");
	    return "same";
	}
	else {
	    &output("The addresses are not the same update DNS service.\n");
	    return "different";
	}
    } 
    else {
	return 0;
    }
}

sub output {
    my ($line)=@_;
    
    if ($verbose) {
	print $line;
    }
}

sub getargs {
    my $temp=0;

    foreach (@ARGV) {
	$temp++;	
	&output("$temp $_\n");
	if ( m/-h/) {
	    print "FreeDNS DNS updater\n";
	    print "     By Charles Puffer\n";
	    print "     Version 0.1 licenses under the GNU GPL www.fsf.org for copy of license\n";
	    print "Useage:\n";
	    print " FreeDNS -v -d a.domain.you.have.at.freedns.afraid.org ?the_strange_code*=\n";
	    print "";
	    print "Parameters:\n";
	    print "    -v turn on or off verbose\n";
	    print "    -d\#\# deamon mode run once every \#\#  minuets\n";
	    print "            should not less than 10min\n";	
	    print "    -h this help\n";
	    print "";
	    print "*Note:\n";
	    print " The strange code you have to include comes from FreeDNS.\n";
	    print " You get it by going to the Dynamic update page and clicking\n";
	    print " on Direct URL, the strange code will be near the end of the\n";
	    print " URL and will begin with a\'?\' and end with a \'=\['.\n";
	    exit;
	}
	if ( m/-v/) {
	    if ($verbose==0) {
		$verbose=1;
		&output("Verbose mode on\n");
		&output("$temp $_\n");
	    } else {
		&output("Verbose mode off\n");
		$verbose=0;
	    }
	}elsif ( m/-d\s*(\n*)/ ) {
	    $deamon=$1;
	    if ($deamon < 10.0){  #It is bad to change this. You will just risk hitting FreeDNS
		$deamon=10.0;       #hard if you ip does not update.
		&output("Deamon mode on check every $deamon minuts\n");
		$deamon*=60; 
	    }
	}elsif ( ($domain eq "NA") && ($code eq "NA") && ( m/(\S+)/ ) ) { #this could be better defined to avoid input errors
	    $domain=$1;
	    &output("The Domain is $domain\n");
	}elsif ( ($domain ne "NA") && ($code eq "NA") && ( m/\?(\S+)=/ ) ) { #this could be better defined to avoid input errors
	    $code=$1;
	    &output("The code is $code\n");
	}else {
	    &output("There may be a problem with your input arguments\n");
	    exit;

	}
    }
	
    if ( ($domain eq "NA") || ($domain eq "NA") ) {
	die "You must provide a domain and a FreeDNS code";
    }
}

sub FreeDNSupdater {
    &getargs();
    if ( &checkDNSIP() ne "same" ) { 
	&setDNSIP();
    }

    while ($deamon) {
	&output("sleeping\n");
	sleep $deamon;
	if ( &checkDNSIP() ne "same" ) { 
	    &setDNSIP();
	}
    }
}

&FreeDNSupdater();
