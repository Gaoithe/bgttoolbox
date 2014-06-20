#!/usr/bin/perl
# bacik.ie/eircomwep  eircom wep script

use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

my $ssid = "42034334";
#my $ssid = "77636693";
#my $ssid = "66153334";
#my $ssid = "26337520";
#sudo iwlist  wlan0 scanning |grep ESSID
#                    ESSID:"eircom77636693"
#                    ESSID:"eircom6"
#        ESSID:"eircom4203 4334"


my $dec_ssid = oct($ssid);
my $xor = $dec_ssid ^ 4044; #mac
my $serial = $xor + 16777216; #0x10000000
my @numbers = {'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine' };
my @chars = split "",$serial;
my $plaintext;
foreach my $char (@chars) {
    $plaintext .= $numbers[$char];
}
my @lyrics = ("Although your world wonders me, ",
              "with your superior cackling hen,",
              "Your people I do not understand,",
              "So to you I shall put an end and",
              "You'll never hear surf music aga",
              "Strange beautiful grassy green, ",
              "With your majestic silver seas, ",
              "Your mysterious mountains I wish");
my @appended;
foreach(my $x=0;$x<=7;$x++){
    $ciphertext .= sha1_hex($appended[$x]);
}
my $c1 = substr($ciphertext,0,26);
my $c2 = substr($ciphertext,26,26);
my $c3 = substr($ciphertext,52,26);
my $c4 = substr($ciphertext,78,26);

print "ssid=$ssid WEP keys c1=$c1 c2=$c2 c3=$c3 c4=$c4\n";


# $ ./eirkey.pl
# ssid=66153334 WEP keys c1=da39a3ee5e6b4b0d3255bfef95 c2=601890afd80709da39a3ee5e6b c3=4b0d3255bfef95601890afd807 c4=09da39a3ee5e6b4b0d3255bfef
# $ ~/bin/eirkey.pl 
# ssid=26337520 WEP keys c1=da39a3ee5e6b4b0d3255bfef95 c2=601890afd80709da39a3ee5e6b c3=4b0d3255bfef95601890afd807 c4=09da39a3ee5e6b4b0d3255bfef



# sudo kismet
# in /etc/kismet/kismet.conf 
#  source=iwl3945,wlan0,wlan0
# lshw |less
# less /usr/share/doc/kismet/README.gz 
