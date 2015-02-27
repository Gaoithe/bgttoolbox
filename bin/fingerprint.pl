#!/usr/bin/env perl
#
# $Name:  $
# $Header: /homes/bob/cvsroot/mist/mist_sti/fingerprint.pl,v 1.3 2015/02/23 11:17:09 james Exp $
#

=head1 NAME

fingerprint.pl - calculate md5 fingerprints on message content and load into Message Fingerprinting

=head1 SYNOPSIS

Script interacts with transcoding server to select a set of profiles.
Message/Media content is transcoded using each profile.
MD5 fingerprint for each profile is calculated and loaded into Message Fingerprinting
Profile-sets are saved in a config file for re-use.

Uses libtrc/trc_cli to initialise transcoding interface. 
User selects set of User-Agent/Device/Media profiles.
 select profiles on server OR can specify a profileset file.
trc_cli makes call to mist_sti to send STI (OMA Standard Transcoding Interface) TranscodingRequest to STI server.
md5 fingerprint of resulting content is calculated.
md5 fingerprints are loaded into cconf for cobwebs the Message Fingerprinting corrib bus application.

Helper script elements - read vantrix transcoding server config to get list of profiles.
A list of profiles can be specified on command-line or in .fingerprinting/<settings> files to allow calculation of a set list of fingerprints for most commonly used profiles. 

=head1 OPTIONS and ARGUMENTS

Usage interactive (query profiles from server): 

   fingerprint.pl <image|audio|video|message|text>"

Usage using -profileset: 

   fingerprint.pl [-help] [-profileset <SETTINGS_FILE_FOR_PROFILES>] <image|audio|video|message|text>"

Usage using -profile: 

   fingerprint.pl [-help] [-profile <profile_name(~regexp}>] [[-profile <profile_name(~regexp}>] ...] <image|audio|video|message|text>"

OTHER OPTIONS may be on command-line or in profileset file: 

  [-help|-h] [-verbose|-v] . . .
  [-saveprofileset <SETTINGS_FILE_FOR_PROFILES>] . . .
  [-selector <selector_name>] [-selector_expr "<expression>"] . . .
  [-server <transcoding_server>] [-msisdn <msisdn>] . . .
  [-tool <path_to_trc_cli>]

=head2 Example

e.g. fingerprint.pl test.jpg

If no profile specified server is queried for profile list.
The user is prompted(in menus) to select profile.
The profile selection made is written to a profileset .fingerprinting/<datetime> which may be re-used later.
Profile-set files can be copied/moved and edited.

After a profile-set is selected transcoding is attempted on media for each profile.
MD5 fingerprints are calculated and loaded into cobwebs/message fingerprinting cconf.

=head2 More examples . . . 

e.g. fingerprint.pl -profile "image/VAN_JPEG Quality  75   15kB.xml" -profile "message/VAN_HTC Desire.xml" test.jpg

Select profiles on command-line.
Run transcoding on test.jpg using each profile.
Write fingerprint to cobwebs cconf.

e.g. fingerprint.pl -saveprofileset COMMON_PROFILES

Prompt user to select profiles.
Write selected profile-set to a specific file called "COMMON_PROFILES"

e.g. fingerprint.pl -listprofileset

List profile-set files in ~/.fingerprinting/ directory.

e.g. fingerprint.pl -profileset COMMON_PROFILES test.jpg

Load profiles (and other settings from ~/.fingerprinting/COMMON_PROFILES file.
Run transcoding on test.jpg using each profile.
Write fingerprint to cobwebs cconf.

e.g. fingerprint.pl -profileset COMMON_PROFILES -selector IS-MSG test.jpg -selector_expr '!{FROM-STORAGE} && {IS-MSG}'

Load profiles, run transcoding as previous example.
Specify a selector name and expression to use in the fingerprints.

e.g. //!not working yet!// fingerprint.pl -profile "message/.*Nokia.*6500.*" test.jpg

=head1 DESIGN/IMPLEMENTATION

Input: MMS or other message content (image/audio/video/text/other)
Input: Read transcoding server settings (from .fingerprinting or command-line)
Input: Read set(list) of profiles (from .fingerprinting or command-line or prompt user for input)

#
# 0. read settings from .fingerprinting or command-line
#    no default settings => prompt user
# 1. Look in cconf-dir/mist_sti-08/sti_profiles-12/* for server hostname
# 2. ssh to server, grep config and list profiles, 
#    Show menus to allow user to select set of profiles.
#    Save selected profiles in config file for re-use.
# 3. Do transcoding on media file - send transcoding request using cli.
#    MD5 is calculated and shown.
# 4. fingerprint+MD5 content item loaded into cobwebs/message fingerprinting
#
##[omn@vb-48] cat cconf-dir/mist_sti-08/sti_profiles-12/default-07 
#name: "default"
#enabled: 0
#host: "valhalla-1"
#port: 8700
#url: "/GAHOMASTI.xml"
#open_tout: 600
#rsp_tout: 600
#max_conn: 0
#reuse_conn: 1
#log_errors: 0
#log_http: 0
#xml_template: . . . .  <contentType>message/rfc822</contentType>
#
# Where are the profiles kept?
# On vantrix server, search profiles dirs and search mappings in Mapping/STI_VAN_STI_System_Mappings.xml.
#
# MENU: seach profiles, grep and sed to cut down list of profiles
#ls /opt/spotxde/share/profilesMO/Definition/message/ |grep -vE "(First|Last) Fall-back" |column 
#ls /opt/spotxde/share/profilesMO/Definition/message/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq |column
# ls /opt/spotxde/share/profilesMO/Definition/{image,audio,video,message,text}/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq |column
#my @profiles_short_all = `$sshcmd ls $profiles_path/Definition/{image,audio,video,message,text}/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq |column`;
#my @profiles_short_image = `$sshcmd ls $profiles_path/Definition/image/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq |column`;
#
# MENU: Device/User-Agent to profile mapping config for vantrix
#       search for ProfileName matching devices
# e.g. ProfileMapping Key="HTC_Desire_HD/1.0" ProfileName="message/VAN_HTC Desire HD.xml" KeyGroupName="User-Agent"/>
#grep -E "(HTC Dream|HTC Desire|Nokia 3200|Nokia 8800)" /opt/spotxde/share/profilesMO/Mapping/STI_VAN_STI_System_Mappings.xml    
#my $output = `$sshcmd ls $profiles_path/Definition/message`;
#print(STDOUT "$output\n");

# To do transcoding:
#e.g. call to mist_sti trc client cli
#message=OMN_Goals; bin/trc_cln_stub_MOD2 -mode 3 -i ${message}.image -profile "image/VAN_JPEG Quality  75   15kB.xml" -msisdn 353861111111  -o ${message}_PRO15k_MON_mo.trc

=head1 TEST and more details on USAGE

FBIN=/scratch/james/bin
FBIN=~/scripts

# 1.
# Save profile-set specified on command-line 
# 1.1 leave out -ss and is saved to datetimestamp file)
# 1.2 leave out media file and prompted to specify media file
./scripts/fingerprint.pl -profile "message/.*Nokia.*6500.*" -profile "image/VAN_JPEG Quality  75   15kB.xml" -profile "message/VAN_HTC Desire.xml" ~/OMN_Goals_HTCDesire_TUE.trc -ss and3profiles_x
ls ~/.fingerprinting
cat ~/.fingerprinting/and3profiles_x

# 2.
# run without args => reads server from cconf, shows profile selecting menus
[omn@vb-48] ./scripts/fingerprint.pl 
At least one profile should be specified.
Check cconf for transcoding server.
Try omn@valhalla-1
server:omn@valhalla-1
DEBUG: sshcmd=ssh -oBatchMode=yes omn@valhalla-1
DEBUG: grep:van.trx.profiles.local.path = /opt/spotxde/share/profilesMO

profiles_path=/opt/spotxde/share/profilesMO
audio
 image
 message
 text
 video

========================================
    /opt/spotxde/share/profilesMO/Definition
========================================
 1. List profile-set files
 2. Select profiles
 3. Search Device Mapping to profiles (enter: /<searchstring>)
 4. Clear profile selection
 5. Save a profile-set file
 6. Select Media
 7. CONTINUE: Run Transcoding and Generate Fingerprints
Selected 0 profiles: 
No media is specified.

?: 

# 3. run with specified profileset file and media item

# 4. specify selector
# 4.1 specify selector and selector expression
e.g. fingerprint.pl -profileset COMMON_PROFILES -selector IS-FPT-MSG -selector_expr "\!{FROM-STORAGE} && {IS-MSG}"  test.jpg

=cut

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use POSIX;
use File::Basename;
use Data::Dumper;

#########################################################################
# variables and default values
#########################################################################

package main;

our $gOMNHomeDir = $ENV{"HOME"};
our $gConfigDir = "$gOMNHomeDir/.fingerprinting";
mkdir $gConfigDir || print(STDERR "ERROR: failed to mkdir $gConfigDir");

our $gDefaultProfileset = "$gConfigDir/DEFAULT_PROFILES";
our $gProfileset = $gDefaultProfileset;
our $gSaveProfileset;
our $gUserProfileset;
our $gLoadedprofileset;
our $verbose;
our $donothing;

%profileset::profileset = (
    'msisdn' => '353861111111',
    'server' => '',
    'profiles_list' => [],
    'mode' => 3,
    'trc_cli' => "$gOMNHomeDir/bin/trc_cli",
    'selector' => "NEWLY-LOADED-FINGERPRINTS",
    'selector_expr' => "!{FROM-STORAGE} && {IS-MSG}",
    #'trc_cli' => "$gOMNHomeDir/bin/trc_cln_stub_MOD2",
    #'test' => {
    #    't1' => {
    #        'v1'   => 1111,
    #        'v2'   => 't1val2',
    #    },
     #   't2' => {
     #       'v1'   => 1111,
     #       'v2'   => 't2val2',
     #   }
    #},
);

our $gMEDIA_ITEM="";

our $sshcmd;
our $profiles_path;

sub add_profile_to_list;
sub show_selected_profiles;
sub show_selected_media;


#########################################################################
# Menu: top menu, if media or profiles not selected on command-line
#########################################################################
sub topmenu {

    my $profiles_shortlist_topmenu = shift;
    my $select_media_menu = shift;

    my @topmenu_choices = (
        { text => 'List profile-set files',
          code => sub { profilesetfilesmenu()->print(); }},
        { text => 'Select profiles',
          code => sub { $$profiles_shortlist_topmenu->print(); }},
        { text => 'Search Device Mapping to profiles (enter: /<searchstring>)',
          code => sub { searchdefinitionsmenu("$profiles_path/Definition"); }},
        { text => 'Clear profile selection',
          code => sub { clear_profiles(); }},
        #{ text => 'Show Selected profiles',
        #  code => sub { show_selected_profiles(""); }},
        { text => 'Save a profile-set file',
          code => sub { saveProfilesetFile(); }},
        { text => 'Select Media',
          code => sub { $$select_media_menu->print(); }},
        { text => 'CONTINUE: Run Transcoding and Generate Fingerprints',
          key  => 'c',
          code => sub {return "EXIT";},
          enablecode => sub {return ready_for_transcoding();}},
        );

    my $topmenu = Menu->new(
        title   => "$profiles_path/Definition",
        choices => \@topmenu_choices,
        topmenu => 1,
        noexit  => 1,
        noreturn=> 1,
        );

    return $topmenu;
}

#########################################################################
# Menu: selecting profile-set files from ~/.fingerprinting/
#########################################################################
sub profilesetfilesmenu {

    # Profileset files menu
    my @profileset_files_choices = ();
    
    my @profileset_files = `ls $gConfigDir`;
    foreach my $file (@profileset_files) {
        $file =~ s/\r|\n//g;
        push(@profileset_files_choices, {
            text => "$file", 
            code => sub {loadProfilesetOrExit("$gConfigDir/$file");}
             });
    }
    push(@profileset_files_choices,      
         { text => 'back to Topmenu',
           key  => 'b',
           code => sub {return "EXITMENUONELEVEL";}},
        );
    
    my $profileset_files_menu = Menu->new(
        title   => "Select a profile-set file.
    COMMANDS: cat <f> || grep <something> <f> || mv <f1> <f2> || vi <f> || <select number>
    use -profileset <file> on command-line to select a profileset
    $gConfigDir",
        choices => \@profileset_files_choices,
        dir => $gConfigDir,
        allowed => "cat|grep|mv|vi|rm",
        noreturn  => 1,
        marksel   => "   *",
        );

    return $profileset_files_menu;
}

#########################################################################
# Menu: selecting profiles from transcoding server
#  there are ALOT of profiles so we "shortlist" them for the menus
#########################################################################
sub profilesshortlistmenu {
    my $dirpath = shift;
    my $dir = shift;
    my $cmd = shift;
    my $sel = shift;

    my @profiles = `$sshcmd $cmd`;

    #my @profiles = `$sshcmd ls $profiles_path/Definition/$dir/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq`;
    ###my @profiles = `$sshcmd ls $profiles_path/Definition/$dir/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq|column`;

    my @choices;
    foreach my $p (@profiles) {
        $p =~ s/\r|\n//g;

        my $mark="";
        $mark = " *SELECT*" if (grep(/$p/,@{$profileset::profileset{'profiles_list'}}));

        push(@choices, {
            text => "$p".$mark, 
            code => sub { print "SELECT:$p"; 
                          if ($sel) { 
                              add_profile_to_list "$dir/$p"; 
                          } else {
                              profilesshortlistmenu("$profiles_path/Definition",$dir,"ls $profiles_path/Definition/$dir/ |grep '$p'|sort |uniq",1);
                          } 
            }
             });
    }
    push(@choices,            
         { text => 'Exit sub-menu',
           key  => 'b',
           code => sub {return "EXITMENUONELEVEL";}},
        );
    
    my $menu = Menu->new(
        title   => 'Profiles Shortlist $dir',
        choices => \@choices,
        noexit  => 1,
        noreturn=> 1,
        marksel => " *MARKED*",
        );

    $menu->print();
}

sub profiles_shortlist_topmenu {
    # Profiles Shortlist menu
    my @profiles_shortlist_choices;

    # MENU: look in profile Definition dir
    my @dirs_definition = `$sshcmd ls $profiles_path/Definition`;
    print(STDOUT "@dirs_definition\n");

    foreach my $dir (@dirs_definition) {
        $dir =~ s/\r|\n//g;
        push(@profiles_shortlist_choices, {
            text => "$profiles_path/Definition/$dir", 
            code => sub {profilesshortlistmenu("$profiles_path/Definition",$dir,"ls $profiles_path/Definition/$dir/ |grep -vE '(First|Last) Fall-back' |sed 's/VAN_//;s/ .*//' |sort |uniq",0);}
             });
    }
    push(@profiles_shortlist_choices,            
         { text => 'back to Topmenu',
           key  => 'b',
           code => sub {return "EXITMENUONELEVEL";}},
        );

    my $profiles_shortlist_topmenu = Menu->new(
        title   => 'Profiles Shortlist',
        choices => \@profiles_shortlist_choices,
        noexit  => 1,
        marksel => " *MARKED*",
        );

    return $profiles_shortlist_topmenu;
}


#########################################################################
# Menu: search for ProfileName matching devices
#########################################################################
#e.g. ProfileMapping Key="HTC_Desire_HD/1.0" ProfileName="message/VAN_HTC Desire HD.xml" KeyGroupName="User-Agent"/>
#grep -E "(HTC Dream|HTC Desire|Nokia 3200|Nokia 8800)" /opt/spotxde/share/profilesMO/Mapping/STI_VAN_STI_System_Mappings.xml
#grep ProfileMapping /opt/spotxde/share/profilesMO/Mapping/STI_VAN_STI_System_Mappings.xml
#[omn@valhalla-1 ~]$ grep ProfileMapping /opt/spotxde/share/profilesMO/Mapping/STI_VAN_STI_System_Mappings.xml |sed 's/.*ProfileName="//;s/" .*//;s/VAN_//;s/.xml//' |sort |uniq -ci |wc -l
#grep ProfileMapping /opt/spotxde/share/profilesMO/Mapping/STI_VAN_STI_System_Mappings.xml |sed 's/.*ProfileName="//;s/" .*//;s/VAN_//;s/.xml//' |awk '{print $1}' |sort |uniq -ci 
#3770 devices, 144 manufacturers
#profiles_path=/opt/spotxde/share/profilesMO; 
#ssh -oBatchMode=yes omn@valhalla-1 "grep ProfileMapping $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml |sed 's/.*ProfileName=\"//;s/\" .*//;s/VAN_//;s/.xml//' |awk '{print \$1}' |sort |uniq -ci"
sub searchdefinitionsmenu {
    my $dirpath = shift;
    my $manufacturer = shift;
    my @profiles;
    if (defined($manufacturer) && $manufacturer eq "ALL") {
        #@profiles = `$sshcmd "grep '<ProfileMapping ' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml"`
        @profiles = `$sshcmd "grep '<ProfileMapping ' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml" |sed 's/.*ProfileName=\"//;s/\" .*//;s/VAN_//;s/.xml//'`
    } elsif (defined($manufacturer) && $manufacturer eq "COMMON") {
        @profiles = `$sshcmd "grep -E '(HTC Dream|HTC Desire|Nokia 3200|Nokia 8800)' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml"`;
        #my @profiles = `$sshcmd ls $profiles_path/Definition/$dir/ |grep -vE "(First|Last) Fall-back" |sed "s/VAN_//;s/ .*//" |sort |uniq|column`;
    } elsif (defined($manufacturer)) {
        my ($count,$m) = ($manufacturer =~ m/\s*(\d+)\s*(\w+)\s*/);
        @profiles = `$sshcmd "grep -E '$m' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml"`;
    } else {
        #@profiles = `$sshcmd "grep '<ProfileMapping ' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml |sed 's/.*ProfileName=\"//;s/\" .*//;s/VAN_//;s/.xml//' |awk '{print \$1}' |sort |uniq -ci"`;
        @profiles = `$sshcmd "grep '<ProfileMapping ' $profiles_path/Mapping/STI_VAN_STI_System_Mappings.xml" |sed 's/.*ProfileName=\"//;s/\" .*//;s/VAN_//;s/.xml//;s#message/##' |awk '{print \$1}' |sort |uniq -ci`
    }

    my @choices;
    foreach my $p (@profiles) {
        $p =~ s/\r|\n//g;
        $p =~ s/.*ProfileName=//;
        $p =~ s/"//;
        $p =~ s/".*//;

        if (!defined($manufacturer)) {
            push(@choices, {
                text => "$p",
                code => sub { print "SELECT:$p\n"; searchdefinitionsmenu($dirpath,$p); }
                 });
        } else {
            my $mark="";
            $mark = " *SELECT*" if (grep(/$p/,@{$profileset::profileset{'profiles_list'}}));
            my $t = $p;
            # make big menus smaller by reducing size of common menu text (remove redundant message/VAN_......xml)
            $t =~ s/message\/VAN_//;
            $t =~ s/.xml//;
            push(@choices, {
                text => "$t".$mark, 
                code => sub { print "SELECT:$p\n"; add_profile_to_list "$p"; }
                 });
        }
    }
    push(@choices,            
         { text => 'Exit sub-menu',
           key  => 'b',
           code => sub {return "EXITMENUONELEVEL";}},
        );
    
    my $menu = Menu->new(
        title   => "Search Definitions $dirpath",
        choices => \@choices,
        noexit  => 1,
        noreturn=> 1,
        marksel => " *MARKED*",
        );

    $menu->print();
}

#########################################################################
# Menu: select media file
#########################################################################
sub selectmediamenu {
    my $cmd = shift;

    # find . -maxdepth 1 -type f -readable -iname "*.*"
    my $reMediaFileExtensions = "(jpg|jpeg|png|gif|bmp|tif|tiff|" . 
        "wav|ogg|mp3|m4a|m4b|m4p|aiff|wma|aac|au|amr|mov|caf|flac|mid|".
        "avi|mp4|mpg|mpeg|wmv|vob|asf|m4v|3gpp)";

    #$cmd = "ls *.jpg";
    $cmd = "find . -maxdepth 1 -type f -readable |grep -iE \"\.$reMediaFileExtensions\"\$";
    
    my @files = `$cmd`;

    my @choices;
    foreach my $f (@files) {
        $f =~ s/\r|\n//g;
        push(@choices, {
            text => "$f", 
            code => sub { print "SELECT:$f"; 
                          our $gMEDIA_ITEM;
                          $gMEDIA_ITEM = $f;
            }});
    }
    push(@choices,            
         { text => 'Exit sub-menu',
           key  => 'b',
           code => sub {return "EXITMENUONELEVEL";}},
        );
    
    my $menu = Menu->new(
        title   => "Select Media File $cmd",
        choices => \@choices,
        marksel => " *MARKED*",
        );

    #$menu->print();

    return $menu;
}


#########################################################################
# Menu display and user input
#  noreturn means don't exit menu on a selection, just on "exit to submenu"
#########################################################################

package Menu;

sub wait_for_any_key {
    #use Term::ReadKey;
    #ReadMode('cbreak');
    #my $key = ReadKey(0);
    #ReadMode('normal');

    #system "stty cbreak </dev/tty >/dev/tty 2>&1";
    system "stty", '-icanon', 'eol', "\001";
    my $key = getc(STDIN);
    #system "stty -cbreak </dev/tty >/dev/tty 2>&1";
    system 'stty', 'icanon', 'eol', '^@'; # ASCII NUL
    return $key;
}

# Menu constructor
sub new {

    # Unpack input arguments
    my $class = shift;
    my (%args) = @_;
    my $title       = $args{title};
    my $choices_ref = $args{choices};
    my $topmenu     = $args{topmenu};
    my $noexit      = $args{noexit};
    my $noreturn    = $args{noreturn};
    my $marksel     = $args{marksel};
    my $dir         = $args{dir} if $args{dir};
    my $allowed     = $args{allowed} if $args{allowed};

    my @sttyl = qx(stty -a|grep rows);
    my ($rows, $cols) = ($sttyl[0] =~ m/rows\s*(\d+);\s*columns\s*(\d+);/);
    print "DEBUG: screen size is rows:$rows x cols:$cols\n" if ($verbose);

    my $cols_keepfree = 10;
    $cols -= $cols_keepfree;

    # Bless the menu object
    my $self = bless {
        title   => $title,
        choices => $choices_ref,
        topmenu => $topmenu,
        noexit  => $noexit,
        noreturn=> $noreturn,
        marksel => $marksel,
        dir     => $dir,
        allowed => $allowed,
        rows    => $rows,
        cols    => $cols,
    }, $class;

    return $self;
}

# Print the menu
sub print {

    # Unpack input arguments
    my $self = shift;
    my $title   =   $self->{title};
    my @choices = @{$self->{choices}};
    my $topmenu  =  $self->{topmenu};
    my $noexit  =   $self->{noexit};
    my $noreturn=   $self->{noreturn};
    my $marksel =   $self->{marksel};
    
    my $menu_cols = 1;
    my $menu_col_width = 0;
    my $rows_for_menu_head_and_foot = 4;

    if (scalar @choices > ($self->{rows} - $rows_for_menu_head_and_foot)) {
        print "DEBUG: too many choices so . . . \n" if ($verbose);
        my $maxmenutext = 0;
        for my $choice(@choices) {
            my $l = length($choice->{text});
            $maxmenutext = $l if ($maxmenutext<$l);
        }
        $menu_cols = $self->{cols} / ($maxmenutext + 10);
        print "DEBUG: menu cols:$menu_cols\n" if ($verbose);
        $menu_col_width = $self->{cols}/$menu_cols;
    }

    # Print menu
    for (;;) {

        # Clear the screen
        #system 'clear';

        # Print menu title
        print "========================================\n";
        print "    $title\n";
        print "========================================\n";

        # Print menu options
        my $menuline = "";
        my $linecounter = 0;
        my $counter = 0;
        for my $choice(@choices) {
            
            #$choice->{text}.=" *SELECT*" if (grep $choice->{text} @{$profileset::profileset{'profiles_list'}});

            if (!defined($choice->{enablecode}) || $choice->{enablecode}()) {
                if (defined($choice->{key})) {
                    $menuline .= sprintf "%2s. %-${menu_col_width}s", $choice->{key}, $choice->{text};
                } else {
                    $menuline .= sprintf "%2d. %-${menu_col_width}s", ++$counter, $choice->{text};
                }
            }

            if ($counter % $menu_cols == 0) {
                $linecounter++;
                # save un-necessary line-wrapping for big menus by removing whitespace at EOL
                $menuline =~ s/\s*$//;
                printf "$menuline\n";
                $menuline = "";

                if (($linecounter + $rows_for_menu_head_and_foot) % $self->{rows} == 0) {
                    # Woah. Too much stuff in menu for one page. > prompt !! PAGE !! MORE !! LESS !!
                    printf "--More--";
                    wait_for_any_key();
                    printf "\r";
                    
                }

            }


        }
        printf "%2d. %s\n", '0', 'Exit' unless $noexit;
        main::show_selected_profiles("Selected ");
        main::show_selected_media();

        #printf "Selected %d profiles.\n", scalar @{$profileset::profileset{'profiles_list'}};

        print "\n?: ";

        # Get user input
        chomp (my $input = <STDIN>);

        print "\n";

        # Process input
        if ($input =~ m/^\d+$/ && $input >= 1 && $input <= $counter) {
            print "DEBUG: selected $choices[$input - 1]{text}\n";
            my $result = $choices[$input - 1]{code}->();
            print "DEBUG: result=$result\n";
            return $result if ("$result" eq "EXIT");
            return $result."ONELEVEL" if ("$result" eq "EXITMENUONELEVEL" and !$self->{topmenu});
            return $result if (!$self->{noreturn} or ("$result" eq "EXITMENU" and !$self->{topmenu}));
            $choices[$input - 1]{text} .= $marksel if ($marksel); 
        } elsif ($input =~ m/\d+/ && !$input && !$noexit) {
            print "Exiting . . .\n";
            exit 0;
        } elsif ($input eq "b" || $input eq "back") {
            return "BACK";
        } else {

            #print "DEBUG: dir:$self->{dir}\n";
            #print "DEBUG: allowed:$self->{allowed}\n";
            print "DEBUG: input:$input\n";

            if ($self->{allowed} && $input =~ $self->{allowed}) {
                if ($input =~ m/vi /) {
                    my $result = system("cd $self->{dir};$input");
                    print $result;                    
                } else {
                    my $result = `cd $self->{dir};$input`;
                    print $result;
                }
            } else {

                # Also look for a match of the menu item string. (cut & paste common for media and profiles and files
                my $matched=0;
                for my $choice(@choices) {
                    if ($input eq $choice->{text} || 
                        (defined($choice->{key}) && $input eq $choice->{key})
                        ) {
                        $matched=1;

                        print "DEBUG: selected $choice->{text}\n";
                        my $result = $choice->{code}->();
                        print "DEBUG: result=$result\n";
                        return $result if ("$result" eq "EXIT");
                        return $result."ONELEVEL" if ("$result" eq "EXITMENUONELEVEL" and !$self->{topmenu});
                        return $result if (!$self->{noreturn} or ("$result" eq "EXITMENU" and !$self->{topmenu}));
                        $choice->{text} .= $marksel if ($marksel); 
                        
                    }
                }

                if (!$matched) {
                    print "Invalid input.\n\n";
                    sleep 2;
                }
            }
        }
    }
}


#########################################################################
# Menu End
#########################################################################

package main;

#########################################################################
# load a profile-set
#########################################################################

sub loadProfileset {
    our $gProfileset;
    our $gDefaultProfileset;
    my $file = shift;
    print("DEBUG: load profileset $file\n") if ($verbose);
    
    our $err;
    # put profileset data into a separate namespace
    { 
        package profileset;
    
        # Process the contents of the config file
        #my $rc = require $file;

        my $rc = do($file);
        
        # Check for errors
        if ($@) {
            $::err = "ERROR: Failure compiling '$file' - $@";
        } elsif (! defined($rc)) {
            $::err = "ERROR: Failure reading '$file' - $!";
        } elsif (! $rc) {
            $::err = "ERROR: Failure processing '$file'";
        }
    }
        
    if ($err) {
        die "ERROR loading Profileset:$file $err";
    }
}

sub loadProfilesetOrExit {
    my $file = shift;
    my $err = loadProfileset($file);
    $gLoadedprofileset = $file;
    if ($err) {
        print(STDERR "Problem loading PROFILESET.\n");
        print(STDERR "ERROR:$err\n");
        print(STDERR "PROFILESET:'$file' was specified but I can't read it.\n") if $file;
        print(STDERR "\n");
        `ls $file`;
        #pod2usage(q(-verbose) => 1);
        exit(1);

    }

    #if ($verbose) {}
    show_selected_profiles("Loaded ");
}

#########################################################################
# save a profile-set
#########################################################################

sub saveProfileset {
    #our ($gProfileset, $gDefaultProfileset);
    my $file = shift;
    print("INFO: save profileset $file\n");

    my $profileset;
    if (! open($profileset, "> $file")) {
        print (STDERR "ERROR: Failure opening '$file' - $!\n");
        return "ERROR: Failure opening '$file' - $!";
    }
    
    print $profileset <<EOF;

our (%profileset);
# The profileset data hash
@{[Data::Dumper->Dump([\%profileset::profileset], ['*profileset'])]}
1;
EOF

    close($profileset);
    print("INFO: saved profileset $file\n");
    return (undef);   # Success
}

#########################################################################
# Save profile-set
# write to specified profile-set name OR date/timestamp file
#########################################################################
sub saveProfilesetFile {
    our ($gLoadedprofileset, $gSaveProfileset, $gProfileset, $gConfigDir);
    # Write a date-timestamp profile-set if profiles selected by user interaction or on command-line
    if (!$gLoadedprofileset && !$gSaveProfileset && $gProfileset &&
        scalar @{$profileset::profileset{'profiles_list'}} != 0) {
        #$gSaveProfileset = strftime("%F %T", localtime);
        $gSaveProfileset = strftime("%Y%m%d_%H%M", localtime);
    }

    if (scalar @{$profileset::profileset{'profiles_list'}} <= 0) {
        print(STDERR "No PROFILESET. No profiles selected.\n");
    }

    if (!$gSaveProfileset) {
        print(STDERR "No PROFILESET save file name set?\n");
    }
    
    # write profile-set requested on command-line OR profiles selected by user interaction or on command-line
    if ($gSaveProfileset) {
        my $err = saveProfileset("$gConfigDir/$gSaveProfileset");
        if ($err) {
            print(STDERR "Problem saving PROFILESET:'$gConfigDir/$gSaveProfileset'.\n");
            #print(STDERR "$err\n");
            print(STDERR "\n");
            `ls $gConfigDir/$gSaveProfileset`;
            return $err;
        }
        return "SAVED_PROFILESET"
    } else {
        print(STDOUT "INFO: No PROFILESET file saved.\n");
        return "DID_NOT_SAVE_PROFILESET"
    }
}

#########################################################################
# Run ssh commands, query transcoding server config and profiles
#########################################################################

# Hurmmm. Hmmmmm. Hmmmmnnn. Yep. Backticks used because they are most portable. Practical.

#use Net::OpenSSH;
#my $ssh = Net::OpenSSH->new($profileset::profileset{'server'});
##my $ssh = Net::OpenSSH->new($host, user => $user, password => $password);
#$ssh->die_on_error("unable to connect");
#my @output = $ssh->capture("grep van.trx.profiles.local.path /etc/opt/spotxde/trx.conf");
#print(STDOUT "@output\n");
#our $profiles_path = $output[0];
#$profiles_path =~ s/.* //;
#my @output = $ssh->capture("ls $profiles_path");
#print(STDOUT "@output\n");

#my $output = `ssh $profileset::profileset{'server'} grep van.trx.profiles.local.path /etc/opt/spotxde/trx.conf`;
#print(STDOUT "$output\n");
#our $profiles_path = $output;
#$profiles_path =~ s/.* //;
#my $output = `ssh $profileset::profileset{'server'} ls $profiles_path`;
#print(STDOUT "$output\n");

# ssh generally doesn't allow passwd to be specified on cmd line
#if ($profileset::profileset{'serverpass'}) {
#    $sshcmd .= " --password $profileset::profileset{'serverpass'}";
#}

#open P,"command |" or die "error running command $!";
#my @data=<p>;
#close P;
#my $errorcode=$? >> 8;

sub get_output_from_server {
    my $cmd = shift;
    my $match = shift;

    my $output = `$cmd`;
    #print @output;
    #my $output=$output[0];
    my $errcode = $?>>8;
    if ($errcode != 0 || ! ($output =~ m/$match/)) { 
        print(STDERR "errcode=$errcode. Problem with $sshcmd. Check ssh keys are exchanged.\n");
        print(STDERR "ERROR:$output\n");
        exit(1);
    }
    
    print(STDOUT "DEBUG: grep:$output\n");
    return $output;
}

# e.g. $profiles_path = get_config_from_server($sshcmd,"van.trx.profiles.local.path","/etc/opt/spotxde/trx.conf");
#command.line.logging.config.file.path = /opt/spotxde/etc/trx/logconfig.xml
#van.trx.profiles.local.path = /opt/spotxde/share/profilesMO
#offline-transcoding-path = /data/trx-offline
sub get_config_from_server {
    my $sshcmd = shift;
    my $var = shift;
    my $conf = shift;

    my $cmd = "${sshcmd} grep \"^van.trx.profiles.local.path.*=\" /etc/opt/spotxde/trx.conf 2>&1";
    my $output = get_output_from_server($cmd,$var);

    $output =~ s/.* //;
    $output =~ s/\r|\n//g;
    return $output;
}

#########################################################################
# Options processing
#########################################################################

sub add_media_item {
    our $gMEDIA_ITEM;
    $gMEDIA_ITEM = shift;
    print("set gMEDIA_ITEM=$gMEDIA_ITEM\n") if ($verbose);
}

sub add_profile_to_list {
    my $p = shift;
    # don't add duplicate items
    if (!grep(/$p/,@{$profileset::profileset{'profiles_list'}})) {
        push (@{$profileset::profileset{'profiles_list'}}, "$p");
    } else {
        print(STDERR "WARNING: $p is already in list\n");
        sleep 2;
    }
}

sub list_profile_sets {
    print("\n");
    print("INFO: Local profilesets in dir:$gConfigDir. Specify using -ps <name>\n");
    my $output = `ls $gConfigDir`;
    print $output;
    print("\n");

    print("INFO: Query server to build up profileset.\n");
    exit(0);
}

sub show_selected_profiles {
    my $msg = shift;
    printf "%s%d profiles: ", $msg, scalar @{$profileset::profileset{'profiles_list'}};
    foreach my $profile (@{$profileset::profileset{'profiles_list'}}) {
        # cut down screen space used
        my $pprofile = $profile;
        $pprofile =~ s/message\//m\//;
        $pprofile =~ s/image\//i\//;
        $pprofile =~ s/audio\//a\//;
        $pprofile =~ s/text\//t\//;
        $pprofile =~ s/video\//v\//;
        $pprofile =~ s/VAN_//;
        $pprofile =~ s/.xml//;
        print "'$pprofile' ";
    }
    print "\n";
    return 0;
}    

sub clear_profiles {
    @{$profileset::profileset{'profiles_list'}} = ();
}


sub show_selected_media {
    if (!$gMEDIA_ITEM) {
        print("No media is specified.\n");
    } elsif (! -e $gMEDIA_ITEM) {
        print("media:$gMEDIA_ITEM is specified but cannot be found?\n");
    } else {
        print("media:$gMEDIA_ITEM\n");
    }
}

sub ready_for_transcoding {
    if ((scalar @{$profileset::profileset{'profiles_list'}} > 0) &&
        ($gMEDIA_ITEM)) {
        # enable topmenu continue option
        return 1;
    } else {
        # disable topmenu continue option
        return 0;
    }
}

#########################################################################
# Options processing and checking
#########################################################################

my $rc = GetOptions(
    q(help|h|?+)        => \my $help,
    q(verbose|v+)       => \$verbose,
    q(donothing|n+)     => \$donothing,
    q(profileset|ps:s)  => \$gUserProfileset,
    q(saveprofileset|ss:s)  => \$gSaveProfileset,
    q(listprofileset|lps:s) => \&list_profile_sets,
    q(server|s:s)       => \$profileset::profileset{'server'},
    q(profile|p:s)      => \&add_profile_to_list,
    q(msisdn|m:s)       => \$profileset::profileset{'msisdn'},
    q(mode:i)           => \$profileset::profileset{'mode'},
    q(tool|t:s)         => \$profileset::profileset{'trc_cli'},
    q(selector|sel:s)   => \$profileset::profileset{'selector'},
    q(selector_expr|se:s) => \$profileset::profileset{'selector_expr'},
    '<>'                => \&add_media_item,
);
# Getopt::Long on TC nodes is too old for direct array population. 
# q(profile|p:s@)     => \@profileset::profileset{'profiles_list'},

print "DEBUG: OPTIONS rc=$rc help=$help gProfileset=$gProfileset\n\n" if ($verbose);

if (!$rc || $help || !$gProfileset) {
    pod2usage(q(-verbose) => 2,
              q(-sections) => "NAME|SYNOPSIS|USAGE",
        );
    # older Pod::Usage == 1.16 on TC so it doesn't understand sections.
    #pod2usage( { -message => $message_text ,
    #             -exitval => $exit_status  , 
    #             -sections => "NAME|SYNOPSIS|USAGE",
    #             -verbose => $verbose_level,  
    #             -output  => $filehandle } );
    exit 0;
}

#########################################################################
# Load profile-set
#########################################################################

# loading user-specified profile-set is mandatory IF it is specified
if ($gUserProfileset) {
    $gProfileset="$gUserProfileset";
    if (! -e $gProfileset) {
        $gProfileset="$gConfigDir/$gUserProfileset";
    }
    if (! -e $gProfileset) {
        print(STDERR "Problem with PROFILESET.\n");
        print(STDERR "PROFILESET:'$gUserProfileset' was specified but I can't read it.\n") if $gProfileset;
        print(STDERR "\n");
        `ls $gProfileset $gUserProfileset`;
        #pod2usage(q(-verbose) => 1);
        exit -1;
    }
}

# load the user-specified profile-set IF specified loading default profile-set is optional
if (-e $gProfileset) {
    loadProfilesetOrExit($gProfileset);
}

#########################################################################
# Prompt user to select profile-set (and query profiles on server) and media
#########################################################################
if (scalar @{$profileset::profileset{'profiles_list'}} == 0 ||
    !$gMEDIA_ITEM || ! -e $gMEDIA_ITEM
    ) {
    print(STDERR "At least one profile and media item should be specified.\n");

    if (!$profileset::profileset{'server'}) {
        print(STDOUT "Check cconf for transcoding server.\n");
        # read server from here [omn@vb-48] cat cconf-dir/mist_sti-08/sti_profiles-12/default-07 
        my $host = `grep host: cconf-dir/mist_sti-*/sti_profiles-*/default-*`;
        $host =~ s/\r|\n//g;
        $host =~ s/host:\s*//;
        $host =~ s/"//g;
        
        if ($host) {
            print(STDOUT "Try omn\@${host}\n");
            $profileset::profileset{'server'} = "omn\@${host}";
        }
    }

    # query server and prompt user for profiles list
    if ($profileset::profileset{'server'}) {
        print(STDOUT "server:$profileset::profileset{'server'}\n");
        $sshcmd = "ssh -oBatchMode=yes $profileset::profileset{'server'}";
        print(STDOUT "DEBUG: sshcmd=${sshcmd}\n");

        $profiles_path = get_config_from_server($sshcmd,"van.trx.profiles.local.path","/etc/opt/spotxde/trx.conf");
        $profileset::profileset{'profiles_path'} = $profiles_path;
        print(STDOUT "profiles_path=$profiles_path\n");

        #########################################################################
        # User interaction, select list of profiles using menus
        #########################################################################

        #use Menu;
        my $topmenu;
        my $profiles_shortlist_topmenu;
        my $select_media_menu;

        do {

        $topmenu = topmenu(\$profiles_shortlist_topmenu, \$select_media_menu, $profiles_path);

        $profiles_shortlist_topmenu = profiles_shortlist_topmenu(\$topmenu);

        $select_media_menu = selectmediamenu("ls *.jpg",0);

        # Print topmenu and interact through menus to select profiles and media
        # After return from menus carry on and do transcoding
        $topmenu->print();

        } until (ready_for_transcoding());

    } else {
        print(STDOUT "No transcoding server known.\n");
    }
    
}


#########################################################################
# Save profile-set (IF needed)
#########################################################################

saveProfilesetFile();

#########################################################################
# Check media item and at least one profile selected
#########################################################################

my $gExit = 0;

if (scalar @{$profileset::profileset{'profiles_list'}} == 0) {
    print(STDERR "At least one profile should be specified.\n");
    $gExit = -1;
}

if (!$gMEDIA_ITEM || ! -e $gMEDIA_ITEM) {
    # TODO: allow ftp: or http: specified media items
    print(STDERR "One media item should be specified.\n");
    if ($gMEDIA_ITEM) {
        print(STDERR "item:'$gMEDIA_ITEM' was specified but I can't read it.\n") ;
    }
    print(STDERR "\n");
    my $lscheck = `ls $gMEDIA_ITEM`;
    #pod2usage(q(-verbose) => 1,
    #          q(-sections) => "NAME|SYNOPSIS|USAGE",
    #);
    $gExit = -1;
}

if ( ! -x "$profileset::profileset{'trc_cli'}" ) {
    print(STDERR "cannot find trc_cli tool $profileset::profileset{'trc_cli'}, check permissions?\n");
    `ls -al $profileset::profileset{'trc_cli'}`; 
    $gExit = -1;
}

if ($gExit) {
    exit $gExit; 
}

#########################################################################
# Transcoding and write to cconf
#########################################################################

my $datetime = strftime("%Y%m%d_%H%M", localtime);

my $bn = basename($gMEDIA_ITEM);
$bn =~ s/\..*$//;
if ($verbose) { print "MEDIA bn=$bn\n"; }
my $cobwebs_fingerprint_name=$bn."_".$datetime;
my $cobwebs_cconf_path = "corrib_router/cobwebs/fingerprints/$cobwebs_fingerprint_name";

my $cobwebs_cconf_file = 'tmp_fingerprint.cconf';
my $cobwebs_cconf_index = 0;

open(my $cobwebs_cconf_fh, '>', $cobwebs_cconf_file) or die "Could not open tmp cconf file for writing:'$cobwebs_cconf_file' $!";
print $cobwebs_cconf_fh "name: \"$cobwebs_fingerprint_name\"\n";
print $cobwebs_cconf_fh "enabled: 0\n";
print $cobwebs_cconf_fh "desc: \"$cobwebs_fingerprint_name loaded at $datetime\"\n";
print $cobwebs_cconf_fh "selector: \"$profileset::profileset{'selector'}\"\n";

# Write cconf file example
#[omn@vb-48] bin/cci ls corrib_router/cobwebs
#selectors/
#fingerprints/
#[omn@vb-48] cci cat corrib_router/cobwebs/fingerprints/ThisIsAnother
#name: "ThisIsAnother"
#enabled: 1
#desc: "ThisIsAnother"
#selector: "IS-MSG"
#contents.000.enabled: 1
#contents.000.content_name: "ThisIsAnotherC1"
#contents.000.md5: "4688e28256bd6ce9c3e3033e68704a81"

printf "Attempting transcode for %d profiles.\n", scalar @{$profileset::profileset{'profiles_list'}};
foreach my $profile (@{$profileset::profileset{'profiles_list'}}) {
    my $bp = $profile;
    $bp =~ s/\.xml//;
    $bp =~ s/\s+/_/g;
    $bp =~ s/VAN_//g;
    $bp =~ s/[\/\*\.]//g;
    print "INFO: TRANSCODE MEDIA '$gMEDIA_ITEM' bn=$bn PROFILE '$profile' bp=$bp\n";
    if ($verbose) { print "PROFILE '$profile' bp=$bp\n"; }
    if ($verbose) { print "CMD='$profileset::profileset{'trc_cli'} -mode $profileset::profileset{'mode'} -i $gMEDIA_ITEM -profile \"$profile\" -msisdn $profileset::profileset{'msisdn'} -o ${bn}_${bp}.trc'\n"; }
    my $result = `$profileset::profileset{'trc_cli'} -mode $profileset::profileset{'mode'} -i $gMEDIA_ITEM -profile "$profile" -msisdn $profileset::profileset{'msisdn'} -o ${bn}_${bp}.trc 2>&1`;

    print "DEBUG: <RESULT>$result</RESULT>" if ($verbose);
    #INFO: TRANSCODE MEDIA 'image_space_iss_gpredict.jpg' bn=image_space_iss_gpredict PROFILE 'image/VAN_JPEG Quality  75   15kB.xml' bp=imageJPEG_Quality_75_15kB
    #<RESULT>MD5:094c482cecf95fc526fd3143b05a76d6
    #OK, 11416 bytes stored in image_space_iss_gpredict_imageJPEG_Quality_75_15kB.trc.
    #</RESULT>
    my ($md5) = ($result =~ m/MD5:([0-9A-Fa-f]+)\n/);
    my ($bytes) = ($result =~ m/.* (\d+) bytes.*/);
    my $cobwebs_content_name = "${bn}_${bp}";

    ## TODO: maybe duplicate md5 detect? quite likely transcoding will give duplicates
    ## cobwebs app will raise alarm, just one entry for md5 in cobwebs allowed (hash store key = md5)
    ## but that is okay - keeping duplicates in fingerprint content might be easier for customer
    if ($md5) {
        print "INFO: md5=$md5 bytes=$bytes\n";
        printf "INFO adding content entry with md5 to cconf file.\n".
            " index=%03d content_name=$cobwebs_content_name md5=$md5\n", 
            $cobwebs_cconf_index;
        printf $cobwebs_cconf_fh "contents.%03d.enabled: 1\n", $cobwebs_cconf_index;
        printf $cobwebs_cconf_fh "contents.%03d.content_name: \"$cobwebs_content_name\"\n", $cobwebs_cconf_index;
        printf $cobwebs_cconf_fh "contents.%03d.md5: \"$md5\"\n", $cobwebs_cconf_index;
        $cobwebs_cconf_index++;
    } else {
        print "ERROR: Didn't get expected md5 value from transcoding.\n";
        if ($result =~ m/\n.*\n/) { $result =~ chomp($result); $result =~ s/^/\n/; $result =~ s/\n/\n    /g; }
        print "ERROR: transcoding result=$result\n";    
    }
}

#[[ ! -x "$TRC_CLI" ]] && { echo "cannot find trc_cli tool $TRC_CLI, check permissions?"; ls -al $TRC_CLI; exit -1; }
#message=OMN_Goals; $TRC_CLI -mode 3 -i ${message}.image -profile "image/VAN_JPEG Quality  75   15kB.xml" -msisdn 353861111111  -o ${message}_PRO15k_MON_mo.trc

close $cobwebs_cconf_fh;

if ($cobwebs_cconf_index == 0) {
    # no transcoding, no fingerprints generated, nothing to load into cobwebs => abort
    print(STDERR "Problem with TRANSCODING, no fingerprints generated, no data to load to cconf. Abort.\n");
    # no to load
    exit -1;
}


###############################
# do the cci create: cci create of the "NEWLY-LOADED-FINGERPRINTS" or specified SELECTOR (if it doesn't already exist)
###############################
my $cobwebs_cconf_sel_path = "corrib_router/cobwebs/selectors/$profileset::profileset{'selector'}";
print "INFO: check SELECTOR $profileset::profileset{'selector'}\n";
my $result = `cci cat $cobwebs_cconf_sel_path 2>&1`;
if ($result =~ m/cci: not found/) {
    if ($result =~ m/\n.*\n/) { $result =~ chomp($result); $result =~ s/^/\n/; $result =~ s/\n/\n    /g; }
    print "INFO: need to create SELECTOR $profileset::profileset{'selector'} cci cat result=$result\n";

    #[omn@vb-48] cci cat corrib_router/cobwebs/selectors/IS-MSG
    #name: "IS-MSG"
    #enabled: 1
    #filter_expr: "!{FROM-STORAGE} && {IS-MSG}"
    #desc: "IS-MSG"
    my $cobwebs_cconf_sel_file = 'tmp_selector.cconf';
    open(my $cobwebs_cconf_sel_fh, '>', $cobwebs_cconf_sel_file) or die "Could not open tmp cconf file for writing:'$cobwebs_cconf_sel_file' $!";
    print $cobwebs_cconf_sel_fh "name: \"$profileset::profileset{'selector'}\"\n";
    print $cobwebs_cconf_sel_fh "enabled: 0\n";
    print $cobwebs_cconf_sel_fh "filter_expr: \"$profileset::profileset{'selector_expr'}\"\n";
    print $cobwebs_cconf_sel_fh "desc: \"$profileset::profileset{'selector'}\"\n";
    close $cobwebs_cconf_sel_fh;

    {
        my $result = `cci create $cobwebs_cconf_sel_path $cobwebs_cconf_sel_file 2>&1`;
        $result = "SUCCESS" if ($result eq "");
        print "INFO: SELECTOR cci create result=$result\n";
        if ($result =~ m/ failed/) {
            print "ERROR: cci create result=$result\n";
            print "EDIT file $cobwebs_cconf_sel_file and run following command to load manually:\n";
            print "cci create $cobwebs_cconf_sel_path $cobwebs_cconf_sel_file\n";
        } else {
            # if success tidy up tmp file
            #unlink $cobwebs_cconf_sel_file or warn "Could not remove temporary file:$cobwebs_cconf_sel_file error:$!";
        }
    }

    {
        my $result = `cci cat $cobwebs_cconf_sel_path 2>&1`;
        if ($result =~ m/\n.*\n/) { $result =~ chomp($result); $result =~ s/^/\n/; $result =~ s/\n/\n    /g; }
        print "DEBUG: SELECTOR cci cat result=$result\n";
    }

}

###############################
# do the cci create: cci create of FINGERPRINT
###############################
print "INFO: cci create $cobwebs_cconf_path $cobwebs_cconf_file\n";
if ($verbose) {
    my $result = `cat $cobwebs_cconf_file`;
    if ($result =~ m/\n.*\n/) { $result =~ chomp($result); $result =~ s/^/\n/; $result =~ s/\n/\n    /g; }
    print "DEBUG: cconf=$result\n";
}

{
    my $result = `cci create $cobwebs_cconf_path $cobwebs_cconf_file 2>&1`;
    if ($result =~ m/\n.*\n/) { $result =~ chomp($result); $result =~ s/^/\n/; $result =~ s/\n/\n    /g; }

    #[omn@vb-48] cci create corrib_router/cobwebs/fingerprints/image_space_iss_gpredict tmp_fingerprint.cconf 
    # e.g. DEBUG cci create result=cci: create failed, file already exists
    # e.g. cci: create operation failed: update of corrib_router/cobwebs/fingerprints/image_space_iss_gpredict not allowed: {{selector:Invalid Link}}
    if ($result =~ m/ failed/) {
        print "ERROR: cci create result=$result\n";
        print "EDIT file $cobwebs_cconf_file and run following command to load manually:\n";
        print "cci create $cobwebs_cconf_path $cobwebs_cconf_file\n";
    } else {
        print "INFO: cci create result=$result\n" if ($result);
        print "INFO: SUCCESSFUL creation of $cobwebs_cconf_path\n";
        # if success tidy up tmp file
        #unlink $cobwebs_cconf_file or warn "Could not remove temporary file:$cobwebs_cconf_file error:$!";
    }
}

# Quick check alarms/state of cobwebs and mist_sti
printf "--More--";
Menu::wait_for_any_key();

print(STDOUT "\n\nCheck message fingerprinting/transcoding status . . . \n");
print(STDOUT "'failed to add fingerprint' is expected in case of duplicate transcoded media.\n");
print(STDOUT `bci -listals  |grep -E "cobwebs|mist|libtrc"`);
print(STDOUT `bci -listsev1s  |grep -E "cobwebs|mist|libtrc"`);

exit 0;

#########################################################################
# End
#########################################################################

