#!/usr/bin/perl -w
#
# dig out mozilla passwords that I've forgotten
#
use MIME::Base64;


my $match = shift;
my @pwfiles = @ARGV;
my $mozdir = $ENV{HOME} . "/.mozilla";

$match ||= ".*";

# if no pwfile is specified, try and find all of 'em
if ( !@pwfiles or !$pwfiles[0] ) {
    shift @pwfiles if @pwfiles;
    opendir( MOZ, $mozdir );
    my @files = grep !/^\.\.?$/, readdir( MOZ );
    closedir( MOZ );
    for my $f ( @files ) {
        next unless -d "$mozdir/$f";
        opendir( MOZ, "$mozdir/$f" );
        my @salts = grep /.*.slt$/, readdir( MOZ );
        closedir( MOZ );
        for my $s ( @salts ) {
            next unless -d "$mozdir/$f/$s";
            opendir( MOZ, "$mozdir/$f/$s" );
            map { push @pwfiles, "$mozdir/$f/$s/$_" } grep /\.s$/, readdir( MOZ );
            closedir( MOZ );
        }
    }
}

for my $pwfile ( @pwfiles ) {
    if ( !open( FILE, "<$pwfile" )) {
        warn "$pwfile: $!";
        next;
    } else {
        print "-" x 80;
        print "\nData from $pwfile\n";
        print "-" x 80;
        print "\n";
    }

    my @bits;
    while ( <FILE>) {
        if ( /^\.$/ ) { # end of block
            if ( $bits[0] ne "#2c" and $bits[0] =~ /$match/ ) {
                print "Site " . $bits[0] . "\n  ";
                shift @bits;
                print join( "\n  ", @bits );
                print "\n";
            }
            @bits = ();
            next;
        }
        chomp;
        if ( s/^~// ) {
            $_ = decode_base64( $_ );
        $bits[-1] .= ": $_";
        } else {
            push @bits, $_;
        }
    }
}
