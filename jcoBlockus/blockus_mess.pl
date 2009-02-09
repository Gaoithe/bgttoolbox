#!/usr/bin/perl

=head1 NAME

blockus_mess.pl - manipulate blockus pieces, play blockus

=head1 DESCRIPTION

=head2 board spec 

I think.

Board 20x20, 21 pieces to a colour. 
1x1,1x2,2x3,5x4,12x5 = total of 21 pieces, = 89 squares
20*20 board = 400 squares
89*4 piece squares = 356
So 44 spare squares.

=head2 blockus solitaire validation

Jan 2009, I think I've worked out a blockus solitare.
At home though and without access to a blockus set.

GG.YYGGGGYBBBBBRRRBB
GGYYGYGYYYRRRRRBRRBB
YYGGGYYGGYGGGGGBBBRR
YGYYGYYGGGYYYYYBYYRR
YGGYYGGYYYGBBBBYYRYY
G.GGYGBYGYGGGYYBYRRY
GYYY.GBGGGYYGYYBBYRY <<  YY oops this one not needed
GGY.YGBBGBBB.BB..YRY
.G..GYGBRGGBB.B.RYYR
B.GGGYGRBBBGG.BRRRYR
BBBGBYGRYBBG.RBR..RY
GGGBBYGRYGG..RRBRRRY
G.BGB.YRY.GG.RBBRYYY
G.BGGGYYRYYRRBB.YRRR <<  YY
.GGBRRR.RR.YR..BYYYR
.GBBBBRBBRYYY.BBBRYR
.GGRRRBBRBBYBB.BRRRY
.RRGGGRRRB.BBRBRBRYY
RRG.R.G.RBBRBRRRBBBY
RGGGRRRR.RRRRBBB..BY

? lots of spare space.

=head2 foo

backwards:
board image -> count pieces + validate
load board into array.

in memory piec e manipulation + position on board
print board: ascii/html/skype/graphics/... :)


=head2 blockus in skype 

(flag:NU)(flag:NU)(flag:NU)(flag:SO)(flag:HK)(flag:HK)
(flag:NU)    (flag:SO)(flag:SO)(flag:LY)(flag:HK)(flag:HK)
(flag:NU)(flag:SO)(flag:SO)(flag:LY)(flag:LY)(flag:HK)
                  (flag:LY)

(replace-string "G" "(flag:LY)")
(replace-string "R" "(flag:HK)")
(replace-string "B" "(flag:SO)")
(replace-string "." "(flag:CY)")
# do this one first:
(replace-string "Y" "(flag:NU)")


=head3 bleh

a=*; echo $a; echo "$a"
last one output is: *  :-7 :) phoo

=cut 

use strict;

my $board_str = qq(
GG.YYGGGGYBBBBBRRRBB
GGYYGYGYYYRRRRRBRRBB
YYGGGYYGGYGGGGGBBBRR
YGYYGYYGGGYYYYYBYYRR
YGGYYGGYYYGBBBBYYRYY
G.GGYGBYGYGGGYYBYRRY
GYYY.GBGGGYYGYYBBYRY
GGY.YGBBGBBB.BB..YRY
.G..GYGBRGGBB.B.RYYR
B.GGGYGRBBBGG.BRRRYR
BBBGBYGRYBBG.RBR..RY
GGGBBYGRYGG..RRBRRRY
G.BGB.YRY.GG.RBBRYYY
G.BGGGYYRYYRRBB.YRRR
.GGBRRR.RR.YR..BYYYR
.GBBBBRBBRYYY.BBBRYR
.GGRRRBBRBBYBB.BRRRY
.RRGGGRRRB.BBRBRBRYY
RRG.R.G.RBBRBRRRBBBY
RGGGRRRR.RRRRBBB..BY
);

print $board_str;


my @blockus_colours = unpack("c*","RGBY.");
my @blockus_colours_desc = ( "red", "green", "blue", "yellow", "blank" );
my @blockus_colours_skype = ( "(flag:HK)", "(flag:LY)", "(flag:SO)", "(flag:NU)", "(flag:CY)" );


# board string to array
my @board_str_chars = unpack("c*",$board_str);

# array to pieces list/count
## squares  count
my %board_char_counts;
my @board_physical;
my $i = 0; my ($x,$y);
foreach my $p (@board_str_chars) {
    $board_char_counts{$p} += 1;
    $x = $i%20;
    $y = $i/20; 
    print "p is $p, x=$x, y=$y, i=$i\n";
    #print Dumper(grep(/$p/, (@blockus_colours)));
    if (grep(/$p/, (@blockus_colours))) {
	$board_physical[$x][$y] = $p;
	$i++ 
    }
}


use Data::Dumper; 
print Dumper(%board_char_counts);


print "x=$x, y=$y\n";

print Dumper(@board_physical);
# >;)


use lib ".";
use lib "./bin";
use BlockusShape;


sub add_around_if_colour_matches {
    my ($r_ashape,$colour,$ra_board,$x,$y) = @_;

    if ($x>=0 && $y>=0) {
	if ($colour == ${$ra_board}[$x][$y]) {
	    # take and blank this square
	    $$r_ashape->addSquare($x,$y); # = $colour;
     	    #@{$ra_board}->[$x][$y] = $blockus_colours[4]; 
     	    ${$ra_board}[$x][$y] = $blockus_colours[4]; 
	    add_all_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y);
        }
    }
}

sub add_all_around_if_colour_matches {
    my ($r_ashape,$colour,$ra_board,$x,$y) = @_;
    # recursively go right+down and left+up and add all attached cols
    add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x+1,$y);
    add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y+1);
    add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x-1,$y);
    add_around_if_colour_matches($r_ashape,$colour,$ra_board,$x,$y-1);
}


# take a copy of the board.
my @board_physical_copy = @board_physical;

#### TODO: slurp shapes off of board in blockus corner linked order and validate that way as well.
# iterate over board
# find touching squares of same colour (horiz or vert, not diag),
#  pull them out into one shape,
#  blank them on the board
my $shape_count = 0;
my @shapes_on_board;
my $ashape = BlockusShape->new();
for ($x=0; $x<20; $x++) {
    for ($y=0; $y<20; $y++) {
        my $colour = $board_physical_copy[$x][$y];
	# if not blank
	if ($colour != $blockus_colours[4]) {
	    # take and blank this square
	    $ashape->addSquare($x,$y,$colour);
	    $board_physical_copy[$x][$y] = $blockus_colours[4]; 
 	    # recursively go right+down and left+up and add all attached cols
	    add_all_around_if_colour_matches(\$ashape,$colour,\@board_physical_copy,$x,$y);
	    push(@shapes_on_board,$ashape);
	    $ashape->printShape();
	    $ashape = BlockusShape->new();
	    
	}

    }
}

print "HOI x=$x, y=$y, shapes=$#shapes_on_board, ";
$ashape->printShape();


print " is the board cleared off ?";
print Dumper(@board_physical);



print "now, how many shapes? sort by colour, size shape (rotated)  ";

my (%col_count, %col_sz_count) = (0,0);
foreach my $s (@shapes_on_board) {
    $col_count{$s->{COLOUR}}++;
    $col_sz_count{$s->{COLOUR}}{$s->{SIZE}}++;
}

print Dumper(%col_count);
print Dumper(%col_sz_count);
