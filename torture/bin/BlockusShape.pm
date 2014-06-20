package BlockusShape;
use strict;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = {};
    $self->{NAME} = undef;
    $self->{SIZE} = 0;
    $self->{ARRAY}  = [];   # pieces set or unset, size of array depends on min/maxx 

    $self->{COLOUR}   = 0;  # colour only for in-game shapes

    $self->{MAXX}   = 0;  # min/max x and y for shape detecting
    $self->{MINX}   = 500;  # min x and y normalised to 0 for normal shapes
    $self->{MAXY}   = 0;
    $self->{MINY}   = 500;

    bless($self,$class);
    return $self;
}

sub printShape {
    my $self = shift;
    my $info;
    if (@_) { $info = shift; print $info; }
    print "name=".$self->{NAME}.", " if ($self->{NAME});
    my $w = 1 + $self->{MAXX} - $self->{MINX};
    my $h = 1 + $self->{MAXY} - $self->{MINY};
    print "size=".$self->{SIZE}.", w=$w, h=$h, ";
    print "colour=".$self->{COLOUR}.", " if ($self->{COLOUR});

    print "xoffset=".$self->{MINX}.", " if ($self->{MINX});
    print "yoffset=".$self->{MINY}.", " if ($self->{MINY});

    print "\nSHAPE:\n";
    for (my $yi = 0; $yi < $h; $yi++) {
	for (my $xi = 0; $xi < $w; $xi++) {
	    if ($self->{ARRAY}[$xi+$self->{MINX}][$yi+$self->{MINY}]) {
		print "1";
	    } else {
		print " ";
	    }
	}
  	print "\n";
    }
}

sub name {
    my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}

sub addSquare {
    my $self = shift;
    my ($x, $y, $c);
    if (@_) { $x = shift; $y = shift; }
    if (@_) { $c = shift; }
    print "addSquare x=$x,y=$y\n";
    $self->{SIZE}++;
    $self->updateMinMax($x,$y);
    $self->{ARRAY}[$x][$y]=1;
    $self->{COLOUR} = $c if ($c);
}

sub updateMinMax {
    my $self = shift;
    my ($x, $y);
    if (@_) { $x = shift; $y = shift; }
    $self->{MINX} = $x if ($x < $self->{MINX});
    $self->{MAXX} = $x if ($x > $self->{MAXX});
    $self->{MINY} = $y if ($y < $self->{MINY});
    $self->{MAXY} = $y if ($y > $self->{MAXY});
}

sub normalizeShape {
    my $self = shift;

    # array is sized down
    my $w = 1 + $self->{MAXX} - $self->{MINX};
    my $h = 1 + $self->{MAXY} - $self->{MINY};
    my @newshapearray;
    for (my $xi = 0; $xi < $w; $xi++) {
	for (my $yi = 0; $yi < $h; $yi++) {
	    $newshapearray[$xi][$yi] = $self->{ARRAY}[$xi+$self->{MINX}][$yi+$self->{MINY}];
	}
    }

    $self->{ARRAY} = @newshapearray;
    

    # minx,miny => 0,0
    # width and height = maxx and maxy
    $self->{MAXX} -= $self->{MINX};
    $self->{MAXY} -= $self->{MINY};
    $self->{MINX} = 0;
    $self->{MINY} = 0;
}

1;  # so the require or use succeeds
