#!/usr/bin/perl

=head1 NAME

rubik_mess.pl - manipulate rubik cubes, physical and mapped properties, solve or explore rubik

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

=cut 

=head3 3D array ?

=cut


print $cube_str;


my @rubik_colours = unpack("c*","RGBYWO.");
my @rubik_colours_desc = ( "red", "green", "blue", "yellow", "white", "orange", "blank" );



# cube string to array
my @cube_str_chars = unpack("c*",$cube_str);

# array to pieces list/count
## squares  count
my %cube_char_counts;
my @cube_physical;
my $i = 0; my ($x,$y);
foreach my $p (@cube_str_chars) {
    $cube_char_counts{$p} += 1;
    $x = $i%20;
    $y = $i/20; 
    print "p is $p, x=$x, y=$y, i=$i\n";
    #print Dumper(grep(/$p/, (@rubik_colours)));
    if (grep(/$p/, (@rubik_colours))) {
	$cube_physical[$x][$y] = $p;
	$i++ 
    }
}


use Data::Dumper; 
print Dumper(%cube_char_counts);


print "x=$x, y=$y\n";

print Dumper(@cube_physical);
# >;)


use lib ".";
use lib "./bin";
use RubikShape;


sub add_around_if_colour_matches {
    my ($r_ashape,$colour,$ra_cube,$x,$y) = @_;

    if ($x>=0 && $y>=0) {
	if ($colour == ${$ra_cube}[$x][$y]) {
	    # take and blank this square
	    $$r_ashape->addSquare($x,$y); # = $colour;
     	    #@{$ra_cube}->[$x][$y] = $rubik_colours[4]; 
     	    ${$ra_cube}[$x][$y] = $rubik_colours[4]; 
	    add_all_around_if_colour_matches($r_ashape,$colour,$ra_cube,$x,$y);
        }
    }
}

sub add_all_around_if_colour_matches {
    my ($r_ashape,$colour,$ra_cube,$x,$y) = @_;
    # recursively go right+down and left+up and add all attached cols
    add_around_if_colour_matches($r_ashape,$colour,$ra_cube,$x+1,$y);
    add_around_if_colour_matches($r_ashape,$colour,$ra_cube,$x,$y+1);
    add_around_if_colour_matches($r_ashape,$colour,$ra_cube,$x-1,$y);
    add_around_if_colour_matches($r_ashape,$colour,$ra_cube,$x,$y-1);
}


# take a copy of the cube.
my @cube_physical_copy = @cube_physical;

#### TODO: slurp shapes off of cube in rubik corner linked order and validate that way as well.
# iterate over cube
# find touching squares of same colour (horiz or vert, not diag),
#  pull them out into one shape,
#  blank them on the cube
my $shape_count = 0;
my @shapes_on_cube;
my $ashape = RubikShape->new();
for ($x=0; $x<20; $x++) {
    for ($y=0; $y<20; $y++) {
        my $colour = $cube_physical_copy[$x][$y];
	# if not blank
	if ($colour != $rubik_colours[4]) {
	    # take and blank this square
	    $ashape->addSquare($x,$y,$colour);
	    $cube_physical_copy[$x][$y] = $rubik_colours[4]; 
 	    # recursively go right+down and left+up and add all attached cols
	    add_all_around_if_colour_matches(\$ashape,$colour,\@cube_physical_copy,$x,$y);
	    push(@shapes_on_cube,$ashape);
	    $ashape->printShape();
	    $ashape = RubikShape->new();
	    
	}

    }
}

print "HOI x=$x, y=$y, shapes=$#shapes_on_cube, ";
$ashape->printShape();


print " is the cube cleared off ?";
print Dumper(@cube_physical);



print "now, how many shapes? sort by colour, size shape (rotated)  ";

my (%col_count, %col_sz_count) = (0,0);
foreach my $s (@shapes_on_cube) {
    $col_count{$s->{COLOUR}}++;
    $col_sz_count{$s->{COLOUR}}{$s->{SIZE}}++;
}

print Dumper(%col_count);
print Dumper(%col_sz_count);
