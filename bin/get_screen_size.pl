#!/usr/bin/perl

$verbose=1;

print qx(stty -a);


@sttyl = qx(stty -a|grep rows);
my ($rows, $cols) = ($sttyl[0] =~ m/rows\s*(\d+);\s*columns\s*(\d+);/);
print "DEBUG: screen size is rows:$rows x cols:$cols\n" if ($verbose);


@sttyl = qx(stty -a);
#@sttyl = qx(stty -a|sed 's/\s=\s/ /g');
@stty = split(/\s/,@sttyl);
foreach $s (@stty) { print "s:$s\n"; }

@stty = split(/;/, $sttyl[0]);
foreach $s (@stty) { print "s;:$s\n"; }
$rows=$stty[1];
$cols=$stty[2];
print "DEBUG: screen size is rows:$rows x cols:$cols\n" if ($verbose);


@stty = split(/[;:space:]/, (@sttyl));
foreach $s (@stty) { print "split:$s\n"; }


#@sttyl = qx(stty -a);
#@stty = split(/\s/, $sttyl[0]);
#$rows=$stty[1];
#$cols=$stty[2];
#print "DEBUG: screen size is rows:$rows x cols:$cols\n" if ($verbose);
#print $stty[3];
#print $stty[4];
#print $stty[5];

%h = @stty;
@stty = split(/\s/, $sttyl[0]);
%h2 = @stty;
print "h:%h";
print "j2:%h2";
%h3 = @sttyl;

use Data::Dumper;

print @{[Data::Dumper->Dump([\%h], ['*h'])]};

print @{[Data::Dumper->Dump([\%h2], ['*h2'])]};

print @{[Data::Dumper->Dump([\%h3], ['*h3'])]};
