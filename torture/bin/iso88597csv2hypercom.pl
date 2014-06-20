#!/usr/bin/perl -w

require "greek2greeklish.pl";

#  iso88597csv2hypercom.pl
#  apply charset translation to part of a csv file
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
#  $Id: iso88597csv2hypercom.pl,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

# unset LANG and LANGUAGE is only way so far of removing warning
#perl: warning: Setting locale failed.
#export LANG=EN_ie
#bash$ unset LANGUAGE
#bash$ unset LANG
#perldoc perllocale
#require 5.004;
#use POSIX qw(locale_h);
#my $old_locale = setlocale(LC_CTYPE);

#./iso88597csv2hypercom.pl 2 headoocalcrules_engr.csv >headoocalcrules_engr.csv2
#head oocalcrules_engr.csv >headoocalcrules_engr.csv

# 1186  ./iso88597csv2hypercom.pl 2 headoocalcrules_engr.csv >headoocalcrules_engr.csv2
# 1187  less headoocalcrules_engr.csv2
# 1188  hexdump -e '1/1 "%02x " "\n"' oocalcrules_engr.csv2 |sort|uniq -c
# 1189  hexdump -e '1/1 "%02x " "\n"' headoocalcrules_engr.csv2 |sort|uniq -c
# 1190  history
# 1191  ./iso88597csv2hypercom.pl 2 oocalcrules_engr.csv >oocalcrules_engr.csv2
# 1192  hexdump -e '1/1 "%02x " "\n"' oocalcrules_engr.csv2 |sort|uniq -c
# 1193  history



=head1 NAME

Convert - reads translations from a csv file, translates 2nd column to hypercom-printer charset

If you get loads of "Malformed UTF-8 character" errors/warnings then export LANG=

I have changed it such that csv files should be strictly field delimited
with " around text and , seperating.
"" and , allowed inside strings
Read usage.

e.g. 

./iso88597csv2hypercom.pl -a 2 data/extra_trans_gr1.csv >data/extra_trans_gr1_la.csv
./iso88597csv2hypercom.pl -u -a 2 data/extra_trans_gr1.csv >data/extra_trans_gr1_ua.csv
./iso88597csv2hypercom.pl -u 2 data/extra_trans_gr1.csv >data/extra_trans_gr1_u.csv
./iso88597csv2hypercom.pl 2 data/extra_trans_gr1.csv >data/extra_trans_gr1_l.csv

#-m option protects Roman/Latin chars
./iso88597csv2hypercom.pl -m -u 2 data/extra_trans_gr1_prt.csv >data/extra_trans_gr1_prtu.csv
./iso88597csv2hypercom.pl -m -u 2 data/GREEK_TRANS1_prt.csv >data/GREEK_TRANS1_prtu.csv
./iso88597csv2hypercom.pl -m -u 2 data/extra_trans_prt.csv |grep ALPHYRA
"","' %Gï¿½%@EIT_40: %Gï¿½ï¿½Ë°ï¿½%@TE TH %Gï¿½%@EIR%Gï¿½%@ K%Gï¿½%@H%Gï¿½%@H%Gï¿½%@ TH%Gï¿½%@ ALPhyrA',0Ah ","Don't translate 'Alphyra' just the rest","' FUN_40: CHANGE ALPHYRA DIAL-UP SEQUENCE',0AH "

./iso88597csv2hypercom.pl -m -u 1 data/GREEK_TRANS1_prt.csv >data/GREEK_TRANS1_prtU.csv 


./iso88597csv2hypercom.pl -l de 2 data/Amended_Alphyra_GLOSS_de.csv 
grep "[ÄÅÖÜßäåöü]" data/Amended_Alphyra_GLOSS_de.csv 
grep "schließen" data/Amended_Alphyra_GLOSS_de.csv 
grep "[^a-zA-Z0-9\"\'\,\. -?{}()\/+:;*#=]" data/Amended_Alphyra_GLOSS_de.csv

=cut

use strict;
use warnings;

my $VERSION = 0.01;

my (%filestattimes, $tc);
$tc = 0;

my $usage = <<END;
usage: $0 [<options>] <column> <trans.csv> [<another.csv> ...]
iso88597csv2hypercom $VERSION
  <column>   a number, which column in source files to translate, 
              usually 2.
  trans.csv  csv file with e.g. <english>,<greek iso-8859-7 translation>
options:
  -v         verbose print
  -m         map english chars to safe charset before doing main conversion
             (maps upper/lowercase to opposite case where that case not used 
              in printer charser)
  -a         use accented chars when converting
  -u         change all converted to uppercase chars (don\'t use lowercase)
              as the hypercom-printer-charset is incomplete
              this option may look neater 
              (not a mix of upper & lower case in words) 
  -e <col>   where is the english? (a useless option ... for now)
  -l <lang>  specify language gr - greek, sw - swedish, de - german(default gr), gl - greeklish

END

my ($verbose, $uppercase, $accent, $makesafe, $columnWithEnglish, $language);

while ($ARGV[0] =~ "^-") {
    $_ = $ARGV[0];
    if (/-v/i) {
	$verbose = shift(@ARGV);
    }
    if (/-u/i) {
	$uppercase = shift(@ARGV);
    }
    if (/-a/i) {
	$accent = shift(@ARGV);
    }
    if (/-m/i) {
	$makesafe = shift(@ARGV);
    }
    if (/-e/i) {
	shift(@ARGV);
	$columnWithEnglish = shift(@ARGV);
    }
    if (/-l/i) {
	shift(@ARGV);
	$language = shift(@ARGV);
    }

}

if ($#ARGV < 1 ) {   #read perldoc perlvar for ARGV
    die "Too few arguments.\n$usage";
}

# columns from 1 up to ... arbritary limit (sorry gods of programming) 7
my $columnToChange = shift(@ARGV);
if ($columnToChange <= 0 || $columnToChange >= 7) {
    die "I don't fancy doing column $columnToChange";
}
if (!$columnWithEnglish) {
    # try to be tellygent bout dis
    $columnWithEnglish = 0;
    if ($columnToChange == 0) {
	$columnWithEnglish = 1;
    }
}


my ($i, $j, $k, $key);
my (%sourcefile, %alllines, @lines, @slurp, @translations, $stop, $dontstop, $transfile );

$dontstop = 0;   # dontstop overrides stop  (used to decide whether to halt if there are warnings)
$stop = 0;

#setlocale(LC_CTYPE, "fr_CA.ISO8859-1");
#setlocale(LC_CTYPE, "el_GR.ISO8859-7");

if ($verbose) {
    if ($uppercase && $accent) {
	print "Not done yet. Non complete. Nog niet gedann. NICHT abgeschlossen. NO FINALIZADO. Slutförd inte. ÄÅÍ ÏËÏÊËÇÑÙÓÇ.\n";
	print "Converting keeping accents, uppercase only.\n";
	#TODO&iso885972hypercomUPYESaccent();
	;
    } elsif ($uppercase) {
	print "Converting losing accents, uppercase only.\n";
	#&iso885972hypercomUPNOaccent();
    } elsif ($accent) {
	print "Converting keeping accents, upper & lower case.\n";
	#&iso885972hypercomYESaccent();
    } else {
	print "Converting losing accents, upper & lower case.\n";
	#&iso885972hypercomNOaccent();
	#&iso885972hypercom();
    }
}


foreach $transfile(@ARGV) {

    #print "$0: reading translations from $transfile\n";

    # Open transfile and slurp it in
    open(TRANSFILE, "<$transfile") 
	or die "Can't open $transfile for reading.\n$usage";
    @slurp = <TRANSFILE>;
    close(TRANSFILE);

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
#Amended_Alphyra_GLOSS_es.csv:Line busy, wait',Línea ocupada
#Amended_Alphyra_GLOSS_sw.csv:Line busy,Linjen upptagen, wait'
#clean.csv:'Line busy, wait',Linjen upptagen
	# this just does ,s (one comma actually in quoted strings)

#james forcing ", well formed seperations
	s/(^\"[^\"]*)(\"\")/$1WESWAPPEDOUTDBLQUOTE/g;
	s/(,\"[^\"]*)(\"\")/$1WESWAPPEDOUTDBLQUOTE/g;
#	s/([\'\"][^\'\"]+),([^\'\"]+[\'\"])/$1WESWAPPEDOUTACOMMA$2/g;
	s/(\"[^\"]+),([^\"]+[\"])/$1WESWAPPEDOUTACOMMA$2/g;

	if ($verbose) { if (m/WESWAP/) { print "SWAP! $_\n"; } }

        # then we split fields up by ,
	@lines = split(/,/,$_);

	if (!$lines[$columnToChange-1]) { 
	    s/WESWAPPEDOUTACOMMA/,/g;
	    s/WESWAPPEDOUTDBLQUOTE/\"/g;
	    if ($verbose) { print "SHORTLINEB"; }
	    print; print "\n";
	    if ($verbose) { print "SHORTLINEEND\n"; }
	    next; 
	}

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
#clean.csv:'Sale+Cash','F%Gï¿½%@rs%Gï¿½%@ljn.+kontantutb.''
#clean.csv:'VALID FROM ',      'G%Gï¿½%@LLER FR%Gï¿½%@N''

#So we should  s/^'//  and  s/'\s*,/,/g  and  s/,\s*'/,/g  and  s/['\s]*$//


	# get rid of quotes, can't trust em varmints Harrr! Feed them to the fishes.
        # (Being careful about e.g. "can't" or "jusqu''au"

        # [\'\"] slashes not necessary BUT needed for emacs perl mode fontifying
	foreach(@lines) {
	    s/^\"//;
	    s/\"$//;
	    #s/^[\s\'\"]*[\'\"]//g;       
	    #s/[\'\"][\s\'\"]*,/,/g;
	    #s/,[\s\'\"]*[\'\"]/,/g;
	    #s/[\'\"\s]*$//g;
	    #s/\`/\'/g;
	    s/WESWAPPEDOUTACOMMA/,/g;
	    s/WESWAPPEDOUTDBLQUOTE/\"/g;
        }

	$_ = $lines[$columnToChange-1];


	if ($language eq "sw" || $language eq "de") {
	    # swedish and german accented chars mapped together
	    &iso88592hypercom_simple();
	} elsif ($language eq "gl") {
	    &iso885972greeklish();
	} else {
	    if ($uppercase && $accent) {
		#TODO - accents, all uppercase
		&iso885972hypercomUPYESaccent();
		#last time I did this got burned baby! so exit() don't do nothing
		print "earagh sure why would you want accents?\n";
		exit(1);
	    } elsif ($uppercase) {
		if ($makesafe) {
		    &iso885972hypercomUPNOaccent_makesafe(); 
		}
		&iso885972hypercomUPNOaccent();
	    } elsif ($accent) {
		#TODO - accent & lowercase
		&iso885972hypercomYESaccent();
	    } else {
		# about done - test and does it look okay now?
		&iso885972hypercomNOaccent();
		#&iso885972hypercom();
	    }
	}

	$lines[$columnToChange-1] = $_;

	# store translations in nice array for going through later
	$translations[$i][0] = $lines[$columnWithEnglish];
	$translations[$i++][1] = $lines[$columnToChange-1];

	#print "\"$lines[0]\",\"$lines[1]\"\n";
	my ($l,$i); $i=0; foreach $l(@lines) {
	    if($i>0) { print ","; }
	    print "\"$l\"";
	    #print "$l";
	    $i++;
	}
	print "\n";


    }

}

# restore the old locale
#setlocale(LC_CTYPE, $old_locale);

exit;


