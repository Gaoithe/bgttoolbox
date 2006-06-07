#!/usr/bin/perl -w

# TODO: script to do festival by itself
# TODO: script to say hey! you're marked away but you're NOT (focus changing recently)
#  monitor focus and graph for fun and easytimer toognuplot web iface?
#  what's that generic tool to generate stats & graphs?  mrtg that's what it's called!
# TODO: configurable/learn coffee alerts

my $name = "xchat-alert.pl from hacked Waider's XChat hacks";
my $version = "0.1";

# log xchat when not paying attention to my $rtmsgfile = "$ENV{'HOME'}/.rtmessages";
# rt reads that and puts it on root window
# alerts on /msg messages to $user OR if $user is addressed in a channel OR if coffee is mentioned
# alerts fire up xsplash
# no festival here

# Register only if we're not already registered. Durr. Can't do that, can we?
IRC::register( $name, $version, "", "" ); # name, version, shutdown routine, unused
IRC::print "chathack: Loading $name $version\n";
IRC::print "chathack: Registering handlers...";
IRC::add_message_handler( "PRIVMSG", "privmsg_handler" );
IRC::add_message_handler( "msg", "privmsg_handler" ); # msg is IRC message/numeric code
IRC::add_command_handler("xchat_alert_debug", "xchat_alert_debug");
IRC::print "chathack: Registering handlers...done.\n";

my $user = $ENV{USER};
my $home = $ENV{HOME};

my $xchat_alert_hist_file = "xchat_alert.log";

my $msgcounter = 0;
my $msgtime = 0;
my $msgthrottle = 30; # 30 sec throttle

my $debug = 0;
sub xchat_alert_debug {
  $debug = shift;
  IRC::print "chathack: debug is $debug\n";  
  return 1; # return 1 so xchat doesn't look for an internal xchat_alert_debug command ? TODO
}

# actually handler for every message
# xsplash it if someone mentions coffee or if message for me and I'm not listening
sub privmsg_handler {
  my ( $sender, $type, $channel, $message ) = split( ' ', $_[0], 4 );
  my $random;

  # e.g. $line
  # :jamesc!~jamesc@betty.dev.ie.alphyra.com privmsg jamesc :test
  #nick_privmsg_handler(@_);
  #IRC::print "chathack: xchat-alert debug\n";

  # Now clean things up
  $message =~ s/^://;
  ( $sender, undef ) = parse_sender( $sender );

  if ($sender == "$user" && $mesage !~ "forget") {
      if ($message =~ /$user is away/ ) {
	  $tellabusebot = $message;
	  $tellabusebot =~ s/$user is /$user is not /;
	  IRC::command("/msg abusebot $tellabusebot");
	}
      if ($message =~ /$user is back/ ) {
	  $tellabusebot = $message;
	  $tellabusebot =~ s/$user is /$user is not /;
	  IRC::command("/msg abusebot $tellabusebot");
	}
  }


  #IRC::print "chathack: xchat-alert debug $sender m $message\n";
  # Ignore "foo is back" messages.
  return if $message =~ /^.ACTION/;



#TODO: abusebot clean ups?
# /away => abusebot forget jamesc is back .*
# /back => abusebot forget jamesc is away .*
#/msg abusebot tell me about $user
  if ($sender == "abusebot") {
      if ($message =~ /$user is away/ ) {
	  $tellabusebot = $message;
	  $tellabusebot =~ s/I hear that //;
	  $tellabusebot =~ s/$user is /$user is not /;
	  IRC::command("/msg abusebot $tellabusebot");
	}
      if ($message =~ /$user is back/ ) {
	  $tellabusebot = $message;
	  $tellabusebot =~ s/I hear that //;
	  $tellabusebot =~ s/$user is /$user is not /;
	  IRC::command("/msg abusebot $tellabusebot");
	}
  }
#http://www.xchat.org/docs/xchat2-perldocs.html
#http://masaka.cs.ohiou.edu/~eblanton/files/auto-op.pl



  # check focus generated by fvwm (window manager)
  #*FvwmEvent: focus_change "Current Exec perl -l -e 'print join( chr(0), @ARGV )' $n $c $w > $HOME/.focus"
  #e.g. jamesc@betty:~/src/itg/multi_mopsXTerm0x1800026
  # chathack: fvwm focus title jamesc@betty:~/src/itg/multi_mops class XTerm id 0x1800026
  #e.g. sEmascsexeseven Emacs 0x22000d8
  #e.g. chathack: fvwm focus title X-Chat [1.8.11]: Dialog with abusebot @ kinsey.dev.ie.alphyra.com class X-Chat id 0x2000182

  if ( open( FILE, "<$ENV{'HOME'}/.focus" )) {
        my $focus = <FILE>;
        close( FILE );
        my ( $title, $class, $id ) = split( chr(0), $focus ); chomp($id);
	IRC::print "chathack: fvwm focus title $title class $class id $id\n" if ($debug); 

	#alerts when in xchat but not watching particular channel
	#IRC::print "chathack: check channel with $channel not in title\n" if ($debug); 
        #if ( $title =~ /with $channel/ && $class =~ /^X-Chat$/ ) {
	IRC::print "chathack: check class $class == X-Chat?\n" if ($debug); 
        if ( $class =~ /^X-Chat$/ ) {
          return; # no need, I'm already paying attention
          #return if (!$debug); # no need, I'm already paying attention
        } else {
          $random = "$class not X-Chat, $title =?= $channel";
        }
  }

  my $rtmsgfile = "$ENV{'HOME'}/.rtmessages";
  if ( -e $rtmsgfile ) {
      if ( open( RTFILE, ">>$rtmsgfile" )) {
	  #my $stort = "xchat<" . sprintf("%8s",$sender) . ">|";
	  my $stort = "$channel<" . sprintf("%8s",$sender) . ">|";
	  print RTFILE "$stort $message\n";
	  close RTFILE;
      } else {
	  IRC::print "chathack: hey! can\'t open $rtmsgfile ?\n";
      }
  }

  # TODO: use different script to trigger on dictionary and lookup word
  if ( $type =~ /PRIVMSG/ && ( $message =~ /word/i || $message =~ /dictionary/ ) ) {
      #parse
      #wget 
      #print
  }

  if ($channel !~ /^#/) {
      IRC::print "chathack: message not ^# type is $type channel is $channel\n";
  }
  IRC::print "chathack: message type is $type channel is $channel\n" if ($debug); 
  # special notifications for a privmsg or for "jamesc" or "coffee"
  if ( $type =~ /PRIVMSG/ && ( $channel =~ /^$user/ || $channel !~ /^\#/ || $message =~ /^$user/i || $message =~ /coffee/ ) ) {
      my $coffee = "";
      $now=time();

      if ($now - $msgtime > $msgthrottle) {   
	  $msgtime = time();
	  $msgcounter++;

	  # drawled out coffeeeeee!
	  # nihongo kohi or cohi
	  # waider has a tendancy to say cawwwfeee these days (Amurrikin accent?)
	  # TBD: upper/lower case
	  # TBD: more languages!
	  if ($message =~ /coffee/ ) {
	      #|| $message =~ /[ck]o+h[ei]+/ 
	      #|| $message =~ /[kc][oaw]+[fh][ei]+/) { 
	      $coffee = "COFFEE! COFFEE! COFFEE! COFFEE! COFFEE!"; 
	  }

	  my $xspfont = "-adobe-new*school*-bold-r-normal--34*";
	  system( "xsplash -timeout 5 -text '$coffee $sender/$channel/$message' -font \"$xspfont\" &" );
	  #system( "sh -c \"xsplash -timeout 5 -text '$coffee $sender/$channel/$message' -font \"$xspfont\" &\"" );

	  system "echo \"xsplash:$msgcounter:$now\">>$xchat_alert_hist_file";
	  system "echo \"message:$sender/$channel/$message $coffee\">>$xchat_alert_hist_file";

	  IRC::print "chathack: hitting xsplash $coffee $sender $channel $message\n" if ($debug); 
	  #IRC::print "chathack: $random\n" if $random;
      }

  }

  return;
}

# split sender into nick / user@host
sub parse_sender {
  my $sender = shift;
  $sender =~ m/^:(.*?)!(.*)$/;
}

IRC::print("chathack: Loaded xchat-alert $name $version\n");
IRC::print "chathack: xchat_alert_debug $debug\n";

