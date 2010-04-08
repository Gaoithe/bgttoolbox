package RubikShape;
use strict;

=head1 NAME

RubikShape.pm - manipulate rubik cubes, physical and mapped properties, solve or explore rubik

=head1 DESCRIPTION

=head2 rubik cube spec 

3x3 cube. 
Red opposite orange, Blue opposite Green, White opposite Yellow.
physical: 6 middle pieces w 1 colour, 8 corner pieces w 3 colours, 12 edge pieces w 2 colours
8 + 12 + 6 = 26 pieces.

Can map physical aspects directly into program form.
Or can be more abstract maybe, treat faces as objects, treat piece sides more seperately.

plain colour sides or pictures on sides 
If pictures on sides orientation of middle square adds another requirement to done checking.

=head2 design notes

Feb 2010

R O Y W G B 

=head2 Visualisation .. and tools for working out manipulation/solving methods

Visualisation - ascii, 2D, 3D
Use existing code - xmpuzzles xpuzzles ...

Visualisation of changes, e.g. this sequence of moves results in these changes
Display current cube, history of rotates, last few cubes.
How to modify location + orientation 
cmd line rotates, save, diff against saved, record sequence of moves
score for how close to solved.
diff score for how different from other cube

=head2 rubik in skype :)

                  (flag:NU)
              (flag:NU)  (flag:NU)
         (flag:NU)   (flag:NU)   (flag:NU)
      (flag:SO)   (flag:NU)   (flag:NU)  (flag:LY)
      (flag:SO)(flag:SO)  (flag:NU)  (flag:LY)(flag:LY)
      (flag:SO)(flag:SO)(flag:SO)(flag:LY)(flag:LY)(flag:LY)
          (flag:SO)(flag:SO)(flag:LY)(flag:LY)
              (flag:SO)(flag:LY)


(replace-string "G" "(flag:LY)")
(replace-string "R" "(flag:HK)")
(replace-string "B" "(flag:SO)")
(replace-string "." "(flag:CY)")
# do this one first:
(replace-string "Y" "(flag:NU)")


=head3 bleh

=cut 

use strict;

=head2 definition of cube in script

How define/load in from file? 
North South East West Up Down  NSEWUD
Y/W facing N/S, R/O E/W, G/B U/D

=head3 simple

this mightn't be too bad really.
54 faces
they travel 21 together with rotation of a side
how manage staying togetherness of the physical bits? just with abstract rules

folds.

origami.

There are only 6 moves.

=cut 

my $cube_str = qq(
...YYY...
...YYY...
...YYY...
RRRGGGOOO
RRRGGGOOO
RRRGGGOOO
...WWW...
...WWW...
...WWW...
...BBB...
...BBB...
...BBB...
);

=head3 physical

phys rep means add in all sides of pieces
North South East West Up Down  NSEWUD
this is interesting. sides have a particular place in structure, defines cube well.

=cut 

my $cube_str_trip_phys = qq(
... ... ... YxRxxB YxxxxB YxxOxB ... ... ...
... ... ... YxRxxx Yxxxxx YxxOxx ... ... ...
... ... ... YxRxGx YxxxGx YxxOGx ... ... ...
...  xxRxxx xxRxGx xxxxGx xxxOGx xxxOxx  ...
... ... ... xWRxGx xWxxGx xWxOGx ... ... ...
... ... ... xWRxxx xWxxxx xWxOxx ... ... ...
... ... ... xWRxxB xWxxxB xWxOxB ... ... ...
... ... ... xxRxxB xxxxxB xxxOxB ... ... ...
);

=head3 physical, loc fixed

One position cube never changes. Positions of where sides facing.
Other cube with colours. ... 
Colours will have to change places as they're rotated.

=cut 

my $cube_str_trip_phys = qq(
... NED ND NWD
... NE  N  NW
... NEU NU NWU
..E EU  U  WU  W
... SEU SU SWU
... SE  S  SW
... SED SD SWD
... ED  D  WD
);

my $cube_str_trip_phys = qq(
... ... ... YxRxxB YxxxxB YxxOxB ... ... ...
... ... ... YxRxxx Yxxxxx YxxOxx ... ... ...
... ... ... YxRxGx YxxxGx YxxOGx ... ... ...
...  xxRxxx xxRxGx xxxxGx xxxOGx xxxOxx  ...
... ... ... xWRxGx xWxxGx xWxOGx ... ... ...
... ... ... xWRxxx xWxxxx xWxOxx ... ... ...
... ... ... xWRxxB xWxxxB xWxOxB ... ... ...
... ... ... xxRxxB xxxxxB xxxOxB ... ... ...
);

=head3 not simple, not messy but missing orientation

26 pieces, how define orientation. 
facing out from face ... facing "up"

uhmmm.

=cut 

my $cube_str_triplets = qq(
... ... ... YBR YBx YBO ... ... ...
... ... ... YRx Yxx YOx ... ... ...
... ... ... YGR YGx YGO ... ... ...
... ... Rxx GRx Gxx GOx Oxx ... ...
... ... ... WGR WGx WGO ... ... ...
... ... ... WRx Wxx WOx ... ... ...
... ... ... WBR WBx WBO ... ... ...
... ... ... BRx Bxx BOx ... ... ...
);

=head3 position combined with physical

  positions 123 456 789 UP
  positions 10-18 MID
  positions 19-27 DOWN
  1 Up + East + North
  rotate pieces into these positions.

 e.g. corner YxRxxB (NSEWUD) Rotate E side (U to N) 
  E side (R) stays put, U=>N=>D=>S
   YxRxxB in pos 19 => pos 25 xBRxxY
   YxRxGx in pos 1  => pos 19 GxRxxY 
   xWRxGx in pos 7  => pos 1  GxRxWx
   xWRxxB in pos 25 => pos 7  xBRxWx
  rotate again
   xBRxxY in pos 25 => pos 7  xYRxBx 
  rotate again
   xYRxBx in pos 7  => pos 1  BxRxYx 

... ... ... YxRxxB 19  YxxxxB 20  YxxOxB 21 ... ... ...
... ... ... YxRxxx 10  Yxxxxx 11  YxxOxx 12 ... ... ...
... ... ... YxRxGx 1   YxxxGx 2   YxxOGx 3 ... ... ...
.xxRxxx 13  xxRxGx 4   xxxxGx 5   xxxOGx 6  xxxOxx 15 ...
... ... ... xWRxGx 7   xWxxGx 8   xWxOGx 9 ... ... ...
... ... ... xWRxxx 16  xWxxxx 17  xWxOxx 18 ... ... ...
... ... ... xWRxxB 25  xWxxxB 26  xWxOxB 27 ... ... ...
... ... ... xxRxxB 22  xxxxxB 23  xxxOxB 24 ... ... ...

OR like define YxRxxB == YN,RE,BD pos 19
 rot E side (U to N) same again 
 YN,RE,BD pos 19 =>
 YD,RE,BS pos 25 =>
 YS,RE,BU pos 7 =>
 YU,RE,BN pos 1

=cut 

=head3 3D array ?

=cut

my @blockus_colours = unpack("c*","RGBYOW.");
my @blockus_colours_desc = ( "red", "green", "blue", "yellow", "orange", "white", "blank" );
my @blockus_colours_skype = ( "(flag:HK)", "(flag:LY)", "(flag:SO)", "(flag:NU)", "(flag:xx)", "(flag:xx)", "(flag:CY)" );
my @blockus_colours_curses = ( 1, 2, 4, 3, 13, 7 );
#my @blockus_colours_curses = ( 10, 11, 12, 13, 14, 15 );
#my @blockus_colours_curses = ( 16, 17, 18, 19, 20, 21 );
# 5 purple 6 grey 7 white? 8 also green, 9 blackonwhite
# 10 11 12 13 14 15 black red green orange blue purple
# 16 turquoise

my %blockus_colours_c_to_curses;

my @rubik_colours = unpack("c*","RGBYWO.");
my @rubik_colours_desc = ( "red", "green", "blue", "yellow", "white", "orange", "blank" );

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = {};
    $self->{NAME} = undef;
    $self->{SIZE} = 0;
    $self->{CUBEARR}  = [];   # pieces set or unset, size of array depends on min/maxx 

    $self->{COLOUR}   = 0;  # colour only for in-game shapes

    $self->{MAXX}   = 0;  # min/max x and y for shape detecting
    $self->{MINX}   = 500;  # min x and y normalised to 0 for normal shapes
    $self->{MAXY}   = 0;
    $self->{MINY}   = 500;

    my $i=0;
    foreach my $ci (@blockus_colours) {
	$blockus_colours_c_to_curses{$ci} = $blockus_colours_curses[$i];
	$i++;
    }

    bless($self,$class);
    return $self;
}

# simple
#my @cube = ( 'Y','Y','Y' );

sub strToCube {
    my $self = shift;
    my $cube_str = shift;
    my $aref = shift || \@{ $self->{CUBEARR} };

    # cube string to array
    my @cube_str_chars = unpack("c*",$cube_str);

    # array to pieces list/count
    ## squares  count
    my %cube_char_counts;
    #my @cube_physical;
    my $i = 0; my ($x,$y) = (0,0);
    foreach my $p (@cube_str_chars) {
        $cube_char_counts{$p} += 1;
        print "p is $p, x=$x, y=$y, i=$i\n";
        #print Dumper(grep(/$p/, (@rubik_colours)));
        if (grep(/$p/, (@rubik_colours))) {
	    $$aref[$x][$y] = $p;
            $i++; 
            $x++;
        } else {
            if ($x>0) {$x=0; $y++;}
        }
    }
}

# Rotate side NSEWUD
sub rotEW {
    my $self = shift;
    my $eorw = shift;
    #my $ra_cube = shift || \@{ $self->{CUBEARR} };
    my $ra_cube = \@{ $self->{CUBEARR} };
    #my @first_row = ${$ra_cube}[$eorw][0,1,2];
    print "eorw=$eorw\n";
    my @first_row;
    $first_row[0] = $$ra_cube[$eorw][0];
    $first_row[1] = $$ra_cube[$eorw][1];
    $first_row[2] = $$ra_cube[$eorw][2];
    print "ffs $first_row[0] $first_row[1] $first_row[2]";
    for (my $y=0; $y<9; $y++) {
        #@{$ra_cube}[$eorw][$y,$y+1,$y+2] = @{$ra_cube}[$eorw][$y+3,$y+4,$y+5];
        $$ra_cube[$eorw][$y] = $$ra_cube[$eorw][$y+3];
    }
    #@{$ra_cube}[$eorw][$y,$y+1,$y+2] = @first_row;
    my $y=9;
    print "ffs2 $y $first_row[0] $first_row[1] $first_row[2]\n";
    $$ra_cube[$eorw][$y] = $first_row[0];
    $$ra_cube[$eorw][$y+1] = $first_row[1];
    $$ra_cube[$eorw][$y+2] = $first_row[2];
}

sub rotE {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotEW(3,$ra_cube);
}

sub rotW {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotEW(5,$ra_cube);
}

# Rotate side NSEWUD
sub rotNS {
    my $self = shift;
    my $nors = shift;
    my $nors2 = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    my @first_row;
    $first_row[0] = $$ra_cube[0][$nors];
    $first_row[1] = $$ra_cube[1][$nors];
    $first_row[2] = $$ra_cube[2][$nors];
    print "ffs $first_row[0] $first_row[1] $first_row[2]";
    for (my $x=0; $x<6; $x++) {
        $$ra_cube[$x][$nors] = $$ra_cube[$x+3][$nors];
    }
    $$ra_cube[6][$nors] = $$ra_cube[5][$nors2];
    $$ra_cube[7][$nors] = $$ra_cube[4][$nors2];
    $$ra_cube[8][$nors] = $$ra_cube[3][$nors2];

    $$ra_cube[5][$nors2] = $first_row[0];
    $$ra_cube[4][$nors2] = $first_row[1];
    $$ra_cube[3][$nors2] = $first_row[2];
}

sub rotN {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotNS(3,11,$ra_cube);
}

sub rotS {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotNS(5,9,$ra_cube);
}

my $scube_str = qq(
...YYY...
...YYY...
...YYY...
RRRGGGOOO
RRRGGGOOO
RRRGGGOOO
...WWW...
...WWW...
...WWW...
...BBB...
...BBB...
...BBB...
);

# Rotate side NSEWUD
sub rotUD {
    my $self = shift;
    my $udx1 = shift;
    my $udx2 = shift;
    my $udy1 = shift;
    my $udy2 = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    my @first_row;
    $first_row[0] = $$ra_cube[3][2];
    $first_row[1] = $$ra_cube[4][2];
    $first_row[2] = $$ra_cube[5][2];

    $$ra_cube[3][2] = $$ra_cube[2][5];
    $$ra_cube[4][2] = $$ra_cube[2][4];
    $$ra_cube[5][2] = $$ra_cube[2][3];

    $$ra_cube[2][5] = $$ra_cube[5][6];
    $$ra_cube[2][4] = $$ra_cube[4][6];
    $$ra_cube[2][3] = $$ra_cube[3][6];

    $$ra_cube[5][6] = $$ra_cube[6][3];
    $$ra_cube[4][6] = $$ra_cube[6][4];
    $$ra_cube[3][6] = $$ra_cube[6][5];

    $$ra_cube[6][3] = $first_row[0];
    $$ra_cube[6][4] = $first_row[1];
    $$ra_cube[6][5] = $first_row[2];
}

sub rotU {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotUD(2,6,2,6,$ra_cube);
}

sub rotD {
    my $self = shift;
    my $ra_cube = shift || \@{ $self->{CUBEARR} };
    $self->rotUD(5,9,?,?,$ra_cube);
}





########################################################################
sub printCube {
    my $self = shift;
    my $aref = shift || \@{ $self->{CUBEARR} };
    for (my $y=0; $y<12; $y++) {
      for (my $x=0; $x<10; $x++) {
        #print "${$ra_cube}[$x][$y]";
        print "$$aref[$x][$y]";
        ($x%3==2) && print " ";
      }
      print "\n";
      ($y%3==2) && print "\n";
    }
    print "\n";
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

sub printCubeCurses {
    my $self = shift;
    my $aref = shift || \@{ $self->{CUBEARR} };

    # init
    print qq([?1049h[H[2J);
    my $dwc = qq(#6); # double width chars

    my $BoardMinX = 11;
    my $BoardMinY = 4;


    for (my $y=0; $y<12; $y++) {
      for (my $x=0; $x<10; $x++) {
        #print "${$ra_cube}[$x][$y]";
        #print "$$aref[$x][$y]";
 	my $c = $blockus_colours_c_to_curses{$$aref[$x][$y]};
        $self->cursesCol(1,30+$c,40+$c);  # bright, same fg + bg colour
        my $char = pack("c",$$aref[$x][$y]);
        $self->cursesPutXY($char,$BoardMinX+$x,$BoardMinY+$y);
        ($x%3==2) && print " ";
      }
      print "\n";
      ($y%3==2) && print "\n";
    }
    print "\n";

    # reset colour
    $self->cursesCol(0,33,40);
    $self->cursesPutXY(" ",0,35);

    return




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
 	    my $c;# = $blockus_colours_c_to_curses{$$aref[$xi][$yi]};
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


sub name {
    my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}


1;  # so the require or use succeeds
