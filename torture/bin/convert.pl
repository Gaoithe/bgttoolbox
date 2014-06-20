#!/usr/bin/perl -w

#  convert.pl
#  apply translations from csv file to source code files
#
#  Copyright (C) 2003 Doolin Technologies
#
#  This script is free software; you can redistribute it and/or modify it
#  under the same terms as Perl itself.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  $Id: convert.pl,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

# TODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTO
# TODO list

# DONE -n do nothing option

# DONE -v verbose print off/on option

# pass in source files on command line

# treat spaces in fields better, translation may miss right justify spacing
#   could we be intelligent? Hmmmm
# IF translation already done .... can we keep it as it probably has spacing better?
# Keep spacing in source files
# e.g grep "'  *.*'\s*," *.INC *.s *.S *.inc *.csv
# left justified
#Msg.inc:        GLBRSP  52,'DECLINED            ','AVVISAT             ','REFUSE              ',' RECHAZADA           ','NIET GEACCEPTEERD   ',,0,0,RSP_DECLN
# right justified
#PRTDEF.S:        LMLB        '  BASE','  BASE','  BASE','  BASE',' BASIS'
#clean.csv:'     FIXED',   '     FAST'
#clean.csv:'   VP SALE',   '   VP F%GÔøΩ%@RS%GÔøΩ%@LJNING'
# centered
#Msg.inc:        HSTRSP  54,'   EXPIRED CARD     ','  GAMMALT KORT  ','CARTE EXPIREE       ','TARJETA HA EXPIRADO  ','   VERLOPEN KAART   ',,0,0
#Amended_Alphyra_GLOSS_sw.csv:'    APPROVED    ','    GODKƒNT    ',
# wrong
#Amended_Alphyra_GLOSS_sw.csv:      '        PLEASE KEEP THIS RECEIPT        ',      'SPARA DETTA KVITTO ',
#Amended_Alphyra_GLOSS_sw.csv:           '  ISSUE ',           í°«UTFƒRDAT NR',

# DONE kindof make it faster
# slurp translation file in ?
#   I think the regexp complexity is what slows it down.
#   but it is necessarily complex
# possibly perlfaq useful on optimising (not really) 
# http://www.perldoc.com/perl5.8.0/pod/perlfaq4.html#How-can-I-split-a-%5bcharacter%5d-delimited-string-except-when-inside%0a%5bcharacter%5d--(Comma-separated-files)

# unit tests :)

# Get the actual translations done, in right format (we are just about able to do
#   this now I think

# Warn about inconsistent quoting in csv file

# DONE: we remove "s and 's  BUT they are needed inside strings sometimes e.g. 'Valide jusqu''au'

# DONE: one instance of comma in fields, taken care of 
# make sure this is okay  egrep "(busy,)|(WESWAPPEDOUTACOMMA)" *.s *.S *.inc *.INC

# DONE: made forcing all fields optional, 
# command line option -f, 
# still fills missing fields with "TODO"
# am forcing all changed fields to have 7 entries (last 2 english)
# is this okay?

# add partial string matches intelligence ?
# e.g. grep AUDIT Msg.inc *.csv
# clean.csv:'AUDIT REPORT',       'KONTROLLRAPPORT'
# Msg.inc:        MCCMSG  MSG471,'PRINT AUDIT REPORT','','PRINT','PRINT','PRINT'
# grep PRINT ../../clean.csv
# clean.csv: PRINT REPORT,SKRIV UT RAPPORT
# clean.csv: PRINT,SKRIV UT

# DONE: warn when applying translations a different size, especially longer
# than other fields  (should log these (legibly) as should request translators to
# come up with shorter versions.)

# DONE add an option -i for insert translation into existing space
# this is not so ..... easy to support in future
# e.g. what if we get SCRTXT "NEW STRING",,,,,
# does the code behave correctly ?
# I don't know.
# DONE fill in translation into existing space (script prompts user)
# why prompt user?   Because this I think could break easily.
# in Msg.inc ... there was a space for greek left in macros
# e.g. before & after
#        HSTRSP  01,' PLEASE CALL        ',' KONTAKTA           ','APPELER SVP         ',' LLAME A             ',' BELLEN             ',,R_REFERRAL,0
#        HSTRSP  01,' PLEASE CALL        ',' KONTAKTA','APPELER SVP         ',' LLAME A             ',' BELLEN             ',' –¡—¡ ¡Àœ’Ã≈  ¡À≈”‘≈','TODO',,R_REFERRAL,0
# should be (removing inserted field, so for this version German is gone)
#        HSTRSP  01,' PLEASE CALL        ',' KONTAKTA','APPELER SVP         ',' LLAME A             ',' BELLEN             ',' –¡—¡ ¡Àœ’Ã≈  ¡À≈”‘≈',R_REFERRAL,0

# what do we do with duplicate translations ?
# e.g. sort oocalcrules_engr.csv | cut -d "," -f "1" |uniq -c |grep -v "^[ ]*1"
#      sort oocalcrules_engr.csv | cut -d "," -f "1" |uniq -d
#      sort Amended_Alphyra_GLOSS_sw.csv | cut -d "," -f "1" |uniq -d
#      (for this translation run we find the same translations are duplicated
# for now each is applied (wasteful) and last one applied is the one
# could messily do uniq when opening and sucking translation file in ?
# doing nothing is also acceptable

# DONE After longer translations are inserted 32kpages need much rearranging
# add -t option to force truncation of translations
# add option so that translations should be forced to be <=max translation string length
# ... or if translation is < ?
# ... or if translation is missing?

# DONE alright like not fantastic
# use POD in here http://www.perldoc.com/perl5.6/pod/perlpod.html

# use perl built in Test 
# http://search.cpan.org/author/MSCHWERN/Test-Simple-0.47/lib/Test/More.pm
# thinking maybe not .... have simple test already

# DONE Fix -s option it keeps a blank match e.g.
#        USRMSG  MSG411,'   INSERT CHIP CARD ','SƒTT IN CHIPKORTET','INSERER CARTE','INS T CIRC INTEG','CHIPKAART INSTEKEN',' ≈…”¡√≈‘≈ ‘«Õ  ¡—‘¡ CHIP','TODO','TODO','TODO','TODO','TODO'
#        GLBMSGA MSG412,'AUTHENTICATING CARD','VERIFIERAR KORT','AUTH. CARTE','AUTENTICANDO TARJETA','KAART GEAUTHENTICRD',' ¡—‘¡ ≈–… ’—ŸÕ≈‘¡…','TODO','TODO','TODO','TODO','TODO'
#        USRMSG  MSG413,'CARD AUTHENTICATED','KORTET VERIFIERAT','CARTE AUTH.','TARJETA AUTENTICADA','KAART GEAUTHENTICRD','≈–… ’—Ÿ”«  ¡—‘¡”','TODO','TODO','TODO','TODO','TODO'
#        GLBMSGA MSG414,'WAITING FOR ACCEPT','VƒNTAR P≈ GODKƒNNANDE','ATTENTE AUTH.','ESPERANDO ACEPTACION','WACHTEN OP ACCEPTATIE','¡Õ¡Ã≈Õ≈‘≈ √…¡ ','TODO','TODO','TODO','TODO','TODO'
#        USRMSG  MSG415,'INSERT CHIP CARD    ',' ','INS CARTE','INS T CIRC INTEG','CHIPKAART INSTEKEN',' ≈…”¡√≈‘≈ ‘«Õ ','TODO','TODO','TODO','TODO','TODO'
#
# SEMI redundant match ?   change to SƒTT IN CHIPKORTET
#
#File:line data/Amended_Alphyra_GLOSS_sw.csv:47 source: ./Msg.inc:688 
#        USRMSG  MSG415,'INSERT CHIP CARD    ',' ','INS CARTE','INS T CIRC INTEG','CHIPKAART INSTEKEN',' ≈…”¡√≈‘≈ ‘«Õ ','TODO','TODO','TODO','TODO','TODO'
#SEMI redundant match ?   change to SƒTT IN CHIPKORTET

# DONE make report say IF
#  [1] change was applied?
#  [2] change was applied truncated (-t)
#  [3] redundant match made, change not applied (-s)


# TODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTO



=head1 NAME

Convert - reads translations from a csv file, applies to source files

=head1 SYNOPSIS

  # run the script and see the "usage" message
  ./convert.pl

  # run the script and apply changes to column 2 (swedish)
  ./convert.pl 2 sourcelist.pl swedish.csv

  # run the script and apply changes to column 6 (greek) 
  # -t truncate translations  
  # (bad for reading them but source should be okay to compile afterwards)
  ./convert.pl -t 6 sourcelist.pl greek.csv

  # run the script but do nothing (-n) and be verbose (-v)
  # reports on every line that would be changed
  ./convert.pl -n -v 2 sourcelist.pl swedish.csv

  # run the script and apply changes to column 6 (greek) 
  # -f fill to 7 fields (e.g. German field 7)
  # fields will be filled anyway
  # before:          SCRMSG	MSG522,'SHIFT','SKIFT','SHIFT','TURNO'
  # after (no -f):   SCRMSG	MSG522,'SHIFT','SKIFT','SHIFT','TURNO','TODO','Greeksk'
  # after (-f 7):    SCRMSG	MSG522,'SHIFT','SKIFT','SHIFT','TURNO','TODO','Greeksk','TODO'
  ./convert.pl -f 7 6 sourcelist.pl greek.csv

=head1 DESCRIPTION

This script helps to apply translations to source files.

=head2 Parse translation file

Translations are sucked in and parsed.
Warnings are printed if inconsistent quoting or field seperation is detected.
The script will go no further and prompt user to manually fix lines in 
translation file if there are errors.

=head2 Apply translations to source files

Each source file is backed up, then read in line by line.
If a translation matches it is applied to the line in the specified column.

=head1 FILES

=over 

=item   e.g. swedish.csv

'SHIFT','SKIFT',
Items, Artiklar,
   '  BASE',       'GRUND',

=item   e.g. code.s

SCRMSG	MSG522,'SHIFT','SKIFT','SHIFT','TURNO'
STDHDR  'MULTIPLE PINS','FLERA PINKODER','PLUSIEURS CODES','VARIOS PIN','MEER DAN 1 PIN'
SCRTXT  'Please Select Option','Vlj alternativ','Slectionner une option','Seleccione una op','Optie selecteren svp'
LMLB		'DATE: ','  DATUM:','DATE: ','FECHA:','DATUM: '
DB      '  TIME: ',FLD_FL,FLD_SYSTM,FT_MIL,5
GLBRSP  00,'APPROVAL      authno','GODK[NT       authno','AUTHORISATION authno','APROBACION     authno','GOEDGEKEURD   authno',,R_APPROVED,0,RSP_APP


=head1 HOW TO USE

You should probably use all the following options.
Yes, it is silly they are off by default BUT ...

[1]start by doing nothing with verbose on
  ./convert.pl -n -v -i -t 6 sourcelist.pl oocalcrules_engr.csv 

[2]run it and record errors/warnings in translation file
  ./convert.pl -n -i -t 6 sourcelist.pl oocalcrules_engr.csv >warnings.txt 2>&1

[3]fix errors in translation file

[4]then run it (using truncate and insert options), record the warnings
  ./convert.pl -i -t 6 sourcelist.pl oocalcrules_engr.csv >>warnings.txt 2>&1

[5]Send warnings file to translators to fix strings too long etc...



=cut


use strict;
use warnings;

my $VERSION = 0.01;

use Time::localtime;
use Term::ANSIColor;

#use Text::ParseWords;
#use Text::CSV;
#use Text::CSV_XS;

use Unicode::Map;
my $Map = new Unicode::Map({ ID => "ISO-8859-1" });
# do a little jig like this to get correct length of strings in iso-8859-*
# does not matter that Map create or from_unicode specify ISO-8859-*
# we just need to persuade perl extended chars are to be encoded in one byte
# various ways of doing this with locales BUT can't get them to work beautifully
#my $swedish = "F÷RSƒLJNING";
#print "\nSwedish $swedish, length is ", length($swedish), ", should be 11\n";
#my $uniswedish = $Map -> to_unicode ($swedish);
#print "\nSwedish unicode $uniswedish, length is ", length($uniswedish), ", should be 11\n";
#my $isoswedish = $Map -> from_unicode ("ISO-8859-7",$uniswedish);
#print "\nSwedish unicode $isoswedish, length is ", length($isoswedish), ", is 11\n";
my $doajig; # was going to be an option, now bug removed otherwise
#leave undefined so we don't do a jig.
# ACTUALLY 
# did find a specific problem
#File:line data/Amended_Alphyra_GLOSS_sw.csv:7
#Translation is too long (13 chars). Should be between 10 and 10 chars.
#english:     '      SALE'
#translation: 'F÷RSƒLJNING'
#             '0000000010'



my $starttime = gmtime();
print "Started: $starttime\n";
my (%filestattimes, $tc);
$tc = 0;

my $usage = <<END;
usage: $0 [-n] [-v] [-t] [-T <tolerance>] [-c <csvfile>] [-R <report>] [-s <how>] [-i] [-f <fill>] <column> <sourcefilelist> <trans.csv> [<another.csv> ...]
convert.pl $VERSION
mandatory:
  column     a number, which column in source files to translate
             column: 1 English, 2 Swedish, 3 French, 4 Spanish, 5 Dutch, 6 Greek 7 German
  sourcefilelist  perl definition of hash of sourcefiles to operate on
  trans.csv  csv file with <english>,<translation>
options:
  -n         load translation file and print warnings but don\'t make translations
  -v         verbose print
  -t         if translations are longer than the longest existing translation
             on that line then truncate them
  -T         tolerate translations < existing min - 5 (NOT DONE YET!)
  -i         if there is a blank field for the translation then insert it there
  -f <fill>  will make all translated lines have <fill> entries
  -c <file>  write a parsed csv file (for debug)
  -R <rep>   write a readable report on translation string problems (sorted to match csv files strings)
  -g         grep for english before any translation is done. 
             this is a simpler match than the match done later during translation application
             (this helps find strings that should be matched when they
              are not in what looks like a list of translation strings)
  -s <how>   how to handle semi-redundant matches  
             semi-redundant match e.g. SEMI redundant match ? F÷RHANDSG change to F÷RHANDSGODK.
             may be there for a good reason - string already truncated
             write these to legible report too?
             <how> (NOT DONE YET!) can be one of (p|y|n) (prompt|no) ask user, apply them, don\'t apply them 
             for now <how> is not used
             if -s is not specified semi-redundant matches will be translated/substituted with new string
  -PrintMap <lang> map translations for hypercom printer before applying them 
                   (e.g. accented chars and non-roman/latin alphabet chars are non-standard on hypercom printer)
                   <lang>  =  de or sw

END


my $checkBlankFields = 1;
my $filledBlankFieldsCount = 0;
my $translationsCount = 0;
my $truncationCount = 0;
my $truncationWarnCount = 0;
my $justificationCount = 0;
my $redundantCount = 0;
my $redundantSemiCount = 0;

my ($grepBeforeAction, $noAction, $verbose, $truncate, 
    $tolerance, $insertIfBlankFieldExists, $columnsToFill, 
    $readableReport, $parsedCSVFile,
    $dontSubstituteSemiRedundantMatches, $printmaplang
    );

# how many language fields we have, careful, this could break assembly language macros
$columnsToFill = 6;
$columnsToFill = 5;
$columnsToFill = 10; # no, not 10!
$columnsToFill = 9; # yep, 9 means 10.  we should define them!!
#             column: 1 English, 2 Swedish, 3 French, 4 Spanish, 5 Dutch, 6 Greek 7 German
#                     may not be correct (2,3,4) ???
#                     also 8=Portugese, 9=Italian, Cypriot = Greek I think.

if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}

if ($ARGV[0]) {
while ($ARGV[0] =~ "^-") {

    # TODO use this format instead ?
    #$_ = $ARGV[0];
    #if (/-v/i) {

    if ($ARGV[0] =~ "-n") {
	$noAction = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-f") {
	shift(@ARGV);
	$columnsToFill = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-v") {
	$verbose = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-t") {
	$truncate = shift(@ARGV);
    }
    if ($ARGV[0] =~ "-T") {
	shift(@ARGV);
	$tolerance = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-s") {
	shift(@ARGV);
	$dontSubstituteSemiRedundantMatches = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-R") {
	shift(@ARGV);
	$readableReport = shift(@ARGV);
    }
    if ($ARGV[0] =~ "-c") {
	shift(@ARGV);
	$parsedCSVFile = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-i") {
	$insertIfBlankFieldExists = shift(@ARGV);
	$checkBlankFields = 2; # 2 means do the insertion, 0 means don't, 1 means ask

    }

    if ($ARGV[0] =~ "-g") {
	shift(@ARGV);
	$grepBeforeAction = shift(@ARGV);
    }

    if ($ARGV[0] =~ "-PrintMap") {
	shift(@ARGV);
	$printmaplang = shift(@ARGV);
	die "PrintMap doesn't work yet";
    }
}}

if ($#ARGV < 2 ) {   #read perldoc perlvar for ARGV
    die "$usage";
}

my $columnToChange = shift(@ARGV);
if ($columnToChange <= 1 || $columnToChange >= 8) {
    die "I don't fancy doing column $columnToChange";
}

my $sourceFileList = shift(@ARGV);

my @mycol  = ( "red", "green", "yellow", "green", "yellow", "green", "yellow", "green", "yellow" );
# This script forces all translation lines to have 6 entries
#grep "\'.*\'\s*,\s*\'.*\'" *.INC *.S *.s *.inc >OriginalTranslationsFromSource

my ($i, $j, $k, $key);
my (%alllines, @lines, @slurp, @translations, $stop, $dontstop, $transfile );

$dontstop = 0;   # dontstop overrides stop  (used to decide whether to halt if there are warnings)
$stop = 0;

# Define my sourcefiles
#$sourcefile{"Msg"}{"name"} = "./Msg.inc";

#require "sourcefiles.pl";
my $allsourcefiles;
our %sourcefile;
require "$sourceFileList";
foreach $key (keys(%sourcefile)) {
    $allsourcefiles .= $sourcefile{$key} . " ";
}

if ($parsedCSVFile) {
    open(PARSEDCSVFILE, ">$parsedCSVFile") 
	or die "Can't open $parsedCSVFile for writing.\n";
}
close(PARSEDCSVFILE);

foreach $transfile(@ARGV) {

    print "$0: reading translations from $transfile\n";

    # Open transfile and slurp it in
    open(TRANSFILE, "<$transfile") 
	or die "Can't open $transfile for reading.\n$usage";
    @slurp = <TRANSFILE>;
    close(TRANSFILE);

    if ($parsedCSVFile) {
	open(PARSEDCSVFILE, ">>$parsedCSVFile") 
	    or die "Can't open $parsedCSVFile for writing.\n";
    }

    # parse transfile, tidy up and print concerned messages if there is cause for concern
    $i = 0; my $linenumber = 0;
    foreach (@slurp) {

	$linenumber++;

	# skip blank lines or lines with just ,s and whitespace
	if (m/^[,\s]*$/) { next; }

	# We replace 2 or more ,s in a row with just one
        #  deleting columns in spreadsheet, then saving 
        #  often results in saving of deleted column as blank entry ,,
        #  rather than making people do something like:
        #   mv bleh.csv bleh.csv.tmc; sed "s/,+/,/g" bleh.csv.tmc >bleh.csv.
	s/,+/,/g;

        # replace , and/or white space mix at end of line with nothing
	s/[,\s]*$//;


        # we replace comma inside well quoted translation string because ....
        # there is one instance of it, ...
        #    actually there are more in other csv files.
#Scrn.inc:        SCRTXT  'Line busy, wait','Line busy, wait','Ligne occupee, patientez','Linea ocupada','Lijn is bezet'
#Amended_Alphyra_GLOSS_de.csv:Line busy, wait',Leitung belegt
#Amended_Alphyra_GLOSS_es.csv:Line busy, wait',LÌnea ocupada
#Amended_Alphyra_GLOSS_sw.csv:Line busy,Linjen upptagen, wait'
#clean.csv:'Line busy, wait',Linjen upptagen
	# this just does ,s (one comma actually in quoted strings)
	s/([\'\"][^\'\"]+),([^\'\"]+[\'\"])/$1WESWAPPEDOUTACOMMA$2/g;

	if ($verbose) { if (m/WESWAP/) { print "SWAP! $_\n"; } }

        # then we split fields up by ,
	@lines = split(/,/,$_);


# read http://www.perldoc.com/perl5.8.0/pod/perlfaq4.html#How-can-I-split-a-%5bcharacter%5d-delimited-string-except-when-inside%0a%5bcharacter%5d--(Comma-separated-files)
#	@lines = ();
#	push(@lines, $+) while $_ =~ m{
#	    "([^\"\'\\]*(?:\\.[^\"\'\\]*)*)",?  # groups the phrase inside the quotes
#		| ([^,]+),?
#		| ,
#	    }gx;
#	push(@lines, undef) if substr($_,-1,1) eq ',';  
# james - couldn't get it to work with ' quotes? Am I missing something simple?


# nope
#	@lines = quotewords(",", 0, $_);  


#grep "'[^,]*'[^,]*'" *.csv 
# => lots of stupid quoting ... e.g.:
#clean.csv:'Row ','Rad''
#clean.csv:'No stored Trans.  ','Inga lagrade trans.'  '
#clean.csv:'Sale+Cash','F%GÔøΩ%@rs%GÔøΩ%@ljn.+kontantutb.''
#clean.csv:'VALID FROM ',      'G%GÔøΩ%@LLER FR%GÔøΩ%@N''

#So we should  s/^'//  and  s/'\s*,/,/g  and  s/,\s*'/,/g  and  s/['\s]*$//


	# get rid of quotes, can't trust em varmints Harrr! Feed them to the fishes.
        # (Being careful about e.g. "can't" or "jusqu''au"

        # [\'\"] slashes not necessary BUT needed for emacs perl mode fontifying
	foreach($lines[0], $lines[1]) {
	    s/\`/\'/g;
	    s/\'/\'/g;  # this quote is > 127 - iso-8859-n extended - be careful
	    s/^[\s\'\"]*[\'\"]//g;       
	    s/[\'\"][\s\'\"]*,/,/g;
	    s/,[\s\'\"]*[\'\"]/,/g;
	    s/[\'\"\s]*$//g;
	    s/WESWAPPEDOUTACOMMA/,/g;
        }

	# can\'t trust left/right padding/justification in translations anyway
        # so remove here
	# e.g.    '      SALE',"    '      –ŸÀ«”«'"
	$lines[1] =~ s/^[ \'\"]+//;
	$lines[1] =~ s/[ \'\"]+$//;


        # do a little jig like this to get correct length of strings in iso-8859-*
        # does not matter that Map create or from_unicode specify ISO-8859-*
        # we just need to persuade perl extended chars are to be encoded in one byte
        # various ways of doing this with locales BUT can't get them to work beautifully
	# ACTUALLY 1) so long as file saved as iso-8859-whatever
        #             when perl reads it in string lengths even with extended chars are okay
        #             can possibly have problems getting data from other sources but okay for now.
        #          2) from_unicode behaves differently from previous test
	if ($doajig) {
	    print "\nb4 unicode iso jig iso $lines[1], length is ", length($lines[1]), "\n";
	    my $unitext = $Map -> to_unicode ($lines[1]);
	    $lines[1] = $Map -> from_unicode ($unitext);
	    #$lines[1] = $Map -> from_unicode ("ISO-8859-1",$unitext);
	    print "unicode $unitext, length is ", length($unitext), "\n";
	    print "iso $lines[1], length is ", length($lines[1]), "\n";
	}

	# special chars might screw things up a bit in the regex
	#$lines[0] =~ s/\*/\\\*/g;
	# string will be used as regexp search string
	# so ? + ( ) other chars must be slashified
	for($lines[0]) {
	    s/\`/\\\`/g;
	    s/\'/\\\'/g;
	    s/\"/\\\"/g;
	    s/\?/\\\?/g;
	    s/\+/\\\+/g;
	    s/\*/\\\*/g;
	    s/\(/\\\(/g;
	    s/\)/\\\)/g;
	    s/\[/\\\[/g;
	    s/\]/\\\]/g;
	    s/\^/\\\^/g;
	    s/\$/\\\$/g;
	    s/\-/\\\-/g;
	}

	# store translations in nice array for going through later
	# I'm sure there's a ... better? ... way. @translations[$i++] = @lines;
	$translations[$i][3] = "$transfile:$linenumber";
	$translations[$i][0] = $lines[0];
	$translations[$i++][1] = $lines[1];

	if ($parsedCSVFile) {
	    print PARSEDCSVFILE "\"",$lines[0],"\",\"",$lines[1],"\"\n";
	}

	if ($grepBeforeAction) {
	    # grep -H for file name, -n for line number
	    my $result = `grep -Hn \"[\\\"\\\'] *$lines[0] *[\\\"\\\']\" $allsourcefiles`;	    
	    if ($result) {
		#print "GREP \"$lines[0]\" GREP $result";
		print "GREP$result";
	    }
	}


	my $warn = 0;
	my $fileline = "$transfile:$linenumber ";
	my $warningmsg = "Warning. $transfile:$linenumber ";
	my $errormsg = color("bold"). color("red"). "Error! $transfile:$linenumber ". color("reset");

	# quick checks, missing translations or extreme differences in lengths 
	my $englishlen = length($lines[0]);
	my $foreignishlen = length($lines[1]);

	if ($lines[2]) {
	    $warn = 1;
	    $stop++; # this is an unforgivable offence
	    warn "$errormsg Too many ,s (or bad quoting) in line in csv file?\n";
	    if ($verbose) {
		warn "    There should be only two fields.\n";
		my $l;
		foreach $l(@lines) {
		    chomp $l;
		    print "    FIELD: $l\n";
		}
	    }
	}
	if ($englishlen <= 0) {
	    $warn = 1;
	    $stop++; # this is an unforgivable fence
	    warn "$errormsg I get worried when I see blank lines (after parsing).";
	}
	if ($englishlen > 0 && $foreignishlen <= 0) {
	    $warn = 1;
	    $stop++; # this is an unforgivernable defence
	    warn "$errormsg Missing translation?\n";
	    if ($verbose) {
		printf("    ENGLISH:%02d \"%-25s\" MACALLITS:%02d \"%s\"\n",
		       $englishlen,$lines[0],$foreignishlen,$lines[1]);
	    }
	}
	if ($englishlen > 2*$foreignishlen) {
	    $warn = 1;
	    #$stop = 1; # this is forgivable
	    warn "$warningmsg translation is succinct? (i.e. more than 50% shorter)\n";
	    if ($verbose) {
		printf("    ENGLISH:%02d \"%-25s\" MACALLITS:%02d \"%s\"\n",
		       $englishlen,$lines[0],$foreignishlen,$lines[1]);
	    }
	}
	if ($warn == 1) {
	    print "\n";
	}
    }

    close(PARSEDCSVFILE);

    if ($dontstop == 0 && $stop > 0) {
	die "$0: $stop unforgivable errors.\nPlease to be fixing errors in $transfile manually before continuing.\n";
    }

    if ($readableReport) {
	open(RREPFILE, ">$readableReport") 
	    or die "Can't open $readableReport for writing.\n";
    }

    print "$0: Applying translations to sourcefiles\n";

    my ($line, $file, @sourceslurp, $tran1 );
    # Open sourcefiles here, 
    #  back them up,
    #  and slurp into a datastructure,
    #  we'll modify the data then write out the whole thing to the file
    system ("mkdir -p backup/");
    foreach $key (keys(%sourcefile)) {
        $filestattimes{$key} = gmtime();
	$file = $sourcefile{$key};
	my $filelinenumber = 0;
	print "$0: Translating $file $key\n";
	if ($noAction) {
	    print "     Changes will NOT be written to disk ($noAction option)\n";
	}

	open(SOURCEFILE, "<$file") or die "can't open source file $file for slurping";
        @sourceslurp = <SOURCEFILE>;
	close SOURCEFILE;

	if (!$noAction) {

	    if ($verbose) { system ("ls -al $file"); }
	    if (! -e "backup/$file") { 
		# if a backup already exists don't overwrite as it is probably original backup
		if ($verbose) { print "making backup\n"; }
		system ("cp $file backup/$file");
	    }

	    open(SOURCEFILE, ">$file") or die "can't open source file $file for overwriting";

	}

	# go through each row of file
        foreach $line(@sourceslurp) {

	    chomp($line);
	    my $linetowrite = $line;
	    my $dontSubstitute;
	    #undef $dontSubstitute;
	    if ($dontSubstitute) { 
		print "James has incomplete understanding of perl\n";
		warn "James has incomplete understanding of perl\n";
	    }

	    $filelinenumber ++;

	    # a little optimisation - makes a big difference
	    # if line doesn't look like a list of translations then NEXT!
	    if ($line !~ /[\'\"].+[\'\"]\s*,\s*[\'\"].*[\'\"]/) {
		if (!$noAction) {
		    print SOURCEFILE "$linetowrite\n";
		}
		next;
	    }

	    # go through each translation and apply it to line if found
	    foreach $tran1(@translations) {

                #print "Tran ${$tran1}[0] TO ${$tran1}[1]\n";

                if (${$tran1}[2]) {
		    print "BORK ${$tran1}[2]\n"; 
		    die "Indicates bug I haven't thought enough about"; 
		}

# if we require at least .*'english','something','something','something',
# this ensures we don't replace simple words everywhere
# e.g. grep 'CASH' *.s
# but get in trouble in a couple of places where there are only two translations

# if we require at least .*'english','something...
# we can be sure it is at least matching our translation string in quotes

# then later we can replace columns if they exist or add them if not

# On this particular regexp:
# ^.*['"]      1st quoted item in list (otherwise similar
#              words to english in other text match erroniously
#           \s*${$tran1}[0]\s*['"] choosing to drop space around english
#                                  there are advantages ... and disadvantages
#                                 \s*\,\s*['"] followed at least by something 
#                                              that looks like another string in a , list  

		#if ($line =~ m/[\'\"]\s*${$tran1}[0]\s*[\'\"]\s*\,.*\,.*\,.*\,/)  {
		#if ($line =~ m/^[^,]*['"]\s*${$tran1}[0]\s*['"]\s*\,\s*['"]/)  {
		if ($line =~ m/^[^\'\"]*[\'\"]\s*${$tran1}[0]\s*[\'\"]\s*\,\s*[\'\"]/)  {

		    if ($verbose) {
			print "\nMATCH ";
			print colored("${$tran1}[0]", "bold");
			print " changed to ";
			print colored("${$tran1}[1]", "bold");
			print "\n$line\n";
		    }

		    $_ = $line;

                    my (@moregoo, $quote); 

# careful that the brain goo doesn't get mixed with the regexp goo 
#   when parsing regexps with brain
# much of following few regexps is kindof the same as above only delimiting fields with ()
		    my ($startgoo, $quotespace, $matchgoo, $spacequote, $restofgoo) = 
			m/(^[^\'\"]*)([\'\"]\s*)(${$tran1}[0])(\s*[\'\"])\s*\,(.*)/;

                    my $english = "$quotespace$matchgoo$spacequote";
                   
                    $quote = $quotespace; 
                    $quote =~ s/[^\"\']//g; 

                    # line by line match each next quoted string field (followed by comma)
                    $i = 0;
                    my $rest = $restofgoo;
                    while ($rest) {
                        $_ = $rest;
			s/([^,\s])\'\'([^,\s])/$1SWAPOUT2QUOTE$2/g;   # please forgive me ,'AUJOURD''HUI',
                        ($moregoo[$i], $rest) =
                            m/\s*[\'\"]([^\'\"]*)[\'\"]\s*\,(.*)/;
			if ($rest) { $restofgoo = $rest; $i++; }
		    }

		    #print "DEBUG $restofgoo DEBUG\n";

                    # last match not followed by a comma
		    $_ = $restofgoo;
		    ($moregoo[$i], $rest) =
			m/\s*[\'\"]([^\'\"]*)[\'\"](.*)/;
		    if (!$moregoo[$i]) { 
			# this is possible with extra elements (unquoted at end of list)
			$i--; 
			$rest = "," . $restofgoo;
		    }

                    # here check lengths of strings, should we constrain the translation?
		    my ($maxlen, $minlen);
		    $maxlen = $minlen = length($english) - 2;
                    for($j=0;$j<=$i;$j++) {
			
			$moregoo[$j] =~ s/SWAPOUT2QUOTE/\'\'/g; # if I act (a little) insane ,'AUJOURD''HUI',

			# don't match on TODO
			# as we often put 'TODO' for undone languages at end 
			# would make minlen often 4
			if ($moregoo[$j] eq "TODO") { next; }

			my $len = length($moregoo[$j]);
			if ($len > $maxlen) { $maxlen = $len; } 
			if ($len < $minlen) { $minlen = $len; } 
                    }		    

                    # fill in blank translations (up to $columnsToFill)  
                    # fill in recognisable bad string "UOHOH" "DEADBEEF" ?
                    # or fill in english (already that way for some entries)
                    # we must fill with something (though in practice this happens with
                    # commented out translations which look old & unused & deprecated & unloved 
                    for($j=$i+1;$j<$columnsToFill;$j++) {
			#$moregoo[$j] = $english;
			#$moregoo[$j] =~ s/[\'\"]//g;			
			$moregoo[$j] = "TODO"; 

			# check are we possibly filling in something which 
			# already has blank entry ,, waiting for it?
			if ($rest =~ "^,," && $checkBlankFields > 0) {
			    my $notthisOne = 0;
			    # ask if we have not done so already
			    if ($checkBlankFields == 1) {
				my $fieldwarningmsg = color("bold"). color("green");
				$fieldwarningmsg .= "Warning. $file:$filelinenumber". color("reset");
				print "Blank field following on line (i.e. ,,),";
				print " should we fill translation in there?\n";
				print "Original: $line\n";
				print "Select: (y)es or (n)o or (N)one or (A)ll: \n";
				#fflush STDIN;
				read STDIN,$i,1;
				my $endlinehopefully;
				read STDIN,$endlinehopefully,1;
				for ($i) {
				    if (/n/) { $notthisOne = 1; }
				    if (/N/) { $checkBlankFields = 0; }
				    if (/y/i) { $checkBlankFields = 1; }
				    if (/a/i) { $checkBlankFields = 2; }
				}
			    }

			    # yes ?
			    if ($checkBlankFields > 0 && $notthisOne == 0) {
				$rest =~ s/^,,/,/;
				$filledBlankFieldsCount++;
			    }

			}

		    }

		    # we know what we want to translate now
		    # just some last things to do
		    my $trans = ${$tran1}[1];
		    my $lenoftrans = length(${$tran1}[1]);

		    # if english is padded with spaces adjust to fit as best we can
                    # if check faster betsy!
		    if ($lenoftrans < $minlen) { for($english) {
			if (/^$quote\s+/) { 
			    $trans = sprintf("%*s",$minlen,$trans);
			    $justificationCount++;
			    if ($verbose) { print "\nRight Justify adjust $quote$trans$quote\n"; }
			}
			elsif (/\s+${quote}$/) {
			    $trans = sprintf("%-*s",$minlen,$trans);
			    $justificationCount++;
			    if ($verbose) { print "\nLeft Justify adjust $quote$trans}$quote\n"; }
			}
			
		    } }

		    # check length of translations
		    #if (length($moregoo[$columnToChange-2]) != length(${$tran1}[1])) {}
		    $lenoftrans = length($trans);

		    my $rrwarningmsg = "";

		    # shorter is good (mostly) if ($lenoftrans > $maxlen || $lenoftrans < $minlen) {
		    if ($lenoftrans > $maxlen) {
			my $lenwarningmsg = color("bold"). color("green");
			$lenwarningmsg .= " and $file:$filelinenumber". color("reset");
			$lenwarningmsg .= "\n   Translation length outside existing range.";
			$lenwarningmsg .= "\n   trans str len ($lenoftrans) maybe should be >$minlen and <$maxlen";
			$lenwarningmsg .= "\n   MATCH $english CHANGE TO $quote$trans$quote";
			warn "$lenwarningmsg\n";
			$truncationWarnCount++;
			if ($readableReport) {
			    $rrwarningmsg = "File:line ${$tran1}[3]";
			    $rrwarningmsg .= "ENDLINETranslation is too long ($lenoftrans chars). Should be between ";
			    $rrwarningmsg .= "$minlen and $maxlen chars.";
			    $rrwarningmsg .= "ENDLINEenglish:     $english";
			    $rrwarningmsg .= "ENDLINEtranslation: $quote$trans${quote}";
			    my $temp = sprintf("%0*s",$maxlen,$maxlen);
			    $rrwarningmsg .= "ENDLINE             $quote$temp${quote}ENDLINE";
			    # don't print it here, 
			    # we want it together with summary of whether substitution was applied or not.
			    #print RREPFILE $rrwarningmsg;
			}

		    } 



		    # if what we replace exactly matches translation already done previously and it is redundant
		    # it is nice to know how much we need this
		    if ($moregoo[$columnToChange-2] eq $trans) {
			$redundantCount++;
			if ($verbose) {
			    print "Redundant match ? ";
			    print colored("$moregoo[$columnToChange-2]\n", "bold");
			}
		    } else {
			
			for ($moregoo[$columnToChange-2]) {
			    if (! m/^ *$/) { # as long as string isn't blank

				# if replace string is substring of existing translation possibly 
				# there is a reason (string already previously shortened)
				for ($trans) {
				    $moregoo[$columnToChange-2] =~ s/\*/\\\*/g;
				    if (m/$moregoo[$columnToChange-2]/) {
					$redundantSemiCount++;
					if ($dontSubstituteSemiRedundantMatches) { 
					    $dontSubstitute="option to keep semi-redundant matches is on"; 
					}
					# this could be an issue - could stop & prompt user to do the tellygent thing
					# think about it over coffee.
					my $semiredundantwarning = "SEMI redundant match ? " .
					    "$moregoo[$columnToChange-2]" .
					    " matches $trans";
					warn "\n".$semiredundantwarning."\n";
					if ($readableReport) {
					    my $rrsemiwarningmsg = "File:line ${$tran1}[3] source: $file:$filelinenumber ";
					    $rrsemiwarningmsg .= "ENDLINE${line}";
					    $rrsemiwarningmsg .= "ENDLINE${semiredundantwarning}ENDLINE";
					    print RREPFILE $rrsemiwarningmsg;
					}
				    }
				}
			    }
			}
		    }

		    my $subinfo;
		    if (!$dontSubstitute) {
			# substitute our translation
			$subinfo = "translation made $moregoo[$columnToChange-2] to ${trans}ENDLINE\n";
			$moregoo[$columnToChange-2] = $trans;
			$translationsCount++;
			# but if we must truncate, then truncate
			if ($truncate) { 
			    if ($lenoftrans > $maxlen) {
				$moregoo[$columnToChange-2] = substr($trans,0,$maxlen);
				$subinfo = "Translsation truncated from $lenoftrans to $maxlen chars ==$moregoo[$columnToChange-2]==ENDLINE\n";
				warn $subinfo;
				$truncationCount++;
			    }
			}
		    } else {
			warn "Not substituting $trans for $moregoo[$columnToChange-2] $dontSubstitute.\n";
			$subinfo = "Not substituting $dontSubstitute.ENDLINE\n";
		    }

		    # a summary of what actually happened
		    if ($readableReport) {
			print RREPFILE $rrwarningmsg;
			print RREPFILE $subinfo;
		    }

		    if ($verbose) {
			# print (prettily) matches
			print "$startgoo";
			print color("bold"), color($mycol[0]), "$english", color("reset");

			for($j=0;$j<$columnsToFill;$j++) {
			    print ",$quote", color($mycol[($j+1)%9]).
				"$moregoo[$j]", color("reset"), "$quote";
			}

			print "$rest\n";
		    }

		    $linetowrite = "$startgoo$english";
                    for($j=0;$j<$columnsToFill;$j++) {
			$linetowrite .= ",$quote$moregoo[$j]$quote";
                    }
                    $linetowrite .= "$rest";

# don't need to look for more translations when we have already matched one
		    last;   
		    
		}
	    }

	    if (!$noAction) {
		# write original line or translation found
		print SOURCEFILE "$linetowrite\n";
	    }
	}
	
	if (!$noAction) {
	    # translations done on that file
	    close SOURCEFILE;
	}

	#print "Finished one file, Hit Return to continue\n";
	#read STDIN,$i,1;

    }

    if ($readableReport) {
	close(RREPFILE);
    }

}

my $endtime = gmtime();

print "\nstatistics:\nBlank fields filled in: $filledBlankFieldsCount\n";
print "Translations: $translationsCount\n";
print "truncations: $truncationCount ($truncationWarnCount warnings)\n";
print "justifications: $justificationCount\n";
print "redundant translations: $redundantCount ($redundantSemiCount semi-redundant maybe)\n";

if ($readableReport) {
    my $result = `mv $readableReport /tmp/$readableReport`;
    my $endline = "\n";
    open(RREPINFILE, "sort -n -t: -k3 /tmp/$readableReport|") 
	or die "Can't copy/sort/open /tmp/$readableReport for reading.\n";
    open(RREPOUTFILE, ">$readableReport") 
	or die "Can't open $readableReport for writing.\n";
    while (<RREPINFILE>) { 
	s/ENDLINE/$endline/g;
	print RREPOUTFILE;
    }
    close(RREPOUTFILE);
    close(RREPINFILE);
}


print "Started: $starttime\n";
foreach $key (keys(%filestattimes)) {
    print "File $key: $filestattimes{$key}\n"; 
}
print "Finished: $endtime\n";

exit;


