#!/usr/bin/perl -w

# This is a simple IRC bot based on the example in the POE cookbook

# Things:
# + tracking logins/logouts/aways/last active
#   check per-server botnick instead of global one
#   how to deal with Not Talking To Myself stuff?
use strict;

use POE;
use POE::Component::IRC;
use POE::Component::Client::HTTP;
use GDBM_File;
use Fcntl;
use Storable;

use IO::File;

use HTTP::Request;
use HTML::TokeParser;
use URI::Escape;
use POSIX;

# Create the private directory
sub PRIVDIR{ "$ENV{'HOME'}/.officebot" }

-d PRIVDIR or mkdir PRIVDIR, 0700;

use vars qw( %config );

# load the config file, which is just more perl
do( PRIVDIR . "/botrc" ) or die "botrc: " . ("$@"?"$@":("$!"?"$!":"???"));

$config{'debug'} = $ENV{'DEBUG'} if $ENV{'DEBUG'};
$config{'debug'} ||= "";
$config{'triggers'} ||= [];

print STDERR "Running in DEBUG mode\n" if $config{'debug'};
print STDERR "Config:\n" if $config{'debug'};
map { print STDERR "$_ = $config{$_}\n" } sort keys %config if $config{'debug'};
print STDERR "End of config\n" if $config{'debug'};

# These messages are used to respond when the bot doesn't know what
# you've asked it.
my @noclue = (
			  "Huh?",
			  "No idea what you're talking about.",
			  "Does not compute.",
			  "Please. I'm not human.",
                          "Hmm?",
	                  "Uhmmm?",
			 );

# Create the component that will represent an IRC network.
POE::Component::IRC->spawn();

# Default name
$config{'botnick'} ||= "abusebot" . $config{'debug'};

# Create the bot session.  The new() call specifies the events the bot
# knows about and the functions that will handle those events.
POE::Session->new (
				   _start => \&bot_start,
				   _stop => \&bot_stop,
				   irc_connected => \&on_server,
				   irc_disconnected => \&on_disconnect,
				   irc_001    => \&on_connect,
				   irc_433 => \&on_nickused,
				   irc_353 => \&on_names,
				   irc_public => \&on_privmsg,
				   irc_msg => \&on_privmsg,
				   irc_error => \&on_error,

				   irc_join => \&on_join,
				   irc_part => \&on_part,
				   irc_quit => \&on_quit,

				   irc_nick => \&on_nick,

				   irc_ctcp_action => \&on_action,

				   abuse => \&abuse_response,

				   pirate => \&pirate_response,

				   _default => \&_default,
				   signals => \&signals,
                  );

sub _default {
    return unless $config{'debug'};

    if ( $_[ARG0] =~ /^irc_(.*)$/ ) {
        print "IRC $1 received\n";
    } else {
        print "Default caught an unhandled $_[ARG0] event.\n";
    }
    print "Parameters: @{$_[ARG1]}\n" if defined $_[ARG1];

    0;                          # so we don't trap signals
}

sub signals {
    my ( $kernel, $heap, $sig ) = @_[KERNEL, HEAP, ARG0 ];
    print STDERR "Received SIG$sig\n";

    # send a message to all channels about leaving
    my @channels = keys %{$heap->{channel_data}};
    $kernel->call( office=>'privmsg', \@channels, "AIE! dying on SIG$sig!" );

    for my $chan ( keys %{$heap->{channel_data}}) {
        $kernel->call( office => part => $chan );
    }

    $kernel->call( ua => 'shutdown' );
    $kernel->call( office => 'shutdown' );

    0;
}

POE::Component::Client::HTTP->spawn(
									Agent => "abusebot/1.0",
									Alias => "ua",
									Proxy => $ENV{'http_proxy'},
									NoProxy => $ENV{'no_proxy'},
                                   );

# this might be nice, but I can't work it right now.
#$poe_kernel->sig( INT => 'signals' );

# The bot session has started.  Register this bot with the "office"
# IRC component.  Select a nickname.  Connect to a server.
sub bot_start {
    my $kernel  = $_[KERNEL];
    my $heap    = $_[HEAP];
    my $session = $_[SESSION];

    $kernel->post( office => register => "all" );

    do_connects( $kernel );
}

# This actually does the connects. You can specify a list of servers;
# if you don't, it'll connect to all the servers it knows about. This
# is also used as a reconnect routine if a server drops the bot
# connection.
sub do_connects {
    my $kernel = shift;
    my @servers = @_;

    if ( !@servers ) {
        @servers = @{$config{'servers'}};
    } else {
        my @srvs = @servers;
        @servers = ();
        for my $srv ( @srvs ) {
            for my $srvp ( @{$config{'servers'}}) {
                if ( $srvp->{server} eq $srv or grep /^$srv$/, @{$srvp->{aliases}}) {
                    push @servers, $srvp;
                }
            }
        }
    }

    for my $srv ( @servers ) {
        print STDERR "Firing connection to " . $srv->{server} . "\n" if $config{debug};

        $srv->{botnick} ||= $config{'botnick'};

        $kernel->post( office => connect =>
                       {
                        Nick => $srv->{botnick},
                        Username => $config{'botnick'},
                        Ircname => "Waider's abusive POE::Component::IRC bot",
                        Server => $srv->{server},
                        Password => $srv->{password},
                        Port => $srv->{port} || 6667,
                        UseSSL => $srv->{ssl} || 0,
                       }
                     );
    }
}

# When we die... best save those messages, in case there was anything
# important!
sub bot_stop {
    my $heap = $_[HEAP];
}

# The bot has successfully connected to a server; however, we wait for
# the 001 message before doing anything.
sub on_server {
    my $server = $_[ARG0];
    print STDERR "Connected to server $server\n" if $config{'debug'};
}

# Actually connected. Let's join some channels (per config file)
sub on_connect {
    my $server = $_[ARG0];
    my @channels;

    print STDERR "Welcomed to server $server\n" if $config{'debug'};
    # Check what we should be doing on this server
    my @servers = @{$config{'servers'}};

    # The server might be aliased. Really, we should do this with DNS
    # hackery or something.
    for my $srv ( @servers ) {
        $srv->{aliases} ||= [];
        if ( $srv->{server} eq $server or grep /^$server$/, @{$srv->{aliases}}) {
            print STDERR "Found config for this server\n" if $config{'debug'};
            @channels = @{$srv->{channels}};
            last;
        }
    }

    if ( !@channels ) {
        print STDERR "No channels specified for $server.\n";
    } else {
        for my $channel ( @channels ) {
            my %channel_data;
            $channel_data{$channel->{name}} = { password => $channel->{password}};
            $_[HEAP]->{channel_data} = \%channel_data;

            print STDERR "Joining " . $channel->{name} . "\n" if $config{'debug'};
            $_[KERNEL]->post( office => join => $channel->{name}, ($channel->{password})||"" );
        }
    }
}

# Woah! Someone's using our nick!
sub on_nickused {
    my $kernel = $_[KERNEL];
    my $server = $_[ARG0];

    # frob the name and try again
    for my $srv ( @{$config{'servers'}}) {
        if ( $srv->{server} eq $server or grep /^$server$/, @{$srv->{aliases}}) {
            $srv->{botnick} ||= $config{botnick};
            print STDERR
              "Whoops, someone's already called " . $srv->{botnick} . " here on $server\n"
                if $config{'debug'};

            $srv->{botnick} .= "_";
            last;
        }
    }

    print STDERR "Reconnecting to $server\n" if $config{debug};
    do_connects( $kernel, $server );
}

# woop, someone changed their name!
sub on_nick {
    my ( $heap, $sender, $new ) = @_[HEAP, ARG0, ARG1 ];

    my ( $oldnick ) = $sender =~ m/^(.*?)!/;
    $oldnick = quotemeta( $oldnick );

    print STDERR "$oldnick is now known as $new\n" if $config{'debug'};

    my %channels = %{$heap->{channel_data}};
    for my $channel ( keys %channels ) {
        if ( defined( $channels{$channel}->{names} )) {
            my @users = grep !/^$oldnick$/, @{$channels{$channel}->{names}};
            push @users, $new;
            $channels{$channel}->{names} = \@users;
        }
    }
}

# React to an action on the channel. We only act on messages that
# refer directly to the bot.
sub on_action {
    my ( $kernel, $heap, $who, $where, $msg ) = @_[ KERNEL, HEAP, ARG0, ARG1, ARG2 ];
    my $nick = ( split /!/, $who )[0];

    brane( $kernel, $heap, $who, $where, "$nick $msg" );
    return;
}

# Private messages to the bot get responses directed right back at the
# sender; other than that, they're handled by the same code.
sub on_privmsg {
    my ( $kernel, $heap, $who, $where, $arg ) = @_[KERNEL, HEAP, ARG0, ARG1, ARG2];

    brane( $kernel, $heap, $who, $where, $arg );
}

sub brane {
    my ( $kernel, $heap, $who, $where, $msg ) = @_;
    my $nick = ( split /!/, $who )[0];
    my $target = ( $where->[0] eq $config{'botnick'} ) ? $nick : $where->[0];
    my ( $reply, $action );
    my $channel = $where->[0];
    my %channels = %{$heap->{channel_data}};
    my @names;

    # this is awful
    if ( defined( $channel ) and defined( $channels{$channel}->{names})) {
        @names = @{$channels{$channel}->{names}};
    } else {
        push @names, $target;
    }

    my $ts = scalar(localtime);
    logmessage( $heap, $channel, "<" . $nick . ">", $msg );

    if ( $channel eq $config{'botnick'} ) {
        $msg = $config{'botnick'} . ": " . $msg;
    }

    # try to use the trigger config to handle the input
    my @triggers = @{$config{'triggers'}};
    for my $chat ( 0..$#triggers ) {
        my $regexp = $triggers[$chat]->[0];
        $regexp =~ s/%b/$config{'botnick'}/g; # XXX fixme $srv->botnick

        print STDERR "checking [$msg]\n  against [$regexp]\n"
          if $config{'debug'};

        # verify that the regexp is sane
        eval { $msg =~ /$regexp/ };
        if ( $@ ) {
            print STDERR "Broken regexp $regexp\n($@)\n";
            next;
        }

        if ( $msg =~ /$regexp/i ) {
            my @dollar = $msg =~ /$regexp/i;
            $reply = $triggers[$chat]->[1];

            if ( ref( $reply ) eq "ARRAY" ) {
                $reply = $reply->[int(rand(scalar(@{$reply})))]
            } elsif ( ref( $reply ) eq "CODE" ) {
                # danger will robinson
                eval {
                    $reply = &{$reply}( $msg, $nick, $where, @dollar );
                };
                if ( $@ ) {
                    $reply = "coderef returned $@";
                }
                # response directed to a particular channel
                if ( ref( $reply ) eq "ARRAY" ) {
                    $target = $reply->[1];
                    $reply = $reply->[0];
                }
            } elsif ( ref( $reply )) {
                $reply = 'I don\'t yet understand ' . ref( $reply ) .
                  ' triggers';
            }

            if ( defined( $reply )) {
                $reply =~ s/\%n/$nick/g;
                # could make this smarter
                $reply =~ s/\%1/$dollar[0]/g;
                $reply =~ s/\%2/$dollar[1]/g;

                # if it starts with "/me" then it's an action
                if ( $reply =~ s@^/me\s*@@ ) {
                    $action = $reply;
                    undef $reply;
                }

                # if it starts with "/msg $nick" it's a privmsg
                if ( $reply =~ s@^/msg $nick\s*@@ ) {
                    $target = $nick;
                }
            }

            # bail out on first match
            last;
        }
    }

    if ( !defined( $reply ) and !defined( $action )) {
        # See if the bot is being addressed
        if ( $msg =~ /^($config{'botnick'}:\s*)+/ or grep /^$config{'botnick'}$/, @{$where} ) {
            $msg =~ s/^($config{'botnick'}:\s*)//;

            # commands the bot understands
            if ( $msg =~ /reload$/ ) {
                # largely stolen from man perlfunc(1)
                my $return;
                unless ( $return = do( PRIVDIR . "/botrc" )) {
                    $reply = "$nick: couldn't parse botrc: $@" if $@;
                    $reply = "$nick: couldn't do botrc: $!"
                      unless defined( $return ) or $reply;
                    $reply = "$nick: couldn't run botrc"
                      unless $return or $reply;
                }
                $reply ||= "$nick: done!";
            } elsif ( $msg =~ /restart$/ ) {
                # ooog
                my $pid = fork();
                if ( $pid ) {
                    exit;
                } else {
                    # fixme: detach here
                    exec $0;
                }
            } elsif ( $msg =~ /^join\s+(.*)$/ ) {
                my $newch = $1;
                my $pass = "";
                if ( $newch =~ /^(.*?)\s+(.*)$/) {
                    $newch = $1;
                    $pass = $2;
                }
                if ( defined( $heap->{channel_data}->{$newch} )) {
                    $reply = "I'm already there!";
                } else {
                    $reply = "Ok!";
                    $kernel->post( office => join => $newch, $pass );
                    $heap->{channel_data}->{$newch} = {};
                }
            } elsif ( $msg =~ /^leave$/ ) {
                $kernel->post( office => part => $target );
                delete $heap->{channel_data}->{$target};
                print STDERR "Leaving $target\n" if $config{debug};
            } elsif ( $msg =~ /^channels/ ) {
                $reply = "I'm on the following channels:\n ";
                $reply .= join( "\n ", sort keys %{$heap->{channel_data}}) . "\nAnd that's it.";
            } elsif ( $msg =~ /^(find|where is|where's)\s+(\w+)/ ) {
                my $user = $2;
                my @chan = finduser( $heap, $user );
                if ( @chan ) {
                    $reply = "$user is on the following channels:\n ";
                    $reply .= join( "\n ", sort @chan ) . "\nAnd that's it.";
                } else {
                    $reply = "I can't find $user on any of my channels!";
                }
            } else {
                $reply = "$nick: " . $noclue[int(rand( scalar( @noclue)))];
            }
        }
    }

    reply( $kernel, $target, $reply ) if $reply;
    action( $kernel, $target, $action ) if $action;
}

sub reply {
    my ( $kernel, $to, $msg ) = @_;
    my $sent = 0;

    if ( !ref( $to )) {
        $to = [ $to ];
    }

    # allow multi-line messages
    my @lines = split( /[\r\n]+/, $msg );
    for my $ch ( @{$to } ) {
        if ( $ch ne $config{'botnick'}) {
            for $msg ( @lines ) {
                $kernel->post( office => 'privmsg', $ch, $msg );
            }
            $sent = 1;
        } else {
            print STDERR "Refusing to talk to myself!\n";
        }
    }

    print STDERR "No destination for message!\n" unless $sent;
}

sub action {
    my ( $kernel, $to, $msg ) = @_;

    if ( !ref( $to )) {
        $to = [ $to ];
    }

    if ( grep /^$config{'botnick'}$/, @{$to} ) {
        print STDERR "Not sending a message to myself!\n" if $config{'debug'};
        #	$to = CHANNEL;
        return;
    }

    $kernel->post( office => 'ctcp', $to, "ACTION " . $msg );
}

sub abuse_response {
    my ( $kernel, $heap, $request_packet, $response_packet) = @_[KERNEL, HEAP, ARG0, ARG1 ];
    my $req = $request_packet->[0];
    my $res = $response_packet->[0];

    my $content = $res->content;
    my $abuse = "";
    my $victim = shift @{$heap->{abuseme}} if defined( $heap->{abuseme});
    my $channel;
    if ( defined( $victim )) {
        ( $victim, $channel ) = ( $victim->[0], $victim->[1] );
    }
    $channel ||= $victim;       # send it as a private message
    $channel ||= $config{'botnick'}; # last resort; forces it to go to the default channel
    if ( $content ) {
        my $p = HTML::TokeParser->new( \$content );
        $p->get_tag( "font" );
        $abuse = $victim . ": " if $victim;
        $abuse .= $p->get_trimmed_text;
    }

    if ( $abuse ) {
        reply( $kernel, $channel, $abuse );
    } else {
        action( $kernel, $channel, "abuses" . ( $victim ? " $victim" : " people at random" ) . ".");
    }
}

sub pirate_response {
    my ( $kernel, $heap, $request_packet, $response_packet) = @_[KERNEL, HEAP, ARG0, ARG1 ];
    my $req = $request_packet->[0];
    my $res = $response_packet->[0];

    my $content = $res->content;
    my $pirate = "";
    my $victim = shift @{$heap->{pirate}} if defined( $heap->{pirate});
    my $channel;
    if ( defined( $victim )) {
        ( $channel ) = ( $victim->[0], $victim->[1] );
    }

    return unless $channel;

    if ( $content ) {
        if ( $config{'debug'}) {
            print STDERR "PIRACY!\n";
            print $content . "\n";
        }
        my $p = HTML::TokeParser->new( \$content );
        $p->get_tag( "h3" );
        $pirate .= $p->get_trimmed_text;

        $pirate =~ s/^The pirate speaks,"//;
        $pirate =~ s/"$//;
    } else {
        $pirate = "error: " . $res->code . " " . $res->message if $config{'debug'};
    }

    if ( $pirate ) {
        reply( $kernel, $channel, $pirate );
    } else {
        reply( $kernel, $channel, "AAR!" );
    }
}

sub on_join {
    my ( $kernel, $heap, $who, $channel ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
    my $nick = ( split /!/, $who )[0];

    print STDERR "$nick has joined $channel\n" if $config{'debug'};
    logmessage( $heap, $channel, $nick, "has joined $channel" );

    # hacky
    if ( defined( $heap->{messages}->{$nick})) {
        brane( $kernel, $heap, $who, [ $config{'botnick'} ], "any messages?" );
    }

    my ( %channels, @names );
    %channels = %{$heap->{channel_data}} if $heap->{channel_data};
    if ( defined( $channels{$channel} )) {
        @names = @{$channels{$channel}->{names}} if $channels{$channel}->{names};
    }
    push @names, $nick unless grep /^$nick$/, @names;
    $channels{$channel}->{names} = \@names;
    $heap->{channel_data} = \%channels;
}

sub on_quit {
    my ( $kernel, $heap, $who ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
    do_part( $kernel, $heap, $who );
}

sub on_part {
    my ( $kernel, $heap, $who, $channel ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
    $channel =~ s/^(.*?) :.*$/$1/;
    do_part( $kernel, $heap, $who, $channel );
}

sub do_part {
    my ( $kernel, $heap, $who, $channel ) = @_;
    my $nick = ( split /!/, $who )[0];
    my @channels = keys %{$heap->{channel_data}};

    if ( defined( $channel)) {
        @channels = ( $channel );
    } else {
        # irc_quit
        @channels = keys %{$heap->{channel_data}}; # XXX potentially fatal
        $channel = join( ", ", @channels );
    }

    print STDERR "$nick has left $channel\n" if $config{'debug'};
    logmessage( $heap, $channel, $nick, "has left $channel" );

    return if ( $nick eq $config{botnick});

    # remove from all channels
    for $channel ( @channels ) {
        my ( %channels, @names );
        %channels = %{$heap->{channel_data}} if $heap->{channel_data};
        if ( defined( $channels{$channel} )) {
            @names = @{$channels{$channel}->{names}} if $channels{$channel}->{names};
        }
        @names = grep !/^$nick$/, @names;
        $channels{$channel}->{names} = \@names;
        $heap->{channel_data} = \%channels;
    }
}

sub on_disconnect {
    print STDERR "Eeep! Disconnected from $_[ARG0]\n";

    # let's reconnect!
    do_connects( $_[KERNEL], ); #  $_[ARG0] ); xxx
}

sub on_error {
    print STDERR "Eeep! Error: " . $_[ARG0] . "\n";
}

sub on_names {
    my ( $kernel, $heap, $server, $detail ) = @_[KERNEL, HEAP, ARG0, ARG1];
    my ( $channel, $names ) = $detail =~ /^. (.*?) :(.*)$/;
    if ( !defined( $names )) {
        print STDERR "parse failed for $detail\n";
        return;
    }
    my @names = split( /\s+/, $names );
    for my $name ( @names ) {
        $name =~ s/^@//;
        print STDERR "Checking messages for $name\n" if $config{'debug'};
        if ( defined( $heap->{messages}->{$name} )) {
            reply( $kernel, $name, "I have messages for you.\nTo get them, do \"/msg $config{'botnick'} any messages?\"");
        }
    }
    my %channels;
    %channels = %{$heap->{channel_data}} if $heap->{channel_data};
    $channels{$channel}->{names} = \@names;
    $heap->{channel_data} = \%channels;
}

# Run the bot until it is done.
$poe_kernel->run();
exit 0;

# Log a message
#
# figures out which logifle based on the channel specified.
sub logmessage {
    my ( $heap, $channel, $nick, $message ) = @_;
    my %channels = %{$heap->{channel_data}};
    my $logfile = $channels{$channel}->{logfile};

    if ( !defined( $logfile )) {
        $logfile = new IO::File;
        $logfile->open( ">>" . PRIVDIR . "/$channel.log" );
    }

    print $logfile "[" . scalar(localtime) . "] $nick $message\n";
}

sub finduser {
    my ( $heap, $nick ) = @_;
    my %channels = %{$heap->{channel_data}};
    my @channels;

    for my $channel ( keys %channels ) {
        if ( defined( $channels{$channel}->{names})) {
            if ( grep /^$nick$/, @{$channels{$channel}->{names}}) {
                use Data::Dumper;
                print STDERR "adding channel...\n";
                print STDERR Dumper $channels{$channel};
                print STDERR "\n";
                push @channels, $channel
                  unless $channels{$channel}->{password}; # don't list passworded channels
            }
        }
    }

    @channels;
}
