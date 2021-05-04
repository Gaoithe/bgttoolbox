#!/usr/bin/perl -w

#  convert_data.pl
#  load numbers from files, convert to csv for import into sheets and graphing
#

=head1 NAME

convert_data.pl - load numbers from files, convert to csv for import into sheets and graphing

=head1 SYNOPSIS

  # run the script and see the "usage" message
  ./convert.pl

  # run the script and ...
  ./convert.pl ...

=head1 DESCRIPTION

This script helps to take cstat data in multiple different files and merge and convert into .csv file.
.csv file ready for import into sheets for graph plotting and other analysis.

=head1 USAGE

convert_data.pl [TODO: OPTIONS] <list of files>

TODO: output file name
DONE: do not include all 0 value files (DEFAULT mode)
TODO: do not include all 0 value rows (useful for humans and decreases file size but messes up graphs maybe)
TODO: back-fill char option default "0", "BF0" useful for debug
TODO: debug mode ? myeh no.
TODO: column totals (good for analysis - stats matching & comparison overview)

TODO: aggregate data - add up stats from every second to every minute or every 5/10/...
 One day of ~180 cstat items for MMSC in 40M to 50M .tgz
 ~180 cstat files per day 4.4M to 6.3M size, 18400 lines each 
 A week of cstats with 180 cstat items from MMSC dropping 0 values gives a 180M .csv file.
 This file kills excel/openoffice sheets and won't load in google sheets etc. :-(
DESIGN: aggregate by stripping one datetime char gives 1sec 10secs 1min 10mins 1hour 1day ....
DESIGN: aggregate by converting datetime and rounding down gives more possibilities
 e.g. datetime 13/4/2021-00:17:44 => -agg 3 13/4/2021-00:17

e.g. 
convert_data.pl mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7*

WARNING: stats all zero in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliver_req_in_nack, so not including it.
86400 lines in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliver_req_out
86400 lines in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliver_req_out
86400 lines in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_in
86400 lines in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_in_nack
86400 lines in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_out
5 files read gives us 5 columns
datetime, mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliver_req_out mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliveryreport_req_out mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_in mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_in_nack mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_submit_req_out
datetime, mmsc.mm7_deliver_req_out, mmsc.mm7_deliveryreport_req_out, mmsc.mm7_submit_req_in, mmsc.mm7_submit_req_in_nack, mmsc.mm7_submit_req_out
5 columns

$ less cstats.csv 
datetime, mmsc.mm7_deliver_req_out, mmsc.mm7_deliveryreport_req_out, mmsc.mm7_submit_req_in, mmsc.mm7_submit_req_in_nack, mmsc.mm7_submit_req_out
13/4/2021-00:17:44, 0, 0, 0
13/4/2021-00:17:45, 0, 0, 0, 0
13/4/2021-00:17:46, 0, 0, 0, 0, 0
.
.
14/4/2021-00:17:53, 0, 0

=head1 DESIGN/OPERATION

Read in multiple files and parse/combine data by dates
Drop data files which are all 0
Handle file sets where some files missing some date/time entries.

TODO: load into elasticsearch or myriad other cool & modern stats analysis tools :-P

=head2 Example of input file names, locations and contents

hosts dirs mmsc01a mmsc01b mmsc02a mmsc02b

ls mmsc01b/tmp/
cstat_14-04-2021  cstat_15-04-2021  cstat_16-04-2021  cstat_17-04-2021  cstat_18-04-2021  cstat_19-04-2021

ls mmsc01b/tmp/cstat_1*

mmsc01b/tmp/cstat_14-04-2021:
flow                                      mimx_sparta.dr_req_in                  mmsc.mm7_readreply_req_out_nack  qsr.not_for_me
h2c.clnt_conns                            mimx_sparta.dr_req_out                 mmsc.mm7_replace_req_in          qsr.nqs_drained_messages
h2c.m_ack_req_in                          mimx_sparta.dr_res_in                  mmsc.mm7_replace_req_in_nack     qsr.nqs_retrieved_messages
h2c.m_ack_rsp_out_ack                     mimx_sparta.dr_res_out                 mmsc.mm7_submit_req_in           qsr.opens_for_delete
h2c.m_ack_rsp_out_nack                    mimx_sparta.fwd_req_in                 mmsc.mm7_submit_req_in_nack      qsr.parked_receipt_retrieve_retries

$ head mmsc01b/tmp/cstat_14-04-2021/mimx_flip.msgs
13/4/2021-00:17:36 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:17:37 0 mmsc01-pri-b 0 mmsc01-pri-a 0
.

$ head mmsc01b/tmp/cstat_14-04-2021/xena.http_req_in
13/4/2021-00:18:19 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:18:20 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:18:21 0 mmsc01-pri-b 0 mmsc01-pri-a 0
.

$ head mmsc01b/tmp/cstat_14-04-2021/qsr.messages
13/4/2021-00:15:28 51480 quasar-a-2 12412 quasar-b-2 14050 quasar-b-1 12526 quasar-a-1 12492
13/4/2021-00:15:29 51474 quasar-a-2 12411 quasar-b-2 14049 quasar-b-1 12522 quasar-a-1 12492
13/4/2021-00:15:30 51471 quasar-a-2 12411 quasar-b-2 14049 quasar-b-1 12521 quasar-a-1 12490
.

$ head mmsc01b/tmp/cstat_14-04-2021/reafer.normal_msgs_in_acked
13/4/2021-00:18:09 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:18:10 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:18:11 0 mmsc01-pri-b 0 mmsc01-pri-a 0

$ head mmsc01b/tmp/cstat_14-04-2021/mmsc.mm7_deliver_req_out
13/4/2021-00:17:50 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:17:51 0 mmsc01-pri-b 0 mmsc01-pri-a 0
13/4/2021-00:17:52 0 mmsc01-pri-b 0 mmsc01-pri-a 0

=head2 Output file and contents

=head3 OPTION 1 just take the combined stat, drop per-process stats.

mmsc01b/cstat_14-04-2021.csv
datetime, mimx_flip.msgs, xena.http_req_in, qsr.messages, reafer.normal_msgs_in_acked, mmsc.mm7_deliver_req_out 
13/4/2021-00:15:28, 0, 0, 51480, 0, 0
13/4/2021-00:15:29, 0, 0, 51474, 0, 0
13/4/2021-00:15:30, 0, 0, 51471, 0, 0
13/4/2021-00:17:50, 0, 0, 51479, 0, 0
.
.

SUMMARY tt total files, tt total stats, tt stats with non-zero items, ll average file lines(max:x min:y), ll total data times

=head3 OPTION 2 take the combined stat and all per-process stats: NAH.

mmsc01b/cstat_14-04-2021_ALL.csv
datetime, mimx_flip.msgs, mimx_flip.msgs_p1, mimx_flip.msgs_p2, xena.http_req_in, xx1, xx2, qsr.messages, qq1, qq2, qq3, qq4, reafer.normal_msgs_in_acked, rr1, rr2, mmsc.mm7_deliver_req_out, mm1, mm2
 
MYEH. okay, hassle and not needed.

=cut

my $VERSION = 0.01;
my $usage = <<END;
usage: $0 [-agg <aggregateval>] [-o outfile] <datafilelist>
convert_data.pl $VERSION
mandatory:
  datafilelist  list of files to read cstat values from
options:
  -agg        how many chars to aggregate (0 default, 1 10secs, 2/3 1min, 4 10min, 5/6 1hour
  -o <file>   output .csv file name

debug options:
  -bfc <char> backfill char, default "0", e.g. "BF0" useful for debug 

# e.g. 
convert_data.pl -agg 3 -o mmsc02b_cstat_aggMin_14to19-04-2021.csv mmsc02b/tmp/cstat_*/*

END


if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}

my $optAggVal = 0;
my $optBfcVal = 0;
my $optOutFile = "converted.csv";

if ($ARGV[0]) {
while ($ARGV[0] =~ "^-") {

    # TODO use this format instead ?
    #$_ = $ARGV[0];
    #if (/-v/i) {

    if ($ARGV[0] =~ "-agg") {
	shift(@ARGV);
	$optAggVal = int(shift(@ARGV));
	# if not an integer go away
    }

    if ($ARGV[0] =~ "-bfc") {
	shift(@ARGV);
	$optBfcVal = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-o") {
	shift(@ARGV);
	$optOutFile = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-v") {
	$verbose = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-PrintMap") {
	shift(@ARGV);
	$printmaplang = shift(@ARGV);
	die "PrintMap doesn't work yet";
    }
}}

if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}


# read files in
# check if file data is all zero and WARNING/discard if so.
# create list/hash with date/time for every second of the day. yes.
# as file is read, option to do simple aggregation by truncating date/time
# write out .csv file with combined data into one file

# INIT: data{datetime} = stat;
# column_names[i++] = statname;
# data{datetime} += stat;
#Count number of lines in a file
my @column_names;
my %column_names;
my $column_count=0;
my $columns=0;

my @file_names;
my %datacount;
my %csdata;
my %csdataAgg;

my $backfillfull="";
my $statAgg=0;

foreach my $file (@ARGV) {

    # all zeros check
    my $allzeros=1;
    open (FILE, $file) or die "Can't open '$file': $!";
    while (<FILE>) {    
	my ($datetime, $stat) = m/(^[^\s]*)\s+([^\s]*)\s.*/;
	if ($stat != 0) { $allzeros=0; }
    }
    close FILE;
    if ($allzeros == 1) {
	print "WARNING: stats all zero in $file, so not including it.\n";
	next; # foreach next file
    }

    my $shortfile = basename($file);
    my $statname = $shortfile;
    if (not exists($column_names{$statname})) {
	$column_names{$statname} = $column_count++;
	push @column_names, $statname;
	$columns++;
    }
	   
    open (FILE, $file) or die "Can't open '$file': $!";
    my $lines = 0;
    my $linesAgg = 0;
    my $datetimeAggLast = "";
    while (<FILE>) {    
	#e.g. parse this: 13/4/2021-00:15:30 51471 quasar-a-2 12411 quasar-b-2 14049 quasar-b-1 12521 quasar-a-1 12490
	#                 ^^^^^^^^^^^^^^^^^^ ^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	#                   datetime         stat       we don't care about the rest
	#split/parse out datetime and stat
	my ($datetime, $stat) = m/(^[^\s]*)\s+([^\s]*)\s.*/;
	#printf "datetime:%s stat:%s\n", $datetime, $stat;
	$stat = int($stat);
	# OPTION for human parsing - do not include all 0 value rows
	if ($stat == 0) { next; }

	if (not exists($csdata{$datetime}{$statname})) {
	    $csdata{$datetime}{$statname} = $stat;
	} else {
	    $csdata{$datetime}{$statname} += $stat;
	}

	if ($optAggVal > 0) {
	    my $datetimeAgg = substr $datetime,0,-$optAggVal;
	    #print "optAggVal:$optAggVal dt:$datetime atAgg:$datetimeAgg last:$datetimeAggLast\n";
	    if (not exists($csdataAgg{$datetimeAgg}{$statname})) {
		$csdataAgg{$datetimeAgg}{$statname} = $stat;
	    } else {
		$csdataAgg{$datetimeAgg}{$statname} += $stat;
	    }
	}

	$lines++;
    }
    close FILE;
    $datalinecount = keys %csdata;
    $dataagglinecount = keys %csdata;
    print "$lines lines in $file, $dataagglinecount aggregated, $datalinecount data lines so far.\n";
    push @file_names, $file;
}

print "$columns files read gives us $columns columns\n";

use File::Basename;

my $outfile=$optOutFile;
open (OUTFILE, '>', $outfile) or die "Can't open '$outfile': $!";
# print column header line
printf "datetime, %s\n", join(" ",@file_names);
printf "datetime, %s\n", join(", ",@column_names);
printf OUTFILE "datetime, %s\n", join(", ",@column_names);
# writing out, sorted by date/time order
if ($optAggVal > 0) { %csdata = %csdataAgg; }
foreach my $datetime (sort keys %csdata) {
    #my @hash = @csdata{$datetime};
    #print keys @hash;
    my %hash = %{$csdata{$datetime}}; #https://perlmaven.com/multi-dimensional-hashes

    #printf OUTFILE "%s, %s\n", $datetime, join(", ", map{qq{$hash{$_}}} @column_names);
    my $values = "";
    foreach my $stat (@column_names) {
	if (exists($hash{$stat})) {
	    $values .= ", $hash{$stat}";
	} else {
	    $values .= ", 0";
	}
    }
    printf OUTFILE "%s%s\n", $datetime, $values;
    #printf OUTFILE "%s, DEBUG: %s\n", $datetime, join(", ", map{qq{$_=>$hash{$_}}} @column_names);
    #printf OUTFILE "%s, DEBUG2: %s\n", $datetime, join(", ", map{qq{$_=>$hash{$_}}} sort keys %hash);
}

$datalinecount = keys %csdata;
print "$datalinecount lines and $columns columns written to $outfile.\n";
