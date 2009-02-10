package BlockusBoard;
use strict;

use BlockusShape;

# TODO a BlockusShape is just a BlockusBoard, a BlockusBoard is just a BlockusShape :)  Chicken or egg.  Inherit.  Same class?
# A board has shapes/squares with different colours

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = {};
    $self->{NAME} = undef;
    $self->{SIZE} = 0;
    $self->{ARRAY}  = [];   # pieces set or unset, size of array depends on min/maxx 

    $self->{BOARDSTR} = "";  # ascii string representing board
    $self->{BOARDARR} = [];  # array of board
    $self->{BOARDINFO} = {};  # hash of shapes summary for board (counts)

    $self->{SHAPEARR} = [];  # array of shapes ?

    $self->{BWIDTH} = 20;
    $self->{BHEIGHT} = 20;

    $self->{MAXX}   = 0;  # min/max x and y for shape detecting
    $self->{MINX}   = 500;  # min x and y normalised to 0 for normal shapes
    $self->{MAXY}   = 0;
    $self->{MINY}   = 500;

    bless($self,$class);
    return $self;
}

my @blockus_colours = unpack("c*","RGBY.");
my @blockus_colours_desc = ( "red", "green", "blue", "yellow", "blank" );
my @blockus_colours_skype = ( "(flag:HK)", "(flag:LY)", "(flag:SO)", "(flag:NU)", "(flag:CY)" );


sub populateFromString {
    my $self = shift;
    print "# board string to array\n";
    my @board_str_chars = unpack("c*",$self->{BOARDSTR});

    print "# array to squares list/count\n";
    # my %board_char_counts; $self->{BOARDINFO}
    # my @board_physical;  $self->{BOARDARR}
    my $i = 0; 
    my ($x,$y);
    foreach my $p (@board_str_chars) {
	$self->{BOARDINFO}{$p} += 1;
	$x = $i%$self->{BWIDTH};
	$y = int($i/$self->{BWIDTH}); 
	my $pc = pack("c",$p);
	#print "p is $pc, x=$x, y=$y, i=$i\n" if ($debug);
	#print Dumper(grep(/$p/, (@blockus_colours)));
	if (grep(/$p/, (@blockus_colours))) {
	    $self->{BOARDARR}[$x][$y] = $p;
	    $i++ 
	}
    }
}

# populate using ascii string
sub populate {
    my $self = shift;
    $self->{BOARDSTR} = shift;
    $self->populateFromString();
}

sub printSummary {
    my $self = shift;
    print "# couloured square counts array:\n";
    use Data::Dumper; 
    print Dumper($self->{BOARDINFO});

    #print "x=$x, y=$y\n";
    print "# Board physical dumped:\n";
    print Dumper($self->{BOARDARR});
    # >;)
}

sub print {
    my $self = shift;
    print $self->{BOARDSTR};
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







sub add_around_if_colour_matches {
    my $self = shift;
    my ($r_ashape,$colour,$ra_board,$x,$y) = @_;

    if ($x>=0 && $y>=0) {
	if ($colour == ${$ra_board}[$x][$y]) {
	    # take and blank this square
	    $$r_ashape->addSquare($x,$y); # = $colour;
     	    #@{$ra_board}->[$x][$y] = $blockus_colours[4]; 
     	    ${$ra_board}[$x][$y] = $blockus_colours[4]; 
	    $self->add_all_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y);
        }
    }
}

sub add_all_around_if_colour_matches {
    my $self = shift;
    my ($r_ashape,$colour,$ra_board,$x,$y) = @_;
    # recursively go right+down and left+up and add all attached cols
    $self->add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x+1,$y);
    $self->add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y+1);
    $self->add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x-1,$y);
    $self->add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y-1);
}


sub countShapes {
    my $self = shift;

    print "#Verify board. Count each shape by following same-coloured squares.\n";
    # take a copy of the board.
    # ohhh tricky. copy of 2D array and preserve dimension!
    # perldoc perllol (not in)  http://www.perlmonks.org/?node_id=489224
    #my @board_physical_copy = [ $self->{BOARDARR} ];
    #my @board_physical_copy = ( ( $self->{BOARDARR} ) );
    my @board_physical_copy = @{ $self->{BOARDARR} };
    #print "# Board physical dumped:\n";
    #print Dumper(@board_physical_copy);

    #### TODO: slurp shapes off of board in blockus corner linked order and validate that way as well.
    # iterate over board
    # find touching squares of same colour (horiz or vert, not diag),
    #  pull them out into one shape,
    #  blank them on the board
    my $shape_count = 0;
    my @shapes_on_board;
    my $ashape = BlockusShape->new();
    my ($x,$y);
    for ($x=0; $x<$self->{BWIDTH}; $x++) {
	for ($y=0; $y<$self->{BHEIGHT}; $y++) {
	    my $colour = $board_physical_copy[$x][$y];
	    #my $colour = $board_physical_copy[$x][$y][0];  ## ACK! WHY [0]?
	    #my $colour = $board_physical_copy[$x*$self->{BWIDTH}+$y][0][0];  ## ACK! WHY [0]?
	    # if not blank
	    if ($colour != $blockus_colours[4]) {
		# take and blank this square
		$ashape->addSquare($x,$y,$colour);
		$board_physical_copy[$x][$y] = $blockus_colours[4]; 
		# recursively go right+down and left+up and add all attached cols
		$self->add_all_around_if_colour_matches(\$ashape,$colour,\@board_physical_copy,$x,$y);
		push(@shapes_on_board,$ashape);
		push(@{$self->{SHAPEARR}},$ashape);
		$ashape->printShape();
		$ashape = BlockusShape->new();
		
	    }
	    
	}
    }
    
    print "HOI x=$x, y=$y, shapes=$#shapes_on_board, ";
    $ashape->printShape();




    print "#is the board cleared off ?";
    print Dumper(@board_physical_copy);



    print "now, how many shapes? sort by colour, size shape (rotated)  ";

    my (%col_count, %col_sz_count) = (0,0);
    foreach my $s (@shapes_on_board) {
	$col_count{$s->{COLOUR}}++;
	$col_sz_count{$s->{COLOUR}}{$s->{SIZE}}++;
    }
    
    print Dumper(%col_count);
    print Dumper(%col_sz_count);


}











sub name {
    my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}

# add one (more) coloured square to this shape
# used verifying blockus boards
sub addSquare {
    my $self = shift;
    my ($x, $y, $c);
    if (@_) { $x = shift; $y = shift; }
    if (@_) { $c = shift; }
    #print "addSquare x=$x,y=$y\n";
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
