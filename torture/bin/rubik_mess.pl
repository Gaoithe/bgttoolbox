#!/usr/bin/perl

use strict;

=head1 NAME

rubik_mess.pl - manipulate rubik cubes, physical and mapped properties, solve or explore rubik
call and test RubikShape.pm

=head1 DESCRIPTION

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

print $cube_str;


use lib ".";
use lib "./bin";
use RubikShape;

my $debug = 0;

my $shape = RubikShape->new;

$shape->strToCube($cube_str);

$shape->printCubeCurses;
sleep 1;


$shape->rotE;
$shape->printCubeCurses;
sleep 1;
$shape->rotE;
$shape->printCubeCurses;
sleep 1;
$shape->rotE;
$shape->printCubeCurses;
sleep 1;
$shape->rotE;
$shape->printCubeCurses;
sleep 1;

$shape->rotW;
$shape->printCubeCurses;
sleep 1;
$shape->rotW;
$shape->printCubeCurses;
sleep 1;
$shape->rotW;
$shape->printCubeCurses;
sleep 1;
$shape->rotW;
$shape->printCubeCurses;
sleep 1;

$shape->rotN;
$shape->printCubeCurses;
sleep 1;
$shape->rotN;
$shape->printCubeCurses;
sleep 1;
$shape->rotN;
$shape->printCubeCurses;
sleep 1;
$shape->rotN;
$shape->printCubeCurses;
sleep 1;

$shape->rotS;
$shape->printCubeCurses;
sleep 1;
$shape->rotS;
$shape->printCubeCurses;
sleep 1;
$shape->rotS;
$shape->printCubeCurses;
sleep 1;
$shape->rotS;
$shape->printCubeCurses;
sleep 1;

$shape->rotU;
$shape->printCubeCurses;
sleep 1;
$shape->rotU;
$shape->printCubeCurses;
sleep 1;
$shape->rotU;
$shape->printCubeCurses;
sleep 1;
$shape->rotU;
$shape->printCubeCurses;
sleep 1;

$shape->rotD;
$shape->printCubeCurses;
sleep 1;
$shape->rotD;
$shape->printCubeCurses;
sleep 1;
$shape->rotD;
$shape->printCubeCurses;
sleep 1;
$shape->rotD;
$shape->printCubeCurses;
sleep 1;


sleep 60;

return;


$shape->printCube;

$shape->rotE;
$shape->printCube;
$shape->rotE;
$shape->printCube;
$shape->rotE;
$shape->printCube;
$shape->rotE;
$shape->printCube;

$shape->rotW;
$shape->printCube;
$shape->rotW;
$shape->printCube;
$shape->rotW;
$shape->printCube;
$shape->rotW;
$shape->printCube;

$shape->rotN;
$shape->printCube;
$shape->rotN;
$shape->printCube;
$shape->rotN;
$shape->printCube;
$shape->rotN;
$shape->printCube;

$shape->rotS;
$shape->printCube;
$shape->rotS;
$shape->printCube;
$shape->rotS;
$shape->printCube;
$shape->rotS;
$shape->printCube;

$shape->rotU;
$shape->printCube;
$shape->rotU;
$shape->printCube;
$shape->rotU;
$shape->printCube;
$shape->rotU;
$shape->printCube;

$shape->rotD;
$shape->printCube;
$shape->rotD;
$shape->printCube;
$shape->rotD;
$shape->printCube;
$shape->rotD;
$shape->printCube;

return;

#use Data::Dumper; 
#print Dumper(%cube_char_counts);


