#!/usr/bin/perl -w
# dump a datebook pdb
use Palm::PDB;
use Palm::Datebook;
use Data::Dumper;
use MIME::QuotedPrint;
use Date::Calc qw( :all );

my $file = shift or die "no file specified";
my $pdb = new Palm::PDB;
$pdb->Load( $file ) or die "Load $file: $!";

print <<"EOH";
BEGIN:VCALENDAR
VERSION:1.0
EOH

for my $record ( @{$pdb->{records}}) {
    # time fixup
    my $start = sprintf( "%02d%02d", $record->{start_hour},
                         $record->{start_minute} );
    my $end = sprintf( "%02d%02d", $record->{end_hour},
                       $record->{end_minute} );

    # unset => hour/minute are set to 0xff
    if ( $start eq "255255" ) {
        $start = "";
    } else {
        $start = "T" . $start . "00";
    }

    if ( $end eq "255255" ) {
        $end = "";
    } else {
        $end = "T" . $end. "00";
    }

    print "BEGIN:VEVENT\n";
    print "DTSTART:";
    printf( "%04d%02d%02d%s\n",
            $record->{year}, $record->{month}, $record->{day}, $start );

    if ( $end ) {
        print "DTEND:";
        printf( "%04d%02d%02d%s\n",
                $record->{year}, $record->{month}, $record->{day}, $end );
    }

    # alarm
    if ( defined( $record->{alarm})) {
        my $advance = $record->{alarm}{advance}; # -1 => no advance
        my $unit = $record->{alarm}{unit}; # 0m 1h 2d

        if ( $advance != -1 ) {
            my ( $y, $m, $d, $h, $mi, $s );

            my $base_hr = $record->{start_hour};
            my $base_mn = $record->{start_minute};

            # no time -> midnight
            if ( $base_hr == 0xff ) {
                $base_hr = 0;
                $base_mn = 0;
            }

            if ( $unit == 0 ) {
                ( $y, $m, $d, $h, $mi, $s ) =
                  Add_Delta_YMDHMS( $record->{year}, $record->{month},
                                    $record->{day}, $base_hr, $base_mn, 0,
                                    0, 0, 0, 0, -$advance, 0 );
            } elsif ( $unit == 1 ) {
                ( $y, $m, $d, $h, $mi, $s ) =
                  Add_Delta_YMDHMS( $record->{year}, $record->{month},
                                    $record->{day}, $base_hr, $base_mn, 0,
                                    0, 0, 0, -$advance, 0, 0 );
            } elsif ( $unit == 2 ) {
                ( $y, $m, $d, $h, $mi, $s ) =
                  Add_Delta_YMDHMS( $record->{year}, $record->{month},
                                    $record->{day}, $base_hr, $base_mn, 0,
                                    0, 0, -$advance, 0, 0, 0 );
            } else {
                die "unknown unit $unit\n";
            }
            printf "AALARM:%04d%02d%02dT%02d%02d%02d\n",
              $y, $m, $d, $h, $mi, $s;
        }
    }

    # repeat rules
    if ( defined( $record->{repeat})) {
        my $type = $record->{repeat}{type};
        my $freq = $record->{repeat}{frequency};
        if ( $type == 1 ) {
            print "RRULE:D$freq\n";
        } elsif ( $type == 2 ) {
            print "RRULE:W$freq ";
            my @days = ( "SU", "MO", "TU", "WE", "TH", "FR", "SA" );
            for my $day ( 0..6 ) {
                print $days[$day] . " "
                  if $record->{repeat}{repeat_days}[$day];
            }
            print "#" . $record->{repeat}{start_of_week} . "\n";
        } elsif ( $type == 3 ) {
            die "fix monthly by day\n";
        } elsif ( $type == 4 ) {
            die "fix monthly by date\n";
        } elsif ( $type == 5 ) {
            print "RRULE:Y$freq\n";
        }
    }

    # summary
    my $summ = $record->{description};
    $summ =~ s/\n/\\n/g;
    print "SUMMARY:" . $summ . "\n";

    # what to do with 'note'?
    if ( $record->{note} ) {
        my $string = $record->{note};
        my $encoded = "";
        print "ATTACH;ENCODING=QUOTED-PRINTABLE:=\n";
        $encoded = encode_qp( $string, "" );
        # stupid-ass palm encoding
        $encoded =~ s/=0A/=0D=0A=\n/g;
        print $encoded . "\n";
    }

    print "UID:" . $record->{id} . "\n";
    print "END:VEVENT\n";
}
print "END:VCALENDAR\n";
