package BlockusBoard;
use strict;

use BlockusShape;

# TODO a BlockusShape is just a BlockusBoard, a BlockusBoard is just a BlockusShape :)  Chicken or egg.  Inherit.  Same class?
# A board has shapes/squares with different colours

my @blockus_colours = unpack("c*","RGBY.");
my @blockus_colours_desc = ( "red", "green", "blue", "yellow", "blank" );
my @blockus_colours_skype = ( "(flag:HK)", "(flag:LY)", "(flag:SO)", "(flag:NU)", "(flag:CY)" );
my @blockus_colours_curses = ( 1, 2, 4, 3 );
my %blockus_colours_c_to_curses;

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

    for (my $i=0; $i<5; $i++) {
	my $ci = $blockus_colours[$i];
	$blockus_colours_c_to_curses{$ci} = $blockus_colours_curses[$i];
    }

    bless($self,$class);
    return $self;
}


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
    #print Dumper($self->{BOARDINFO});
    foreach my $k (keys(%{$self->{BOARDINFO}})) {
	print "k=$k kv=$self->{BOARDINFO}->{$k}\n";
    }

    #print "x=$x, y=$y\n";
    #print "# Board physical dumped:\n";
    #print Dumper($self->{BOARDARR});
    # >;)
}

sub print {
    my $self = shift;
    print $self->{BOARDSTR};
}


sub printBoard {
    my $self = shift;
    my $aref = shift || \@{ $self->{BOARDARR} };

    #print Dumper(@$aref);

    print "\nBOARD:\n";
    for (my $yi = 0; $yi < $self->{BHEIGHT}; $yi++) {
	for (my $xi = 0; $xi < $self->{BWIDTH}; $xi++) {
	    print pack("c",$$aref[$xi][$yi]);
	}
  	print "\n";
    }
}


#attr: 0=Reset, 1Bright, 2Dim,  3Underline,  5Blink,  7Reverse,  8Hidden
#fg:   30 + (0Black,  1Red,  2Green,  3Yellow,  4Blue,  5Magenta,  6Cyan,  7White)
#bg:   40 + (")
sub cursesCol {
    my $self = shift;
    my ($attr, $fg, $bg) = (shift, shift, shift);
    my $text = shift || ""; # optional

    print "[".$attr.";".$fg.";".$bg."m".$text;
}

sub cursesPutXY {
    my $self = shift;
    my $text = shift;
    my ($x, $y) = (shift, shift);
    my $rev = shift;

    my $revstr = "";
    $revstr = qq([7m) if ($rev);

    print "[".$y.";".$x."H".$revstr.$text;
		 
}    

sub printBoardCurses {
    my $self = shift;
    my $aref = shift || \@{ $self->{BOARDARR} };

    my $BoardMinX = 11;
    my $BoardMinY = 4;


    # init
    print qq([?1049h[H[2J);
    my $dwc = qq(#6); # double width chars

    # print base board
    $self->cursesCol(2,30,47); # dim black on white
    my $y = $BoardMinY-1;
    $self->cursesPutXY($dwc . (' ' x (2+$self->{BWIDTH})),$BoardMinX-1,$y);
    for ($y=$BoardMinY;$y<$BoardMinY+$self->{BHEIGHT};$y++) {
        $self->cursesPutXY($dwc . ' ' . ('o' x $self->{BWIDTH}) . ' ' ,$BoardMinX-1,$y);
    }
    $self->cursesPutXY($dwc . (' ' x (2+$self->{BWIDTH})),$BoardMinX-1,$y);


    for (my $yi = 0; $yi < $self->{BHEIGHT}; $yi++) {
	for (my $xi = 0; $xi < $self->{BWIDTH}; $xi++) {
	    # print using char in case colour doesn't work
	    my $char = pack("c",$$aref[$xi][$yi]);
	    # set colour 
 	    my $c = $blockus_colours_c_to_curses{$$aref[$xi][$yi]};
	    $self->cursesCol(1,30+$c,40+$c);  # bright, same fg + bg colour
            $self->cursesPutXY($dwc . $char,$BoardMinX+$xi,$BoardMinY+$yi);
	    #$self->cursesPutXY(" ",0,27+$xi);
	    #print "c is $c, char is $char, ref is ".$$aref[$xi][$yi]."\n";
	}
    }

    # print summary 
    $self->cursesPutXY(" ",0,27);
    # reset colour
    $self->cursesCol(0,33,40);
    $self->printSummary();

    # reset colour
    $self->cursesCol(0,33,40);
    $self->cursesPutXY(" ",0,35);

}

sub printBoardCursesMBLEH {
    my $self = shift;

    # init
    print qq([?1049h[H[2J);
    print qq(#6;MOOOp); # double width chars

    $self->cursesPutXY("       ",10,10);
    $self->cursesPutXY("       ",11,11,1);
    $self->cursesPutXY("       ",12,12);
    $self->cursesCol(0,31,40);
    $self->cursesPutXY("       ",11,13,1);
    $self->cursesCol(0,32,40);
    $self->cursesPutXY("       ",11,14,1);
    $self->cursesCol(0,33,40);
    $self->cursesPutXY("       ",11,15,1);
    $self->cursesCol(0,34,40);
    $self->cursesPutXY("       ",11,16,1);

    print qq([59;13Hblockus);
    print qq([1;1Hbaa);
    print qq([1;38H[7m             ). (' ' x 20);
    print qq([27m[21;60Hmoo\n);

    return;


    print qq([27m[1;46H[7m    [27m[1;60H[7m  [27m[2;38H[7m  [27m[2;60H[7m  [27m[3;38H[7m  [27m[3;60H[7m  [27m[4;38H);

    print qq([?1049h[H[2J[59;13Hj - left   k - rotate   l - right   <space> - drop   p - pause   q - quit[1;1HScore: 0[1;38H[7m  [27m[1;46H[7m    [27m[1;60H[7m  [27m[2;38H[7m  [27m[2;60H[7m  [27m[3;38H[7m  [27m[3;60H[7m  [27m[4;38H
[7m  [27m[4;60H[7m  [27m[5;38H[7m  [27m[5;60H[7m  [27m[6;38H[7m  [27m[6;60H[7m  [27m[7;38H[7m  [27m[7;60H[7m  [27m[8;38H[7m  [27m[8;60H[7m  [27m[9;38H[7m  [27m[9;60H[7m  [27m[10;38H[7m  [27m[10;60H[7m  [27m[11;38H[7m  [27m[11;60H[7m  [27m[12;38H[7m  [27m[12;60H[7m  [27m[13;38H[7m  [27m[13;60H[7m  [27m[14;38H[7m  [27m[14;60H[7m  [27m[15;38H[7m  [27m[15;60H[7m  [27m[16;38H[7m  [27m[16;60H[7m  [27m[17;38H[7m  [27m[17;60H[7m  [27m[18;38H[7m  [27m[18;60H[7m  [27m[19;38H[7m  [27m[19;60H[7m  [27m[20;38H[7m  [27m[20;60H[7m  [27m[21;38H[7m                        [27m[1;46H  [1;50H[7m  [27m[2;46H[7m    [27m[21;60H[7m  [27m[1;48H    [2;46H  [2;50H[7m  [27m[3;46H[7m    [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[2;48H    [3;46H  [3;50H[7m  [27m[4;46H[7m    [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[21;60H[7m  [27m[3;48H    
[4;46H  [4;50H[7m  [27m[5;46H[7m    [27m[21;60H[7m  [27m[4;48H    
[5;46H  [5;50H[7m  [27m[6;46H[7m    [27m[21;60H[7m  [27m[5;48H    
																																					    [6;46H  [6;50H[7m  [27m[7;46H[7m    [27m[21;60H[7m  [27m[6;46H[7m    [27m  [7;44H[7m    [27m  [21;60H[7m  [27m[6;44H[7m    [27m  [7;42H[7m    [27m  [21;60H[7m  [27m[6;42H[7m    [27m  [7;40H[7m    [27m  [21;60H[7m  [27m[6;42H    [7;40H  [7;44H[7m  [27m[8;40H[7m    [27m[21;60H[7m  [27m[21;60H[7m  [27m[1;1HScore: 12[7;42H    [8;40H    [19;42H[7m    [27m[20;40H[7m    [27m[21;60H[7m  [27m[1;1HScore: 13[1;46H[7m      [27m[2;48H[7m  [27m[21;60H[7m  [27m[1;46H      [2;46H[7m      [27m[3;48H[7m  [27m[21;60H[7m  [27m[1;48H[7m  [27m[2;46H  [21;60H[7m  [27m[2;46H[7m  [27m[3;48H  [21;60H[7m  [27m[1;48H  [2;46H  [2;50H  [3;46H[7m      [27m[21;60H[7m  [27m[1;1HScore: 30[2;48H  [3;46H      [19;48H[7m  [27m[20;46H[7m      [27m[21;60H[7m   [27m[21;60Hmoo);

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


  sub deep_copy {
    my $this = shift;
    if (not ref $this) {
      $this;
    } elsif (ref $this eq "ARRAY") {
      [map deep_copy($_), @$this];
    } elsif (ref $this eq "HASH") {
      +{map { $_ => deep_copy($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
  }


sub countShapes {
    my $self = shift;

    print "#Verify board. Count each shape by following same-coloured squares.\n";
    # take a copy of the board.
    # ohhh tricky. copy of 2D array and preserve dimension!
    # perldoc perllol (not in)  http://www.perlmonks.org/?node_id=489224
    #my @board_physical_copy = [ $self->{BOARDARR} ];
    #my @board_physical_copy = ( ( $self->{BOARDARR} ) );

    #my @board_pc = @{ $self->{BOARDARR} };
    #my @board_physical_copy = @board_pc;

    # OHHHH yeah :)
    my @board_physical_copy = map { [ @$_ ] } @{ $self->{BOARDARR} };

    # NO! deep_copy doesn't preserve array dimensions
    #my @board_physical_copy = deep_copy(@{ $self->{BOARDARR} });

    #print "# Board physical dumped:\n";
    #print Dumper(@board_physical_copy);
    # BUT now changing @board_physical_copy changes $self->{BOARDARR} ! :( not what we want
    # AHH. the lists inside @board_physical_copy are [] (refs) that is why they change
    # ?eh? @newlist = map { [ @$_ ] } @{ $self->{oldlist} };
    # deep copying  http://www.stonehenge.com/merlyn/UnixReview/col30.html

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

		#$self->printBoard(\@board_physical_copy);
		$self->printBoardCurses(\@board_physical_copy);
		
	    }
	    
	}
    }
    
    print "HOI x=$x, y=$y, shapes=$#shapes_on_board, ";
    $ashape->printShape();




    print "#is the board cleared off ?";
    #print Dumper(@board_physical_copy);
    $self->printBoard(\@board_physical_copy);



    print "now, how many shapes? sort by colour, size shape (rotated)  ";
    print "\n";

    my (%col_count, %col_sz_count) = (0,0);
    foreach my $s (@shapes_on_board) {
	$col_count{$s->{COLOUR}}++;
	$col_sz_count{$s->{COLOUR}}{$s->{SIZE}}++;
    }
    
    
    #print Dumper(%col_count);
    print "Shape counts for colours: ";
    foreach my $k (sort(keys(%col_count))) {
	print pack("c",$k) . ":" . $col_count{$k} . " " if ($k);
    }
    print "\n";

    #print Dumper(%col_sz_count);
    print "Shape count breakdown:\n";
    foreach my $k (sort(keys(%col_sz_count))) {
	print "colour:" . pack("c",$k) . "  ";
	foreach my $k2 (sort(keys(%{$col_sz_count{$k}}))) {
	    print "size=$k2 count=" . $col_sz_count{$k}{$k2} . "  ";
	}
	print "\n";
    }

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
