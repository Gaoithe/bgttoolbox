#!/usr/bin/env perl
#
#

use File::Type;

my $ft = File::Type->new();
my $file = $ARGV[0];

my $type_from_file = $ft->checktype_filename($file);

my $type_1 = $ft->mime_type($file);

print "tf:$type_from_file  t1:$type_1\n";

