#!/usr/local/bin/perl -w

=head1 NAME

lessnlr.pl - process nlr binary files
lessnlr.pl - process nlr files record by record

=head1 SYNOPSIS

  somewhat generic definition of file format so script is easily mod to 
  process other file formats.

  process nlr header, ... ignore protocol ... for now
  grep pduType, vpi/vci/length/dir
  collect stats - count PDUs, different PDU data types & directions on vpi/vci channels
  dump stats collected.
  or e.g. process file to fix broken header ...


extract nlr file format header info 
e.g. pduType, atm vpi/vci, direction, timestamp

file records defined in a generic way so script can be taken and changed
to process other binary files

=head1 DESCRIPTION

This is a dev/test tool.

=cut

my $file = shift;

if ( !open( FILE, "<$file" )) {
    warn "can't open $file: $!";
    next;
} else {
    print "Data from $file\n";
}

binmode(FILE);

#http://www.unix.org.ua/orelly/perl/cookbook/ch08_12.htm
#http://www.unix.org.ua/orelly/perl/prog/ch03_008.htm
#$\ ($OUTPUT_RECORD_SEPARATOR)  $/ ($INPUT_RECORD_SEPARATOR)
#http://www.unix.org.ua/orelly/perl/prog/ch02_09.htm#PERL2-CH-2-SECT-9.3
#http://www.unix.org.ua/orelly/perl/cookbook/ch08_01.htm#ch08-23799
#http://www.unix.org.ua/orelly/perl/cookbook/ch08_16.htm
# 8.15. Reading Fixed-Length Records
# use unpack!

## hashlist of field name, bytes

# must be array [ (array of hashes) not hash ( to preserve order
my @fileFormatH = (
                   { "nl_prefix" => 4 },
                   { "nl_prefix2" => 4 },
                   pdu_head24 => (
                       atm_info => (
                           { "flag", 1 },
                           { "ver_prot", 1 },
                           { "eventid", 1 },
                           { "status", 1 },
                           timestamp => (
                               { "sec", 4 },
                               { "nsec", 4 }
                           ),
                           { "site", 2 },
                           { "vpi", 2 },
                           { "vci", 2 },
                           { "len", 2 },
                           { "dir", 1 },
                           { "phys_id", 1 },
                           { "cid", 1 },
                           { "pad", 1 },
                       )
                   )
                   );

# read part of a record (read 1 entry in file record hash)
# entry (is passed as a reference) is either:
#  1. a container of more records
#  2. an attribute with a name and length
# $ret is array reference, passed into recursive calls, 
# all record entries are appended onto $ret as they are read
sub readPart { 
    my ( $entry, $ret ) = @_;
    my $count = 0;
    my $rv;
    if(ref($entry) eq "ARRAY" ) {

        # entry is array 
        #shift @$entry;
        #print "array\n";
        foreach my $item (@$entry) {
            #print "readPart( $item )\n";
            $rv = readPart( $item, $ret );
            if (defined($rv)) { $count += $rv; }
        }        

    } else {

        # entry is hash
        while( my ($name,$len) = each %$entry ) {
            #print "read name $name len $len\n";
            my $data; 
            $rv = read(FILE, $data, $len);
            if (defined($rv)) { $count += $rv; }

            #use Data::Dumper; 
            #print Dumper($data);
            # http://perldoc.perl.org/functions/sprintf.html
            # unpack unpack!
            #printf '%0*x', $len*2, $data;
            my $val;
            if ($len == 1) {
                ($val) = unpack("c",$data);
            } elsif ($len == 2) {
                ($val) = unpack("s",$data);
            } elsif ($len == 4) {
                ($val) = unpack("l",$data);
            } else {
            }
            
            #printf "value is %x\n", $val;
 
            if (undef($rv)) {
                warn "error reading $name length $len: $!";
                return $rv;
            } 
            # ? broken ? $count += $rv;
            $$ret{$name} = {"len" => $len, "data" => $data, "val" => $val};
            #use Data::Dumper; 
            #print Dumper(%$ret);
        }
        return $count;
        
    }
    # finished!
    return $count;

}



my (%record,$rv,$rv2); my $count=0;
while ($rv1 = readPart(\@fileFormatH, \%record)) {
    #print "record $count\n";
    $count++;

    #use Data::Dumper; 
    #print Dumper(%record);
    #print "rv is $rv1 (bytes read)\n";

    my $pktlen = $record{'len'}{'val'};
    # fix length to 4 bgyte boundary
    $pktlen = ($pktlen + 3) & 0xFFFFFFFC;
    #print "len is ".$record{'len'}{'val'}.", pktlen is $pktlen\n";

    my $pdudata;
    if (!($rv2 = read(FILE, $pdudata, $pktlen))) {
        perror("failed to read pdu data\n");
        exit 46;
    }
    #print "rv is $rv2 (bytes read)\n";

    printf "prot %02x%02x", $record{'flag'}{'val'}, $record{'ver_prot'}{'val'};
    printf " vpi %04x vci %04x", $record{'vpi'}{'val'}, $record{'vci'}{'val'};
    printf " dir %d", $record{'dir'}{'val'};
    print "\n";

    printf "len 0x%02x+0x%02x=0x%02x\n", $rv1, $rv2, $rv1+$rv2;
    if ($pktlen != $record{'len'}{'val'}) {
        print "WARNING: PDU length adjusted from ".$record{'len'}{'val'}.".\n"
    }

    # first 4 longs
    my @datalongvals = unpack("llll",$pdudata);
    foreach(@datalongvals) {
        printf "%08x ", $_;
    }
 
    $endbytes = $pktlen - 0x10;
    if ($endbytes > 0) {
        if ($endbytes > 8) { printf(".... "); $endbytes = 8; }
        my $endlongs = $endbytes/4;
        my @datalongvals = unpack("l".$endlongs,
                                  substr($pdudata,$pktlen-$endbytes,$endbytes));
        foreach(@datalongvals) {
            printf "%08x ", $_;
        }
        
    }

    print "\n";

    # read PDU data
    #pktlen = (len + 3) & 0xFFFFFFFC;

    # exit after 1 go - testing.
    #exit 45;

}


print "rv is $rv\n";
#while (read(FILE, $buff, 8)) {
#    print STDOUT $buff;
#}

=head2 readRecords

sub readRecords { 
# array of records - load in 80? (+ more in bg)
    my $scr_lines = 80;
    my @recs;

    my $pos = tell(FILE);
    while ( <FILE>) {
        if ( recBegin ) { # begin of record
            my %rec;
            $rec{'pos'} = $pos;
            if ( $bits[0] ne "#2c" and $bits[0] =~ /$match/ ) {
                print "Site " . $bits[0] . "\n  ";
                shift @bits;
                print join( "\n  ", @bits );
                print "\n";
            }
            @bits = ();
            next;
        }
        $pos = tell(FILE);
    }
}

=cut
