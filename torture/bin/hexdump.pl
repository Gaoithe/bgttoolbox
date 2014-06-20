#!/usr/bin/perl -w

# n by n
sub hexdump {
    my $text = shift;
    my $addroffset = shift || 0; # optional
    my $n = shift || 20;
    my $pstr = "hack";
    my $addr = 0;


#    do {
#	$str = substr($text,$addr,$n);
#	my $texthex = join("", map { sprintf "%02x", $_ } unpack("C*",$str));
#	print "$texthex: $str\n";
#	$addr += $n;
#    } until ($str eq "");

    # the extra awkward checks are to avoid warnings from substr
    #until ($pstr eq "" || $addr+$n>length($text) || !defined($pstr)) {
    until ($pstr eq "" || $addr>length($text) || !defined($pstr)) {
    #until ($pstr eq "" || !defined($pstr)) {
        $pstr = substr($text,$addr,$n);
        if (defined($pstr) && $pstr) {
           my $textaddr = sprintf "%08x", $addr + $addroffset;
           my $padl = 2 * ($n - length($pstr));
           my $texthex = join("", map { sprintf "%02x", $_ } unpack("C*",$pstr));
           my $pad =  " " x $padl;
           $pstr =~ s/[\x00-\x1f]/./g;
           $pstr =~ s/[\x7f-\xff]/./g;
           print "$textaddr: $texthex $pad $pstr\n";
        }
        $addr += $n;
    }
}



hexdump("1234567");
hexdump("MMMMMMMMMMMMOOOOOOOOOOOOOOORRRRRRR\nRRRRRRRRGGGGGGG\nGGGGGGEB1234567");
hexdump("MMMMMMMMMMMMOOOOOOOOOOOOOOORRRRRRR\nRRRRRRRRGGGGGGG\nGGGGGGEB1234567",2345);
hexdump("\x00\x02\x34MMMMMMMMMMMMOOOOOOOOOOOOOOORRRRRRR\nRRRRRRRRGGGGGGG\nGGGGGGEB1234567");
hexdump("\x78\x79\x7e\x7f\x80\x81\x82\xfe\xff\x00\x02\x34MMMMMMMMMMMMOOOOOOOOOOOOOOORRRRRRR\nRRRRRRRRGGGGGGG\nGGGGGGEB1234567");


my $file = shift;

if ( !open( FILE, "<$file" )) {
    warn "$file: $!";
    exit;
} else {
    print "Data from $file\n";
}

# read - text mode returns short lines 
#while ( <FILE>) {
#    hexdump $_;
#}

while ( read(FILE,$_,20)) {
    hexdump $_;
}
