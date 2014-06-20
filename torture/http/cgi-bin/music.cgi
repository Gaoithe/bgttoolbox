#!/usr/bin/perl

use CGI qw(:cgi-lib);
&ReadParse(*input);
print &PrintHeader;

#use CGI::Request;
#my $cgi = GetRequest;

my $formComments=<<"EINDE"
# Music - scales
# http://www.dspsrv.com/~jamesc/music.html
#         frequency  12 notes  C=256Hz, 512Hz => spacing is 12th root of 2?
# Root, 3rd and 5th freq spacing?  resonant  yes! yes!  (for major scales)  wow!
# Guitar notes, chords
# EINDE zijn nederlands voor "END". 
# Ik woon in Nederlands wanner schrif ik dit, daroom probeer ik soms Nederlands te schrijf.  
#
EINDE
;

my $modeComments=<<"EINDE"
Modes? Modes of G major follow. Just G scale starting from different notes.
Ionian mode _IS_ major key. And pattern moves up+down fretboard giving different keys.
Learn pattern from root to root.

Ionian == natural major
Aeolian == natural minor

Pentatonic => scale has 5 notes only, drop 4th and 7th
Pentatonic G: G A B D E G
Has 5 modes, 1st to 5th  related to Ionian, Dorian, Phyrgian, Mixolydian and Aeolian, just drop the not-needed notes.

G Major: G A B C D E F#
    0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
||| E |   | F#| G |   | A |   | B | C |   | D |   | E |   | F#| G |   | A |   | B |
||| B | C |   | D |   | E |   | F#| G |   | A |   | B | C |   | D |   | E |   | F#|
||| G |   | A |   | B | C |   | D |   | E |   | F#| G |   | A |   | B | C |   | D |
||| D |   | E |   | F#| G |   | A |   | B | C |   | D |   | E |   | F#| G |   | A |
||| A |   | B | C |   | D |   | E |   | F#| G |   | A |   | B | C |   | D |   | E |
||| E |   | F#| G |   | A |   | B | C |   | D |   | E |   | F#| G |   | A |   | B |
           xxxxxxxxxxxxxxx
            Ionian key G => G(3)
                   xxxxxxxxxxxxxxxxxxx
                    Dorian key G => A(5)
                               xxxxxxxxxxxxxxx
                                Phyrgian key G => B(7)
                               xxxxxxxxxxxxxxx
                                Lydian key G => C(8)
                                       xxxxxxxxxxxxxxxxxxx
                                        Mixolydian key G => D(10)
                                               xxxxxxxxxxxxxxxxxxx
                                                Aeolian key G => E(12)
           xxxxxxxxxxxxxxx                                 xxxxxxxxxxxxxxx
                                                            Locrian key G => F#(14)
EINDE
;

# needed for numeric sort
sub numericCompare { $a <=> $b; }

###########
# 
sub defineGlobals
{
# 13 divisions for an octave, 12 notes.
$chromaticScale="A  A# B  C  C# D  D# E  F  F# G  G# ";
$maxScaleNotes=12;
$chromaticScaleR="A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# A  A# B  C  C# D  D# E  F  F# G  G# ";

@noteColourTable= ( "444444", "445555", "446666", "447777", "448888", "449999", "44AAAA", "44BBBB", "44CCCC", "44DDDD", "44EEEE", "44FFFF" );
@noteColourTable2= ( "000000", "000000", "000000", "000000", "000000", "000000", "000000",
                     "1100BC", "1100EF", "220055", "2200AA", "220056", "360089", 
                     "36CCCC", "36FF55", "445510", "443333", "446666", "449999",
                     "4400BC", "4400EF", "660000", "660023", "660056", "660089",
                     "66CCCC", "66FF55", "885510", "883333", "886666", "889999",
                     "8800BC", "8800EF", "AA0000", "AA0023", "AA0056", "AA0079",
                     "AACCCC", "AAFF55", "CC5510", "CC3333", "CC6666", "CC9999",
                     "CC00BC", "CC00EF", "EE0000", "EE0023", "EE0056", "EE3399",
                     "EFFF55", "FFFFFF" );

# Major chords => 0 2 45 7 9 BC   (semi-tone spacing)
@majorSemiToneSpacing = ( 0,2,4,5,7,9,11 );
@majorR35ToneSpacing = ( 0,4,7 );
@pentatonicMajorSemiToneSpacing = ( 0,2,4,7,9 );
# Minor chords    0 23 5 78 A C
@minorSemiToneSpacing = ( 0,2,3,5,7,8,10 );
@minorR35ToneSpacing = ( 0,3,7 );
@pentatonicMinorSemiToneSpacing = ( 0,2,3,7,8 );

# interesting perl feature! look at major and minor semitonespacing,
# there was more messing with major and it got left before going all the way to the end.
# print major....  gave 3 5 7 8 10 0 2  print minor... gave 0 2 3 5 7 8 10
# so remember to sort with foreaches when order matters (e.g. printing scales).
# also sort produces 0 10 2 3 5 7 8  !! 
# so sort numericCompare ...
# nope! This was it: (after foreach $root (major....) )
# $root+=3;# going from C natural so we get all natural notes - don't ask.  #yeow! this changes @majorSemiToneSpacing!
# added 3 to all in @major...

# Guitar fretboard note offsets   e(7) B(2) G(10) D(5) A(0) E(7)   (high->low)  I think?
@guitarFretNotes = (31,26,22,17,12,7);
#@guitarFretNotes = (7,2,10,5,0,7);
$maxGuitarFrets=20;

@notes = split(/ [ ]*/,$chromaticScaleR);
}


###########
# Pass in offset of root along chromatic scale from A, e.g. A=0 C=3 G=10
# $what is major or minor or pentatonicmajor ......
# globals @majorSemiToneSpacing or @pentatonic... or @minor... are passed in
# Uses globals @notes $maxScaleNotes
sub printScale
{
local ($root, $what, *scaleToneSpacing) = @_;
printf "%-2s %s ",$notes[$root],$what;
my @scaleNote;
my $c=0;
foreach $i (sort numericCompare @scaleToneSpacing) {
  $scaleNote[$c++]=$notes[($i + $root) % $maxScaleNotes];
  printf " %-2s ",$scaleNote[$c-1];
}
printf " %-2s\n",$notes[$root];
# printf " %-2s  3rd=%-2s 5th=%-2s\n",$notes[$root],$scaleNote[2],$scaleNote[4];
}


###########
# 
# Uses globals @notes @guitarFretNotes $maxGuitarFrets $maxScaleNotes
sub printGuitarFretboard
{
foreach $note (@guitarFretNotes) {
  print "\n||";
  for ($i=0;$i<$maxGuitarFrets;$i++) {
#    print "| $notes[$note+$i%$maxScaleNotes]";
    printf "| %-2s", $notes[$note+$i%$maxScaleNotes];
  }
  print "|";
}
}


###########
# Pass in offset of root along chromatic scale from A, e.g. A=0 C=3 G=10
# globals @majorSemiToneSpacing or @pentatonic... or @minor... are passed in
# Uses globals @notes @guitarFretNotes $maxGuitarFrets $maxScaleNotes
sub printGuitarFretboardScale
{
#$root=$_[0];
#*scaleToneSpacing=@_[1];
local ($root, *scaleToneSpacing) = @_;

  foreach $note (@guitarFretNotes) {
    print "\n||";
    for ($i=0;$i<$maxGuitarFrets;$i++) {
      # if this_note     isin  this_scale
      # if ($note+$i)%$maxScaleNotes isin (@scaleToneSpacing)+$root
      undef $where;
      for ($[ .. $#scaleToneSpacing) {
        $where=$_, last if (($scaleToneSpacing[$_]+$root)%$maxScaleNotes eq ($note+$i)%$maxScaleNotes);
      }
      if (defined($where)) {
        printf "| %-2s", $notes[($note+$i)%$maxScaleNotes];
      }
      else {
        print "|   ";
      }
    }
    print "|";
  }

}



###########
# 
# Uses globals @notes @guitarFretNotes $maxGuitarFrets $maxScaleNotes
# colour by note
sub printGuitarFretboardTable
{
print "<table cellpadding=5 border=3>";
foreach $note (@guitarFretNotes) {
  print "<tr>";
  for ($i=0;$i<$maxGuitarFrets;$i++) {
    $colour=$noteColourTable[($note+$i)%$maxScaleNotes];
    printf "<td bgcolor=$colour>%-2s</td>", $notes[$note+$i%$maxScaleNotes];
  }
  print "</tr>";
}
print "</table>\n";
}


###########
# Pass in offset of note along chromatic scale from A, e.g. A=0 C=3 G=10
# Uses globals @notes @majorSemiToneSpacing @guitarFretNotes $maxGuitarFrets $maxScaleNotes
sub printGuitarFretboardScaleTable
{
$root=$_[0];
print "<table cellpadding=5 border=3>";
foreach $note (@guitarFretNotes) {
  print "<tr>";
  for ($i=0;$i<$maxGuitarFrets;$i++) {
      # if this_note     isin  this_scale
      # if ($note+$i)%$maxScaleNotes isin (@majorSemiToneSpacing)+$root
      undef $where;
      for ($[ .. $#majorSemiToneSpacing) {
        $where=$_, last if (($majorSemiToneSpacing[$_]+$root)%$maxScaleNotes eq ($note+$i)%$maxScaleNotes);
      }
      if (defined($where)) {
          if ($where == 0) {
              printf "<td bgcolor=FF0000>%-2s</td>", $notes[$note+$i%$maxScaleNotes];
          }
          elsif ($where == 2) {
              printf "<td bgcolor=00FF00>%-2s</td>", $notes[$note+$i%$maxScaleNotes];
          }
          elsif ($where == 4) {
              printf "<td bgcolor=0000FF>%-2s</td>", $notes[$note+$i%$maxScaleNotes];
          }
          else {
              printf "<td>%-2s</td>", $notes[$note+$i%$maxScaleNotes];
          }
      }
      else {
        printf "<td></td>";
      }
  }
  print "</tr>";
}
print "</table>\n";
}


###########
# Assuming low E note (7)  lower C below that (3) maps to ... 64Hz? 
# colour by offset (maps to frequency)
sub printGuitarFretboardTableFreq
{
print "<table cellpadding=5 border=3>";
print "<tr>";
for ($i=0;$i<$maxGuitarFrets;$i++) {
    printf "<th>%2d %4.1f</td>", $i, 652/($twelfthroot2**$i);
  }
print "</tr>";

foreach $note (@guitarFretNotes) {
  print "<tr>";
  for ($i=0;$i<$maxGuitarFrets;$i++) {
#    $colour=$noteColourTable[($note+$i)%$maxScaleNotes];
    $colour= ((($note+$i-7)*0x05 ) % 0x100 ) * 0x10000
            +((($note+$i)*0x14  ) % 0x100 ) * 0x100
                + (($note+$i-7)*0x33  ) % 0x100;
#    $colour=$noteColourTable2[$note+$i];
    printf "<td bgcolor=%6X>%2d %-3.1f %-2s</td>", $colour%0x1000000, $note+$i, 64*($twelfthroot2**($note+$i-3)), $notes[$note+$i%$maxScaleNotes];
  }
  print "</tr>";
}
print "</table>\n";
}


###########
# 
sub printBlankColourTable
{
print "<table>";
foreach $note (@guitarFretNotes) {
  print "<tr>";
  for ($i=0;$i<$maxGuitarFrets;$i++) {
    $colour= ((($note+$i-7)*0x05 ) % 0x100 ) * 0x10000
            +((($note+$i)*0x14  ) % 0x100 ) * 0x100
                + (($note+$i-7)*0x33  ) % 0x100;
    printf "<td bgcolor=%6X>.</td>", $colour%0x1000000;
  }
  print "</tr>";
}
print "</table>\n";
}


###########
# 
MAIN:
{
print "<html><head><title>calc-music.pl</title></head><body><pre>$formComments\n";

defineGlobals();

print "\nDefinitions\n";
print "chromaticScale $chromaticScale\n";
# print "$chromaticScaleR\n";
print "majorSemiToneSpacing @majorSemiToneSpacing\n";
print "minorSemiToneSpacing @minorSemiToneSpacing\n";
print "pentatonicMajorSemiToneSpacing @pentatonicMajorSemiToneSpacing\n";
print "pentatonicMinorSemiToneSpacing @pentatonicMinorSemiToneSpacing\n";
print "notes @notes\n";

print "notes ";
foreach $note (@notes) {
  print "$note ";
  }
print "\n";

print "notes by number ";
for ($i=0;$i<$maxScaleNotes;$i++) {
    print "$i $notes[$i] ";
  }

print "</pre><hr><pre>";

print "\n\nGuitar fretboard:  note(offset)   e(7) B(2) G(10) D(5) A(0) E(7)";
&printGuitarFretboard;

print "</pre><hr><pre>";

print "\n\nHTML Guitar fretboard:  note(offset)   e(7) B(2) G(10) D(5) A(0) E(7)\n</pre>";
&printGuitarFretboardTable();
print "<pre>";

print "\n\nHTML Guitar fretboard: C major  Red=Root Green=3rd Blue=5th\n</pre>";
&printGuitarFretboardScaleTable(3);

print "<pre>\n\nHTML Guitar fretboard: C major, note positions\n</pre>";
$root=3;
print "<table cellpadding=5 border=3>";
foreach $note (@guitarFretNotes) {
  print "<tr>";
  for ($i=0;$i<20;$i++) {
      undef $where;
      for ($[ .. $#majorSemiToneSpacing) {
        $where=$_, last if (($majorSemiToneSpacing[$_]+$root)%12 eq ($note+$i)%12);
      }
      if (defined($where)) {
        printf "<td>$where $majorSemiToneSpacing[$where]</td>";
      }
      else {
        printf "<td></td>";
      }
  }
  print "</tr>";
}
print "</table><pre>\n";
print "\n\nHTML Guitar fretboard: G major  Red=Root Green=3rd Blue=5th\n</pre>";
&printGuitarFretboardScaleTable(10);

print "<pre>\n\n$modeComments";
print "\n\nMajor scales, on the fretboard, more obfussy, you can see the different modes here!";
for($root=0;$root<$maxScaleNotes;$root++){
  print "\n$notes[$root] Major: ";
  &printGuitarFretboardScale($root,*majorSemiToneSpacing);
}

print "\n\nNatural Pentatonic scales, on the fretboard";
foreach $root (sort numericCompare @majorSemiToneSpacing) {
  $r=$root+3; #$root+=3;# going from C natural so we get all natural notes - don't ask.  #yeow! this changes @majorSemiToneSpacing!
  $r%=$maxScaleNotes; # might as well
  print "\n$notes[$r] Pentatonic Major: ";
  &printGuitarFretboardScale($r,*pentatonicMajorSemiToneSpacing);
}


print "\n\nMajor scales @majorSemiToneSpacing\n";
for($root=0;$root<$maxScaleNotes;$root++){
  &printScale($root,"Major",*majorSemiToneSpacing);
}

print "Minor scales @minorSemiToneSpacing\n";
for($root=0;$root<$maxScaleNotes;$root++){
  &printScale($root,"Minor",*minorSemiToneSpacing);
}

print "\n\nPentatonic scales\n";
for($root=0;$root<$maxScaleNotes;$root++){
  &printScale($root,"Pentatonic Major",*pentatonicMajorSemiToneSpacing);
  &printScale($root,"Pentatonic Minor",*pentatonicMinorSemiToneSpacing);
}


print "</pre><p>End of music - Begin of Frequency</p><hr><pre>";


my $guitarComments=<<"EINDE"
Notes same A 5th on 1st == 2nd open (A)
Notes same D 5th on 1st == 3rd open (D)
Notes same G 5th on 1st == 4th open (G)
Notes same B 4th on 1st == 5th open (B)
Notes same E 5th on 1st == 6th open (E)

1st string open (E) is lowest. 6th string closed at rightmost B is highest
relative octave offsets of strings eBGDAE 7 2 10 5 0 7   (low->high) EADGBe 7 0 5 10 2 7
Call A lower than lowest E 0. => we get offsets : 7 12 17 22 26 31  (x +5 +5 +5 +4 +5)
 .. and highest B offset is 50.
EINDE
;

print "$guitarComments";

#         frequency  13 notes  C=256Hz, 512Hz => spacing is 13th root of 2?

# log(ab) = log(a) + log(b)    log(a/b) = log(a) - log(b)   log(a^b) = b*log(a)
# log(x) = y  =>   e^y=x

# #%#%###!@!! 13 should be 12?????
print "\n\n 12 or 13 ???   12 too small (but right?), 13 too big, real Guitar in between?\n\n";

# x^13 = 2   =>
# log(x^12) = log(2) =>
# log(x) = log(2)/12  =>
# e^(log(2)/12) = x

# calculate e :- shouldn'tthis be easier?
$e = 2.718;
$loge = log($e);
$diff=1-$loge;
for($e=2.718281828459;$e<2.72 && $diff>0;$e+=0.00000000000001) {
  $loge=log($e);
  $diff=1-$loge;
  if ($diff<0) {
    print "\n$e $loge $diff\n";
    }
  }

$x = $e**(log(2)/12);
$two = $x**12;
$twelfthroot2=$x;

print " e = $e log($e) = $loge (should be 1)\n";
print " $x**12 = $two (should be 2)\n";

print "\n\nHTML Guitar fretboard: Fret number and length(mm)";
print "\nOffset, note and frequency(Hz) (if next lowest C off fretboard == 64Hz) (offset from next lowest A off fretboard)";
print "\nNote every 12 semitones (=frets) means 2*frequency\n";
print "</pre>";
&printGuitarFretboardTableFreq;
print "<pre>";



$guitarMaxLength = 652;
$guitarMinLength = 217;

$guitarThree[19]=217;
$guitarFour[0]=652;

print "Real guitar string length max,min = $guitarMaxLength,$guitarMinLength \n";
print "Guitar One,Two => i=0..20 soo....is that one too many? YES :(\n"; 
print "Guitar 3,4 => i=0..19 OK? YES :)\n"; 
for ($i=1;$i<20;$i++){
    $guitarThree[19-$i]=$guitarThree[20-$i]*$x;
    $guitarFour[$i]=$guitarFour[$i-1]/$x;
}
print "Guitar 3 (from 217 up) @guitarThree\n";
print "Guitar 4 (from 652 dn) @guitarFour\n";

# length difference  652-217   should be divisible in 20.
# 217 * $x2**19 = 652   pretty much YES.
$logx2 = log(652/217)/19;
$x2 = $e**(log(652/217)/19);
$delta=$x2-$x;
print "Real guitar x = $x2, not $x   oh yeah _BIG_ difference:$delta\n";
for ($i=0;$i<20;$i++){
    $guitarReal[$i]=652/($x2**$i);
}
print "Real guitar @guitarReal\n";

# Frequency should correlate though
# C = 256   *  $x**12   should be 512 ?  well, of course! That's the way I worked out $x silly.
$h=256*($x**12);
$h1=512*($x**12);
$h2=1024*($x**12);
print "\nFrequency:   256 * $x**12 = $h     512 $h1     1024 $h2\n";
# 39? silly cabbage. (cabbalo) should be 37
for ($i=0;$i<39;$i++){
    $noteFreq[$i]=128*($x**$i);
    printf "%2d %-2s %4.2f  ",$i,$notes[$i+3],$noteFreq[$i];
}
print "\nFrequency's 128 ... 256 ... 512: @noteFreq\n";

print "\n\nAnd major Roots, 3rds and 5ths?  resonance?  yep. reasonably close."; 
print "\n1st (root, 3rd, 5th, root) frequencies";
print "\n2nd Calculated resonant frequencies: Root, +rootDif/4, +rootDif/2\n";
for($root=0;$root<12;$root++){
  printf "%-2s Major", $notes[$root];
  foreach $i (@majorR35ToneSpacing,12) {
    $frequency = 256*($x**($root+$i-3));    # C is 3rd note
    printf "  %-2s %4.2f", $notes[($i + $root) % 12], $frequency;
  }
  print "\n        ";
  $rootFrequency = 256*($x**($root-3));    # C is 3rd note
  $topRootFrequency = 256*2*($x**($root-3));    # C is 3rd note
  $rootPlusHalf=$rootFrequency+($topRootFrequency-$rootFrequency)/2;
  $rootPlusQuart=$rootFrequency+($topRootFrequency-$rootFrequency)/4;
  printf "     %4.2f     %4.2f     %4.2f\n", $rootFrequency, $rootPlusQuart, $rootPlusHalf;
}

print "</pre>";
&printBlankColourTable;

print "</pre></body></html>";
}