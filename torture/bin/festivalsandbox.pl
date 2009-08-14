#!/usr/bin/perl -w

#select(STDERR); $| = 1;     # make unbuffered
#select(STDOUT); $| = 1;     # make unbuffered

open (FESTIVAL, "|festival") or die "can't run festival.\n";
select(FESTIVAL); $| = 1;     # make unbuffered

while ($argv[0]) {
    if ($argv[0] =~ /^-/) {
        if ($argv[0] =~ /^-h/) {
print "Type in something for Festival to say\n";
print "Ctrl-D exits\n";
print FESTIVAL "(SayText \"Type in something for Festival to say.\")\n";
print FESTIVAL "(SayText \"Hit enter after every line.\")\n";
print FESTIVAL "(SayText \"Control D to exit.\")\n";

        } else {
            # usage TODO
        }
    }
}


#redirect stdout to festival

while (<>) {
    chomp;
    s/\\/\\\\/g;
    s/\"/\\\"/g;
    print FESTIVAL "(SayText \"$_\")\n";
}

