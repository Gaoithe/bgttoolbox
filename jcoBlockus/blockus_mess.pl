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
use warnings;

use lib ".";
use lib "./bin";
use BlockusShape;
use BlockusBoard;


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


my $debug = 0;

my $board = BlockusBoard->new();


print "# board populate, set by string (and that converted to array)\n";
$board->populate($board_str);

$board->print();
$board->printSummary();


$board->countShapes();


$board->printBoard();

$board->printBoardCurses();
