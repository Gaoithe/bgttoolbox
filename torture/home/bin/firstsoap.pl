#!/usr/bin/perl -w

#    debug => '+',
#    proxy('http://services.soaplite.com/temper.cgi', proxy => 'http://proxy:8080');
#    proxy => 'http://proxy:8080', proxy => 'http://services.soaplite.com/temper.cgi';
#   proxy => 'http://services.soaplite.com/temper.cgi', proxy => 'http://proxy:8080';
#    proxy => 'http://proxy:8080';
#    proxy => 'http://services.soaplite.com/temper.cgi';



#use SOAP::Lite +trace => 'debug';
#use SOAP::Lite +autodispatch =>
#    uri => 'http://www.soaplite.com/Temperatures';
#print SOAP::Lite
#    proxy('http://services.soaplite.com/temper.cgi', proxy => 'http://proxy:8080/');
#my $temperatures = Temperatures->new(32); # get object
#print $temperatures->as_celsius;          # invoke method


use SOAP::Lite +trace => 'debug';
#use SOAP::Lite +autodispatch;

#my $sudsy = SOAP::Lite
#    -> uri('http://simon.fell.com/calc')
#    -> proxy('http://soap.4s4c.com/ssss4c/soap.asp', proxy => 'http://proxy:8080/')
#  ;

#my $sudsy = SOAP::Lite
#    -> uri( "http://www.soaplite.com/Temperatures" )
##    -> proxy( "http://services.soaplite.com/temper.cgi", proxy => 'http://proxy:8080/', timeout => 5)
#    -> proxy( "http://services.soaplite.com/temper.cgi", timeout => 5)
#    -> f2c(32)
#    -> result
#  ;

my $sudsy = SOAP::Lite
    -> uri('http://www.soaplite.com/Demo')
#    -> proxy('http://services.soaplite.com/hibye.cgi')
#    -> proxy('http://services.soaplite.com/hibye.cgi', proxy => 'http://proxy:8080/', timeout => 5)
    -> proxy('http://services.soaplite.com/hibye.cgi', proxy => ['http', 'http://proxy:8080/'], timeout => 5)
# proxy=>['http', 'http://wwwcache.dl.ac.uk:8080']],
    -> hi()
    -> result;

print "RESULT $sudsy\n";

# hangs?
# 2226  wget http://cookbook.soaplite.com/temper.cgi   NO?
# 2224  wget http://cookbook.soaplite.com/ yes?
#[jamesc@betty] ~/bin/soap/$ wget http://services.soaplite.com/temper.cgi
#--17:55:06--  http://services.soaplite.com/temper.cgi
#           => `temper.cgi'
#Resolving proxy... done.
#Connecting to proxy[192.168.10.2]:8080... connected.
#Proxy request sent, awaiting response... 411 Length Required
#17:55:07 ERROR 411: Length Required.

# http://www.soaplite.com/Temperatures#f2c :) 
# Page you are looking for does not exist on this site. Either link is outdated or you clicked something similar to http://www.soaplite.com/Demo or http://www.soaplite.com/Temperatures. Those are not links but URIs (Uniform Resource Identifier). They may look like clickable URLs (Uniform Resource Locator), but they are not and should be treated only as strings. They are not supposed to point to somewhere. Great explanation with more details you can find in XML Namespaces FAQ, Q12.3.

#use SOAP::Lite;
#print SOAP::Lite
#    -> uri( "http://www.soaplite.com/Temperatures" )
#    #-> proxy( "http://services.soaplite.com/temper.cgi" )
#    -> proxy( "http://proxy:8080/" )
#    -> f2c(32)
#    -> result;



#http://builder.com.com/5100-6389-1046624-2.html
#http://www.onlamp.com/pub/a/onlamp/2001/06/29/soap_lite.html
# HA! http://cookbook.soaplite.com/#specifying%20proxy


#  $ENV{HTTP_proxy} = "http://proxy.my.com/";;
# my $soap = SOAP::Lite->proxy('http://endpoint.server/', 
#                              proxy => ['http' => 'http://my.proxy.server/']);
# my $soap = SOAP::Lite->proxy('http://endpoint.server/', 
#                              proxy => 'http://my.proxy.server/');
# my $soap = SOAP::Lite->proxy('http://endpoint.server/');
# $soap->transport->proxy(http => 'http://my.proxy.server/');
