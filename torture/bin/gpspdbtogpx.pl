#!/usr/bin/perl -w

use strict;
use GPS::Babel;

my $file = shift or die "no file specified";

use Palm::PDB;
use Data::Dumper;

my $pdb = new Palm::PDB;

# register Palm::Raw as handler for all pdb loaded
use Palm::Raw;

#&Palm::PDB::RegisterPDBHandlers("GPSPDB",
#				"cGPS", "coGP"
#				);

$pdb->Load( $file ) or die "Load $file: $!";
# e.g. dumpdatebook.pl pdb processing.
# "No handler defined for creator "cGPS", type "strm""

#print Dumper($pdb);

print "Creator:".$pdb->{'creator'}."\n";

my $fmt;
for ($pdb->{'creator'}) {
    if    (/cGPS/)  { $fmt="cetus"; }
    elsif (/coGP/)  { $fmt = "coto"; }     # do something else
    #elsif (/TZGP/)  { }
    #elsif (/Gps4/)  { }
    else            { print "Not sure what file format\n."; }     # default
}

my $babel = GPS::Babel->new();

#my $babel = GPS::Babel->new({
#        exename => 'gpsbabel'
#    });

# auto detect format (doesn't auto-detect pdb:
# "Multiple formats (cetus, copilot, coto, gcdb, geoniche, gpilots, gpspilot, mag_pdb, magnav, palmdoc, pathaway and quovadis) handle extension .pdb at /home/jamesc/bin/gpspdbtogpx.pl line 20")
#my $gpxdata = $babel->read($file);
my $gpxdata = $babel->read($file, { in_format => 'cetus' } );


print "GPXName:".$gpxdata->name()."\n";
#print Dumper($gpxdata);
#print Dumper($gpxdata->{'tracks'}->[0]);
#print Dumper($gpxdata->{'tracks'}->[0]->{'segments'}->[0]->{'points'});
#print Dumper($gpxdata->{'tracks'}->[0]->{'segments'}->[0]->{'points'}->[0]);
#print Dumper($gpxdata->{'tracks'}->[0]->{'segments'}->[0]->{'points'}->[1]);
#print Dumper($gpxdata->{'tracks'}->[0]->{'segments'}->[0]->{'points'}->[2]);

my $count_rejectL=0;
my $count_rejectH=0;
my $count_ok=0;
my $gpxokay = Geo::Gpx->new();

foreach my $point (@{$gpxdata->{'tracks'}->[0]->{'segments'}->[0]->{'points'}}) {
    #print "point: " . Dumper($point) ;
    #if ($point->{'hdop'} >=4 ) {
    #if ($point->{'hdop'} >=1.4 ) {
    if ($point->{'hdop'} >=1.3 ) {
	$count_rejectH++;
    } elsif ($point->{'hdop'} <0 ) {
	$count_rejectL++;
    #} elsif ($point->{'sat'} <6 ) {
    } else {
	$count_ok++;
	$gpxokay->add_waypoint($point);
    }
}

$gpxokay->name("James-".$file);
$gpxokay->author({ name => "James", link => { text => "dspsrv", href => "http://www.dspsrv.com/~jamesc/map"}});
$gpxokay->link({ text => "dspsrv", href => "http://www.dspsrv.com/~jamesc/map"});
$gpxokay->keywords(['gaoithe','Ireland']);


print "Okay:".$count_ok." RejectH:".$count_rejectH." RejectL:".$count_rejectL."\n";
#'course' => '0.000000',
#'ele' => '-8.800000',
#'lat' => '53.356366700',
#'time' => 1190304846,
#'speed' => '0.720222',
#'fix' => '3d',
#'sat' => '3',
#'lon' => '-6.227361700',
#'hdop' => '3.600000'-18 


# use Geo::gpx
# "If you will only be dealing with GPX files use Geo::Gpx directly." 
$babel->write($file.'.gpx', $gpxdata, { out_format => 'gpx' });
print "File:".$file.'.gpx'." written.\n";
#my $xml = $gpxokay->xml();
$babel->write($file.'okayok.gpx', $gpxokay, { out_format => 'gpx' });
print "File:".$file.'okayok.gpx'." written.\n";
$babel->write($file.'.text', $gpxdata, { out_format => 'text' });


