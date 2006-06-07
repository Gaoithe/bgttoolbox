#!/usr/bin/perl

#  greek2greeklish.pl
#  provide some charset translation functions
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
#  $Id: greek2greeklish.pl,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

##
# This has evolved into a general accent translator - biggest translations are for greek chars.
##

#  TODO

#sub greeklish2iso88597() {
#sub iso885972greeklish() {
#sub iso885972hypercomNOaccent() {
# check are there duplicate translations that overwrite earlier translation
# add makesafe

#sub iso885972hypercomUPNOaccent_makesafe() {
#sub iso885972hypercomUPNOaccent() {
# up no accent is finished

#sub iso885972hypercomYESaccent() {
# check are there duplicate translations that overwrite earlier translation
# add makesafe

#sub iso885972hypercomUPYESaccent() {
# nothing is implemented, no translation is done



# e.g. usage
#require "greek2greeklish.pl";
#while (<>) {
#    chop;
#    &iso885972hypercom();
#    print "$_\n";
#}

# MAIN USE

# convert from iso-8859-7 to hypercom printer charset chars for application to source code
# convert from iso-8859-7 to hypercom printer charset AND convert that to 7bit mapping


    #&iso885972greeklish();

    #tr/\xc1\xcb\xda\xd3/ALIS/;
    # e.g. \b10 binary \o33 octal \c123 decimal \xdb hex

    # doesn't work very well ?  E -> Sigma ?  is this a different charset altogether ?
    # is emacs file format ... wrong?
    #tr/ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÓÔÕÖ×ØÙ¿¢¼¸ºáâãäåæçèéêëìíîïðñóòôõö÷øùþÜÝÞúßüýûþ/A/;
    #tr/ERRORÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÓÔÕÖ×ØÙ¿¢¼¸ºáâãäåæçèéêëìíîïðñóòôõö÷øùþÜÝÞúßüýûþ/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/;
    #tr/ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÓÔÕÖ×ØÙ¿¢¼¸ºáâãäåæçèéêëìíîïðñóòôõö÷øùþÜÝÞúßüýûþ/ABGDEZH8IKLMNJOPRSTYFXCWWAOEIabgdezh8iklmnjoprsstyfxqwwaehiioyyw/;


#originally originally hacked from Christos Ricudis ricudis at manitari.paiko.gr
#Fri Nov 30 22:36:01 EET 2001
# ... but nothing left of that
#http://lists.hellug.gr/pipermail/linux-greek-users/2001NOvember/037108.html

#also http://www.dbnet.ece.ntua.gr/~george/hacks/

#also http://www.soi.city.ac.uk/~livantes/Research.html

# http://www.faqs.org/rfcs/rfc1947.html
#RFC 1947 - Greek Character Encoding for Electronic Mail Messages

#http://www.ibiblio.org/koine/greek/lessons/alphabet.html
#http://www.w3.org/TR/MathML2/003.html unicode greek letters with english description
#http://czyborra.com/charsets/iso8859.html#ISO-8859-7


sub greeklish2iso88597() {
    tr/AA/\xB6\xC1/;
    tr/aa/\xDC\xE1/;
    tr/EE/\xB8\xC5/;
    tr/ee/\xDD\xE5/;
    tr/HH/\xB9\xC7/;
    tr/hh/\xDE\xE7/;
    tr/IIII/\xBA\xC0\xC9\xDA/;
    tr/iii/\xDF\xE9\xFA/;

    tr/O/\xCF/;
    tr/oo/\xEF\xFC/;
    tr/S/\xD3/;

    # james can't make up his mind :(
    #tr/ss/\xF2\xF3/;    # f2 f3 sigma, final sigma
    tr/s/\xF2/;    # f2 f3 sigma, final sigma
    s/\xF2$/\xF3/;    # f2 f3 sigma, final sigma
    s/\xF2\w/\xF3/;    # f2 f3 sigma, final sigma   # NOT TESTED!!!!! \w or \s ? perldoc -? geh

    tr/YYY/\xBE\xD5\xDB/;
    tr/yyyy/\xE0\xF5\xFB\xFD/;

    tr/B/\xC2/;
    tr/b/\xE2/;
    tr/C/\xD8/;
    tr/c/\xF8/;
    tr/D/\xC4/;
    tr/d/\xE4/;
    tr/F/\xD6/;
    tr/f/\xF6/;
    tr/G/\xC3/;
    tr/g/\xE3/;
    tr/J/\xCE/;
    tr/j/\xEE/;
    tr/K/\xCA/;
    tr/k/\xEA/;
    tr/L/\xCB/;
    tr/l/\xEB/;
    tr/M/\xCC/;
    tr/m/\xEC/;
    tr/N/\xCD/;
    tr/n/\xED/;

    tr/P/\xD0/;
    tr/p/\xF0/;
    tr/R/\xD1/;
    tr/r/\xF1/;
    tr/T/\xD4/;
    tr/t/\xF4/;
    tr/X/\xD7/;
    tr/x/\xF7/;
    tr/Z/\xC6/;
    tr/z/\xE6/;
    tr/Q/\xC8/;
    tr/q/\xE8/;
    tr/WW/\xBF\xD9/;
    tr/ww/\xF9\xFE/;

    tr/U/\xC8/;
    tr/u/\xE8/;
    tr/VV/\xBF\xD9/;
    tr/vv/\xF9\xFE/;
}

sub iso885972greeklish() {
    # 52 trs
    tr/\xB6\xC1/AA/;
    tr/\xDC\xE1/aa/;
    tr/\xB8\xC5/EE/;
    tr/\xDD\xE5/ee/;
    tr/\xB9\xC7/HH/;
    tr/\xDE\xE7/hh/;
    tr/\xBA\xC0\xC9\xDA/IIII/;
    tr/\xDF\xE9\xFA/iii/;
    tr/\xCF/O/;
    tr/\xEF\xFC/oo/;
    tr/\xD3/S/;
    tr/\xF2\xF3/ss/;
    tr/\xBE\xD5\xDB/YYY/;
    tr/\xE0\xF5\xFB\xFD/yyyy/;
    tr/\xC2/B/;
    tr/\xE2/b/;
    tr/\xD8/C/;
    tr/\xF8/c/;
    tr/\xC4/D/;
    tr/\xE4/d/;
    tr/\xD6/F/;
    tr/\xF6/f/;
    tr/\xC3/G/;
    tr/\xE3/g/;
    tr/\xCE/J/;
    tr/\xEE/j/;
    tr/\xCA/K/;
    tr/\xEA/k/;
    tr/\xCB/L/;
    tr/\xEB/l/;
    tr/\xCC/M/;
    tr/\xEC/m/;
    tr/\xCD/N/;
    tr/\xED/n/;
    tr/\xD0/P/;
    tr/\xF0/p/;
    tr/\xD1/R/;
    tr/\xF1/r/;
    tr/\xD4/T/;
    tr/\xF4/t/;
    tr/\xD7/X/;
    tr/\xF7/x/;
    tr/\xC6/Z/;
    tr/\xE6/z/;
    tr/\xC8/Q/;
    tr/\xE8/q/;
    tr/\xBF\xD9/WW/;
    tr/\xF9\xFE/ww/;
    tr/\xC8/U/;
    tr/\xE8/u/;
    tr/\xBF\xD9/VV/;
    tr/\xF9\xFE/vv/;
}


# see function from_iso88597_to_godawful_greek($text) {
# and it's myriad comments
# from testgreek.php
#
sub iso885972hypercomNOaccent() {
    tr/\xa1\xa2//; #silly funny quotes have found

    tr/\xB6/\xB0/; #"A"
    tr/\xC1/\xB0/; #"A"
    tr/\xDC/a/; #"A" or use "a"?
    tr/\xE1/a/; #"A" or use "a"?
    tr/\xC2/\xB1/; #"B"
    tr/\xE2/b/; #"B" or use "b"?
#   tr/\xD8/\xDB/; #"C"
#   tr/\xF8/\xDB/; #"C" or use "c"?
    #tr/\xC4/\xC4/; #"D" no mapping needed (same char)
    tr/\xE4/d/; #"D" or use "d" ?
    tr/\xB8/E/;
    tr/\xC5/E/;
    tr/\xDD/e/;
    tr/\xE5/e/;
#   tr/\xD6/\xDA/; #"F"
    tr/\xF6/\xBD/; #"F"# use chr(0xBD), "f" lowercase phi
    #tr/\xC3/\xC3/; #"G" no mapping needed (same char)
    tr/\xE3/g/; #"G" or use "g" ?
    tr/\xB9/H/;
    tr/\xC7/H/;
    tr/\xDE/h/;
    tr/\xE7/h/;
    tr/\xBA/I/;
    tr/\xC0/I/;
    tr/\xC9/I/;
    tr/\xDA/I/;
    tr/\xDF/i/;
    tr/\xE9/i/;
    tr/\xFA/i/;
#tr/\xCE/\xCE/; #"J" no mapping needed (same char)
    tr/\xEE/j/; #"J"

    tr/\xCA/K/;
    tr/\xEA/k/;
#tr/\xCB/\xCB/; #"L" no mapping needed (same char)
    tr/\xEB/l/; #"L"
    tr/\xCC/M/;
#   tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xCD/N/;
    tr/\xED/n/;
    tr/\xCF/O/;
    tr/\xEF/o/;
    tr/\xFC/o/;
#tr/\xD0/\xD0/; #"P" no mapping needed (same char)
    tr/\xF0/p/; #"P" or use "p" ?
#   tr/\xD1/\xE8/; #"R"
#   tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho
#   tr/\xD3/\xD5/; #"S"
#   tr/\xF2/s/; #"S" or use "s" ?
#   tr/\xF3/s/; #"S" or use "s" ?
    tr/\xD4/T/;
    tr/\xF4/t/;
#tr/\xC8/\xC8/; #"U"#or Q no mapping needed (same char)
    tr/\xE8/q/; #"U"#or Q or use "q" ?
    tr/\xBF/\xD9/; #"V"#or W omega
    #tr/\xD9/\xD9/; #"V"#or W omega  no mapping needed (same char)
    tr/\xF9/w/; #"V"#or W omega  or use "w" ? 
    tr/\xFE/w/; #"V"#or W omega  or use "w" ?
    tr/\xD7/X/;
    tr/\xF7/x/;
    tr/\xBE/Y/;
    tr/\xD5/Y/;
    tr/\xDB/Y/;
    tr/\xE0/y/;
    tr/\xF5/y/;
    tr/\xFB/y/;
    tr/\xFD/y/;
    tr/\xC6/Z/;
    tr/\xE6/z/;

# these translations must be done last
# these translations would be overwritten if done before some of other translations above
    tr/\xD8/\xDB/; #"C"
    tr/\xF8/c/; #"C" or use "c"?
    tr/\xD6/\xDA/; #"F"
    tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xD1/\xE8/; #"R"
    tr/\xF1/r/; #"R"# use chr(0xE7), "r" lowercase rho
    tr/\xD3/\xD5/; #"S"
    tr/\xF2/s/; #"S" or use "s" ?
    tr/\xF3/s/; #"S" or use "s" ?  # final sigma

}


# when both E and e are used can't make safe. Do we need to?
# no we don't need to silly!!!
# only need to make safe when sending from mops over 7bit
# once hypercom printer charset chars in code they are sent
# directly to printer

# there is a different proprietary mapping used of hypercom 
# printer charset to 7 bits. These are stored in database.
# That mapping is reversed on terminal after data received over 
# 7bit connection ... so in that case chars >7bit would be munged.

# make Roman/Latin chars safe from printer translation 
# (so at terminal side translation -> printer 8 bit charset
#  will not mess up parts of english words)
# E.g. FOOBAR  made safe is  FooBAr (and comes out on printer that way)
#      without making safe   F<omicron><omicron>BA<rho>
sub iso885972hypercomUPNOaccent_makesafe() {
    tr/E/e/;
    tr/G/g/;
    tr/H/h/;
    tr/I/i/;
    tr/K/k/;
    tr/M/m/;
    tr/N/n/;
    tr/O/o/;
    tr/T/t/;
    tr/W/w/;
    tr/X/x/;
    tr/Y/y/;
    tr/Z/z/;
    tr/R/r/;
}

# see function from_iso88597_to_godawful_greek($text) {
# and it's myriad comments
# from testgreek.php
#
#<shobha> the chars that are different are h,w,e,k,i
#<shobha> great!
#<shobha> and E7,E6,E8,F5,D9 & DA
#
#<jamesc> those chars are all the post-translation ones ?
#<jamesc> e.g.     tr/\xEC/\xE6/; #"M"#? lowercase mu
#<shobha> yes - that's right
#<shobha> its what i see in the file
#<jamesc> In that case I'm translating lowercase mu to ... a lowercase mu?
#<jamesc> I should just use uppercase everywhere?
#<shobha> yes - do that
#<jamesc> okay .... I think I should be able to do that quickly :)
#* jamesc hopes
#<shobha> thanks
#* jamesc busies himself
#
#egrep -i "(E7|E6|E8|F5|D9|DA)/;" iso885972hypercom.txt
#egrep "(h|w|e|k|i)/;" iso885972hypercom.txt
#
#    tr/\xDD/e/;
#    tr/\xE5/e/;
#    tr/\xDE/h/;
#    tr/\xE7/h/;
#    tr/\xDF/i/;
#    tr/\xE9/i/;
#    tr/\xFA/i/;
#    tr/\xEA/k/;
#    tr/\xF9/w/; #"V"#or W omega  or use "w" ? 
#    tr/\xFE/w/; #"V"#or W omega  or use "w" ?
#
#    tr/\xBF/\xD9/; #"V"#or W omega   just use W like others
#    tr/\xD6/\xDA/; #"F"
#    tr/\xEC/\xE6/; #"M"#? lowercase mu
#    tr/\xD1/\xE8/; #"R"
#    tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho

# didn't specify g|n|o|t|x|y|z but probably should make
# sure use only uppercase there too?

sub iso885972hypercomUPNOaccent() {
    tr/\xa1\xa2//; #silly funny quotes have found

    tr/\xB6/\xB0/; #"A"
    tr/\xC1/\xB0/; #"A"
    tr/\xDC/\xB0/; #"A" or use "a"?
    tr/\xE1/\xB0/; #"A" or use "a"?
    tr/\xC2/\xB1/; #"B"
    tr/\xE2/\xB1/; #"B" or use "b"?
#   tr/\xD8/\xDB/; #"C"
#   tr/\xF8/\xDB/; #"C" or use "c"?
    #tr/\xC4/\xC4/; #"D" no mapping needed (same char)
    tr/\xE4/\xC4/; #"D" or use "d" ?
    tr/\xB8/E/;
    tr/\xC5/E/;
    tr/\xDD/E/;
    tr/\xE5/E/;
#   tr/\xD6/\xDA/; #"F"
    tr/\xF6/\xBD/; #"F"# use chr(0xBD), "f" lowercase phi
    #tr/\xC3/\xC3/; #"G" no mapping needed (same char)
    tr/\xE3/G/; #"G" or use "g" ?
    tr/\xB9/H/;
    tr/\xC7/H/;
    tr/\xDE/H/;
    tr/\xE7/H/;
    tr/\xBA/I/;
    tr/\xC0/I/;
    tr/\xC9/I/;
    tr/\xDA/I/;
    tr/\xDF/I/;
    tr/\xE9/I/;
    tr/\xFA/I/;
#tr/\xCE/\xCE/; #"J" no mapping needed (same char)
    tr/\xEE/\xCE/; #"J"

    tr/\xCA/K/;
    tr/\xEA/K/;
#tr/\xCB/\xCB/; #"L" no mapping needed (same char)
    tr/\xEB/\xCB/; #"L"
    tr/\xCC/M/;
#   tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xCD/N/;
    tr/\xED/N/;
    tr/\xCF/O/;
    tr/\xEF/O/;
    tr/\xFC/O/;
#tr/\xD0/\xD0/; #"P" no mapping needed (same char)
    tr/\xF0/\xD0/; #"P" or use "p" ?
#   tr/\xD1/\xE8/; #"R"
#   tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho
#   tr/\xD3/\xD5/; #"S"
#   tr/\xF2/s/; #"S" or use "s" ?
#   tr/\xF3/s/; #"S" or use "s" ?
    tr/\xD4/T/;
    tr/\xF4/T/;
#tr/\xC8/\xC8/; #"U"#or Q no mapping needed (same char)
    tr/\xE8/\xC8/; #"U"#or Q or use "q" ?
    tr/\xBF/W/; #"V"#or W omega
    tr/\xD9/W/; #"V"#or W omega  no mapping needed (same char)
    tr/\xF9/W/; #"V"#or W omega  or use "w" ? 
    tr/\xFE/W/; #"V"#or W omega  or use "w" ?
    tr/\xD7/X/;
    tr/\xF7/X/;
    tr/\xBE/Y/;
    tr/\xD5/Y/;
    tr/\xDB/Y/;
    tr/\xE0/Y/;
    tr/\xF5/Y/;
    tr/\xFB/Y/;
    tr/\xFD/Y/;
    tr/\xC6/Z/;
    tr/\xE6/Z/;

# these translations must be done last
# these translations would be overwritten if done before some of other translations above
    tr/\xD8/\xDB/; #"C"
    tr/\xF8/\xDB/; #"C" or use "c"?

    #tr/\xD6/\xDA/; #"F"
    tr/\xD6/\xBD/; #"F"

    #tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xEC/M/; #"M"#? lowercase mu

    #tr/\xD1/\xE8/; #"R"
    #tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho
    tr/\xD1/R/; #"R"
    tr/\xF1/R/; #"R"# use chr(0xE7), "r" lowercase rho

    tr/\xD3/\xD5/; #"S"
    tr/\xF2/\xD5/; #"S" or use "s" ?
    tr/\xF3/\xD5/; #"S" or use "s" ?   # Final sigma

}


#### TODO
# only problem is are these intended for greek use and the charset 
# still falls short of full charset needed, so, Hmmmm.
# e.g. A with accents B5 B6 B7
#      E with accents B8 D2 D3 D4
#      I with accents D6 D7 D8 DF
#      O with accents E0 E2 E3 E4 E5
#      U with accents E9 EA EB EE
#
# http://czyborra.com/charsets/iso8859.html#ISO-8859-7
# http://www.faqs.org/docs/docbook/html/iso-grk2.html
# accents are:
#  tonos  a tic, kindof like small fada over letter
#  dialytika  two dots over letter
#  tonos and dialytika combined
#
# etondial 88 map use just etonos or edial or e ? (as in epsilon e like ?)
# itondial 8c map c0 (circumflex-like but small foo)
# otondial 93 map 
# utondial 96 map 
# atonos 84 map dc
# etonos 89 map dd
# otonos A2 map fc 
# htonos xx map de
# wtonos xx map fe
# itonos 8b map df
# utonos 81 map fb
# utonos 9a map fd
# ytonos 98 map be uppercase y tonos ? (there is no lwr in iso, no upr in hyp)
# adial A0 map 
# edial 82 map dd
# idial A1 map fa
# odial 94 map xx
# odial 99 map xx  (REPEATED)
# udial A3 map fb
# ydial ec map 

# Atonos b5 map b6
# Atonos 8f map xx a with dot over, not A with tonos
# Etonos 90 map b8
# Htonos b9 map b9 ? if H is b4 (H is eta) map b9, c7
# Itonos d8 map ba
# Otonos xx map bc
# Ytonos xx map be
# Wtonos xx map bf
# Atondial b6 map 
# Itondial d7 map 
# Etondial d2 map 
# Otondial e2 map  (?REPEATED)
# Utondial ea map e0
# Adial 8e map 
# Edial d3 map xx
# Idial d6 map da
# Odial e0 map xx
# Udial e9 map fb(lower)
# Ydial ed map db


# AND will/does this generate more duplicates ?

# iso-8859-7 b5 is a tonos & dialytika combined, no letter
# iso-8859-7 b4 is a tonos, no letter
# omega & upsilon (Y-like) & eta (H) have accents too

# check a1 and a2 ? in iso -> not mapped ? i-fada and o-fada
# those babies are funny quotes .... get rid of them ?

sub iso885972hypercomYESaccent() {
    tr/\xa1//; #silly funny quotes have found
    tr/\xa2//; #silly funny quotes have found

    tr/\xC1/\xB0/; #"A"
    tr/\xE1/a/; #"A" or use "a"?
    tr/\xC2/\xB1/; #"B"
    tr/\xE2/b/; #"B" or use "b"?
    tr/\xF8/c/; #"C" or use "c"?
    tr/\xE4/d/; #"D" or use "d" ?
    tr/\xC5/E/;
    tr/\xE5/e/;
    tr/\xF6/\xBD/; #"F"# use chr(0xBD), "f" lowercase phi
    tr/\xE3/g/; #"G" or use "g" ?
    tr/\xC7/H/;
    tr/\xDE/h/;
    tr/\xE7/h/;
    tr/\xC9/I/;
    tr/\xE9/i/;
    tr/\xEE/j/; #"J"

    tr/\xCA/K/;
    tr/\xEA/k/;
    tr/\xEB/l/; #"L"
    tr/\xCC/M/;
    tr/\xCD/N/;
    tr/\xED/n/;
    tr/\xCF/O/;
    tr/\xEF/o/;
    tr/\xF0/p/; #"P" or use "p" ?
    tr/\xE8/q/; #"U"#or Q or use "q" ?
    tr/\xF1/r/; #"R"# use chr(0xE7), "r" lowercase rho
    tr/\xF2/s/; #"S" or use "s" ?
    tr/\xF3/s/; #"S" or use "s" ? Final sigma
    tr/\xD4/T/;
    tr/\xF4/t/;
    tr/\xBF/\xD9/; #"V"#or W omega
    tr/\xF9/w/; #"V"#or W omega  or use "w" ? 
    tr/\xFE/w/; #"V"#or W omega  or use "w" ?
    tr/\xD7/X/;
    tr/\xF7/x/;
    tr/\xD5/Y/;
    tr/\xF5/y/;
    tr/\xC6/Z/;
    tr/\xE6/z/;

# accented chars, we have neither full set in 
#  iso-8859-7 nor hypercom-printer-charset
#  dupl problems will mean moving stuff around?
    tr/\xc0/\x8c/;
    tr/\xdc/\x84/;
    tr/\xdd/\x89/;
    tr/\xfc/\xA2/;
    tr/\xdf/\x8b/;
    tr/\xfb/\x81/;
    tr/\xfd/\x9a/;
    tr/\xbe/\x98/;

    tr/\xdd/\x82/;
    tr/\xfa/\xA1/;
    tr/\xfb/\xA3/;   # duplicate \xfb  (triple actually)

    tr/\xb6/\xb5/;
    tr/\xb8/\x90/;

# these translations must be done last
# these translations would be overwritten if done before some of other translations above
    tr/\xdb/\xed/;   # before d8->db but after       tr/\xED/n/;
    tr/\xD8/\xDB/; #"C"
    tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xD1/\xE8/; #"R"
    tr/\xD3/\xD5/; #"S"
    tr/\xba/\xd8/;

    tr/\xe0/\xea/;
    tr/\xfb/\xe9/;

#    tr/\xD6/\xDA/; #"F"
#    tr/\xda/\xd6/;   # :(  nuts!  awkward!
    tr/\xD6/\x80/;  # use \x80 temporarily hoping \x80 never used
    tr/\xda/\xd6/;
    tr/\x80/\xDA/; #"F"

}


sub iso885972hypercomUPYESaccent() {
    tr/\xa1\xa2//; #silly funny quotes have found

    tr/\xB6/\xB0/; #"A"
    tr/\xC1/\xB0/; #"A"
    tr/\xDC/\xB0/; #"A" or use "a"?
    tr/\xE1/\xB0/; #"A" or use "a"?
    tr/\xC2/\xB1/; #"B"
    tr/\xE2/\xB1/; #"B" or use "b"?
#   tr/\xD8/\xDB/; #"C"
#   tr/\xF8/\xDB/; #"C" or use "c"?
    #tr/\xC4/\xC4/; #"D" no mapping needed (same char)
    tr/\xE4/\xC4/; #"D" or use "d" ?
    tr/\xB8/E/;
    tr/\xC5/E/;
    tr/\xDD/E/;
    tr/\xE5/E/;
#   tr/\xD6/\xDA/; #"F"
    tr/\xF6/\xBD/; #"F"# use chr(0xBD), "f" lowercase phi
    #tr/\xC3/\xC3/; #"G" no mapping needed (same char)
    tr/\xE3/G/; #"G" or use "g" ?
    tr/\xB9/H/;
    tr/\xC7/H/;
    tr/\xDE/H/;
    tr/\xE7/H/;
    tr/\xBA/I/;
    tr/\xC0/I/;
    tr/\xC9/I/;
    tr/\xDA/I/;
    tr/\xDF/I/;
    tr/\xE9/I/;
    tr/\xFA/I/;
#tr/\xCE/\xCE/; #"J" no mapping needed (same char)
    tr/\xEE/\xCE/; #"J"

    tr/\xCA/K/;
    tr/\xEA/K/;
#tr/\xCB/\xCB/; #"L" no mapping needed (same char)
    tr/\xEB/\xCB/; #"L"
    tr/\xCC/M/;
#   tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xCD/N/;
    tr/\xED/N/;
    tr/\xCF/O/;
    tr/\xEF/O/;
    tr/\xFC/O/;
#tr/\xD0/\xD0/; #"P" no mapping needed (same char)
    tr/\xF0/\xD0/; #"P" or use "p" ?
#   tr/\xD1/\xE8/; #"R"
#   tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho
#   tr/\xD3/\xD5/; #"S"
#   tr/\xF2/s/; #"S" or use "s" ?
#   tr/\xF3/s/; #"S" or use "s" ?
    tr/\xD4/T/;
    tr/\xF4/T/;
#tr/\xC8/\xC8/; #"U"#or Q no mapping needed (same char)
    tr/\xE8/\xC8/; #"U"#or Q or use "q" ?
    tr/\xBF/W/; #"V"#or W omega
    tr/\xD9/W/; #"V"#or W omega  no mapping needed (same char)
    tr/\xF9/W/; #"V"#or W omega  or use "w" ? 
    tr/\xFE/W/; #"V"#or W omega  or use "w" ?
    tr/\xD7/X/;
    tr/\xF7/X/;
    tr/\xBE/Y/;
    tr/\xD5/Y/;
    tr/\xDB/Y/;
    tr/\xE0/Y/;
    tr/\xF5/Y/;
    tr/\xFB/Y/;
    tr/\xFD/Y/;
    tr/\xC6/Z/;
    tr/\xE6/Z/;

# these translations must be done last
# these translations would be overwritten if done before some of other translations above
    tr/\xD8/\xDB/; #"C"
    tr/\xF8/\xDB/; #"C" or use "c"?

    #tr/\xD6/\xDA/; #"F"
    tr/\xD6/\xBD/; #"F"

    #tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xEC/M/; #"M"#? lowercase mu

    #tr/\xD1/\xE8/; #"R"
    #tr/\xF1/\xE7/; #"R"# use chr(0xE7), "r" lowercase rho
    tr/\xD1/R/; #"R"
    tr/\xF1/R/; #"R"# use chr(0xE7), "r" lowercase rho

    tr/\xD3/\xD5/; #"S"
    tr/\xF2/\xD5/; #"S" or use "s" ?
    tr/\xF3/\xD5/; #"S" or use "s" ? #final sigma



# accented chars, we have neither full set in 
#  iso-8859-7 nor hypercom-printer-charset
#  dupl problems will mean moving stuff around?
    tr/\xc0/\x8c/;
    tr/\xdc/\x84/;
    tr/\xdd/\x89/;
    tr/\xfc/\xA2/;
    tr/\xdf/\x8b/;
    tr/\xfb/\x81/;
    tr/\xfd/\x9a/;
    tr/\xbe/\x98/;

    tr/\xdd/\x82/;
    tr/\xfa/\xA1/;
    tr/\xfb/\xA3/;   # duplicate \xfb  (triple actually)

    tr/\xb6/\xb5/;
    tr/\xb8/\x90/;

# these translations must be done last
# these translations would be overwritten if done before some of other translations above
    tr/\xdb/\xed/;   # before d8->db but after       tr/\xED/n/;
    tr/\xD8/\xDB/; #"C"
    tr/\xEC/\xE6/; #"M"#? lowercase mu
    tr/\xD1/\xE8/; #"R"
    tr/\xD3/\xD5/; #"S"
    tr/\xba/\xd8/;

    tr/\xe0/\xea/;
    tr/\xfb/\xe9/;

#    tr/\xD6/\xDA/; #"F"
#    tr/\xda/\xd6/;   # :(  nuts!  awkward!
    tr/\xD6/\x80/;  # use \x80 temporarily hoping \x80 never used
    tr/\xda/\xd6/;
    tr/\x80/\xDA/; #"F"

}



#e.g.
#(fset 'james-pullup-trlist-twolines
#   [?\C-s ?t ?r ?/ ?\C-m ?\C-  C-right ?\C-w up up ?\C-e ?\C-y ?\C-s ?t ?r ?/ ?/ ?\C-m ?\C-  C-right ?\C-w up ?\C-e ?\C-y ?\C-a down ?\C-k ?\C-k up up])
#start with cursor on # of #first
#first
#second
#    tr/\xC7/H/;

#\xC1\xE1\xC2\xE2\xE4\xC5\xE5\xF6\xE3\xC7\xDE\xE7\xC9\xE9\xEE\xCA\xEA\xEB\xCC\xCD\xED\xCF\xEF\xF0\xD4\xF4\xE8\xBF\xF9\xFE\xD7\xF7\xD5\xF5\xC6\xE6\xD8\xF8\xD6\xEC\xD1\xF1\xD3\xF2\xF3\xc0\xdc\xdd\xfc\xdf\xfb\xfd\xbe\xdd\xfa\xfb\xb6\xb8\xb9\xba\xe0\xda\xfb\xdb
#\xB0a\xB1bdEe\xBDgHhhIijKklMNnOopTtq\xD9wwXxYyZz\xDBc\xDA\xE6\xE8r\xD5ss\x8c\x84\x89\xA2\x8b\x81\x9a\x98\x82\xA1\xA3\xb5\x90\xb9\xd8\xea\xd6\xe9\xed

# duplicates db da e6 e8 d5 b9->b9 d8 ea d6 e9 ed


# A question for you - for Prtdef.s are the accented chars in swedish
# in need of mapping?  Or are they okay?  There are only a few chars.
# Chars are aoAO - they have a diaeresis (two dots) over them or a
# can also have a circle (ring) over it.
#
# Greek hypercom printer charset has those chars but not in same place
# as iso-8859-1.
# Is greek hypercom printer charset same as normal printer charset?
#    i.e. is there only one?
# Hypercom printer greek charset has
#
#a-diaeresis 0x84
#a-ring      0x86
#A-diaeresis 0x8e
#o-diaeresis 0x94
#O-diaeresis 0x99
#A-ring      0xb6
#
#from http://www.gar.no/home/mats/8859-1.htm
#iso-8859-1
#A-diaeresis 0xc4
#A-ring      0xc5
#O-diaeresis 0xd6
#a-diaeresis 0xe4
#a-ring      0xe5
#o-diaeresis 0xf6

sub swedishiso885972hypercom() {
    tr/\xc4/\x8e/; #A-diaeresis 
    tr/\xc5/\xb6/; #A-ring      
    tr/\xd6/\x99/; #O-diaeresis 
    tr/\xe4/\x84/; #a-diaeresis 
    tr/\xe5/\x86/; #a-ring      
    tr/\xf6/\x94/; #o-diaeresis 
}

sub swedishhypercom2iso88597() {
    tr/\x8e/\xc4/; #A-diaeresis 
    tr/\xb6/\xc5/; #A-ring      
    tr/\x99/\xd6/; #O-diaeresis 
    tr/\x84/\xe4/; #a-diaeresis 
    tr/\x86/\xe5/; #a-ring      
    tr/\x94/\xf6/; #o-diaeresis 
}

# http://german.about.com/library/weekly/aa092898.htm
# ß -- aka "eszet" ("s-z") or "scharfes s" ("sharp s") or "double s" or "ess-tet"
# http://www.cas.muohio.edu/~greal/lrnrsc/faq/faq.html
# What's with that big ß looking letter?
# This character is called an ess-tet and stands for a double s. ( ß = ss) 
# The new German Language Reform eliminates the ß in most cases except those following a long vowel.
# examples: heißen (to be named or called),  but dass (that)

sub germaniso885972hypercom() {
    tr/\xc4/\x8e/; #A-umlaucht
    tr/\xd6/\x99/; #O-umlaucht
    tr/\xdc/\x9a/; #U-umlaucht
    tr/\xe4/\x84/; #a-umlaucht
    tr/\xf6/\x94/; #o-umlaucht
    tr/\xfc/\x81/; #u-umlaucht
    tr/\xdf/ss/; #ss a little bird told me they got rid of this char?
}

sub germanhypercom2iso88597() {
    tr/\x8e/\xc4/; #A-umlaucht
    tr/\x99/\xd6/; #O-umlaucht
    tr/\x9a/\xdc/; #U-umlaucht
    tr/\x84/\xe4/; #a-umlaucht
    tr/\x94/\xf6/; #o-umlaucht
    tr/\x81/\xfc/; #u-umlaucht
}

########### more generic
our %hypercomPrintMap = ( 
			  "sw" => {
   			      #hyper =>   [ "\x8e\xb6\x99\x84\x86\x94", ],
			      #iso8859 => [ "\xc4\xc5\xd6\xe4\xe5\xf6", ],
   			      #iso8859 => hyper
   			      "\xc4\xc5\xd6\xe4\xe5\xf6" => "\x8e\xb6\x99\x84\x86\x94",
			      desc =>     "AAOaao",
			      ldesc => [ "A-diaeresis ", "A-ring      ", "O-diaeresis ", "a-diaeresis ", "a-ring", "o-diaeresis ", ],
			  },
			  "de" => {
   			      #hyper =>   [ "\x8e\x99\x9a\x84\x94\x81", "ss" ],
			      #iso8859 => [ "\xc4\xd6\xdc\xe4\xf6\xfc", "\xdf" ],
   			      "\xc4\xd6\xdc\xe4\xf6\xfc" => "\x8e\x99\x9a\x84\x94\x81",
   			      "\xdf" => "ss",
   			      "\xdf" => "ss",
			      desc =>    [ "AOUaou", "ess-tet" ],
			      ldesc => [ "A-umlaucht", "O-umlaucht", "U-umlaucht", "a-umlaucht", "o-umlaucht", "u-umlaucht", "ess-tet", ],
			  },
			  "desw" => {
   			      #hyper =>   [ "\x8e\xb6\x99\x9a\x84\x86\x94\x81", "ss" ],
			      #iso8859 => [ "\xc4\xc5\xd6\xdc\xe4\xe5\xf6\xfc", "\xdf" ],
			      "\xc4\xc5\xd6\xdc\xe4\xe5\xf6\xfc" => "\x8e\xb6\x99\x9a\x84\x86\x94\x81",
   			      "\xdf" => "ss",
			      desc =>    [ "AAOUaaou", "ess-tet" ],
			      ldesc => [ "A-umlaucht", "A-ring", "O-umlaucht", "U-umlaucht", "a-umlaucht", "a-ring", "o-umlaucht", "u-umlaucht", "ess-tet", ],
			  },
			  );

# this works best ... :-7
sub iso88592hypercom_simple() {
    tr/\xc4\xc5\xd6\xdc\xe4\xe5\xf6\xfc/\x8e\xb6\x99\x9a\x84\x86\x94\x81/;
    s/\xdf/ss/;
}

sub hypercom2iso8859_simple() {
    tr/\x8e\xb6\x99\x9a\x84\x86\x94\x81/\xc4\xc5\xd6\xdc\xe4\xe5\xf6\xfc/;
    s/ss/\xdf/;
}

# :(  doen't quite work as planned ... ?
sub iso88592hypercom() {
    my $lang;
    $lang = shift;
    my $in = \$_; #reference 
    #my @array = @{$hypercomPrintMap{$lang}{iso8859}};
    #for($i=0; $i < $#array; $i++){

    print "\n\$\$in = $$in, \$\_ = $_\n";

    my $key;
    my $ref = \%{$hypercomPrintMap{$lang}}; #reference 
    foreach $key (keys(%$ref)) {
	print "\nKey ".$key;
	for($key){
	    if (m/desc/) { 
	    } else {
		print "tr/$key/$$ref{$key}/;\n";
		$$in =~ tr/$key/$$ref{$key}/;
	    }
	}
    }

    print "\$\$in = $$in, \$\_ = $_\n";
    $$in;
}

return 1;


