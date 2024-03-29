#!/usr/bin/perl

#http://drhyde.cvs.sourceforge.net/viewvc/drhyde/perlscripts/news2mail-and-mail2news/news2mail?revision=1.1
#http://www.cantrell.org.uk/david/tech/talks/yapc-europe-2007-paper.html
#news2mail looks in $HOME/.news2mail for several items. The most important of those is config.pl, which looks like this:
#
#  'username:password@server.example.com:portnumber' => {
#     'omn.published' =>
#         { post => 'james.coleman@openmindnetworks.com' },
#     'alt.2eggs.sausage.beans.tomatoes.2toast.largetea.cheerslove' =>
#         { post => '2eggs-post@example.com' }
#  },
#  'news.somewhereelse.wherever' => {
#      'local.fart-jokes' => { post => 0 }
#  }
#
# [sudo] cpan -i Net::NNTP::Client Email::Send


use strict;
use warnings;

use Net::NNTP::Client;
use GDBM_File;
use Email::Send;
use Data::Dumper;

use constant DEBUG => 0;

select(STDERR); $| = 1; select(STDOUT);

my $confdir = "$ENV{HOME}/.news2mail";
unless(-d $confdir && -f $confdir.'/config.pl') {
    mkdir $confdir || die("Couldn't create $confdir\n");
    open(FILE, ">$confdir/config.pl") || die("Couldn't create $confdir/config.pl\n");
    print FILE join("\n",
        "smtphost => 'localhost',",
        "address  => 'myaddress\@example.com',",
	"'user:pass\@news.example.com:119' => {",
	"    'misc.test'  => { post => 1 },",
	"    'alt.config' => { post => 1 },",
	"},",
	"'privateserver.localdomain' => {",
	"    'my.secret.newsgroup'  => { post => 1 },",
	"}"
    );
    close(FILE);

    print "You need to configure me!  Take a look in $confdir\n";
    exit;
}

tie my %seen, 'GDBM_File', "$confdir/seen.dbm", GDBM_WRCREAT, 0640;

my $subscriptions = { do $confdir.'/config.pl' };

my $smtphost = $subscriptions->{smtphost};
my $address = $subscriptions->{address};
delete $subscriptions->{smtphost};
delete $subscriptions->{address};

SERVERS: foreach my $server (keys %{$subscriptions}) {
    unless(-d "$confdir/$server") {
        mkdir("$confdir/$server") || die("Can't create $confdir/$server\n");
    }
    my($auth, $host) = split('@', $server);
    ($auth, $host) = (':', $auth) if(!$host);
    my($user, $pass) = split(':', $auth);
    ($host, my $port) = split(':', $host);
    $port ||= 119;
    print "Connecting to $host:$port with credentials [$user,$pass]\n" if(DEBUG);
    my $client = Net::NNTP::Client->new(
        "$host:$port",
	server => $host,
	port   => $port,
        (($user) ? (user => $user, pass => $pass) : ()),
        debug  => 0, # set to 1 by default - hate!
    );
    # refresh groups list if this is a new server or the list is more
    # than 7 days old
    if(!-f "$confdir/groups.$server" || -M "$confdir/groups.$server" > 7) {
	my $list = eval { $client->list() };
	if($@) {
	    print STDERR "$@\n";
	    next SERVERS;
	}
	open(FILE, ">$confdir/groups.$server") || die("Can't write $confdir/groups.$server\n");
	print FILE "$_\n" foreach(sort keys %{$list});
	close(FILE);
	print "Updated groups list, see $confdir/groups.$server\n";
    }

    GROUPS: foreach my $group (keys %{$subscriptions->{$server}}) {

        print "$group: start\n" if(DEBUG);

        my($articles, $firstarticle) = eval { $client->group($group); };
	if($@) {
	    print STDERR "$@\n";
	    next SERVERS;
	}
	if(!-e "$confdir/$server/$group.lastretrieved") {
	    # new subscription, so set lastretrieved to current
            open(FOO, ">$confdir/$server/$group.lastretrieved") ||
	        die("Can't write $confdir/$server/$group.lastretrieved\n");
	    print FOO $firstarticle + $articles - 1;
	    close(FOO);
	    print "New subscription: $server/$group\n  first: $firstarticle\n  articles: $articles\n" if(DEBUG);
	    next GROUPS;
	}
	open(FOO, "$confdir/$server/$group.lastretrieved") ||
	    die("Can't read $confdir/$server/$group.lastretrieved\n");
	chomp(my $lastretrieved = <FOO>);
        $client->nntpstat($lastretrieved);
	close(FOO);
	FETCHNEWS: while(my $msgid = $client->next()) {
            if(exists($seen{$msgid})) { # already got this article
		print "$group: $msgid already seen\n" if(DEBUG);
	        $seen{$msgid} = time(); # update timestamp
		$lastretrieved++;
	        open(FOO, ">$confdir/$server/$group.lastretrieved") ||
	            die("Can't write $confdir/$server/$group.lastretrieved\n");
	        print FOO $lastretrieved;
	        close(FOO);
		next FETCHNEWS;
	    }
	    my $article = [map { chomp; $_; } @{$client->head($msgid)}];
	    # filter based on headers here
	    push @{$article}, '', map { chomp; $_; } @{$client->body($msgid)};

	    print "$group: fetched $msgid\n" if(DEBUG);

	    my @newsheaders;
	    my @headers = (
	        "To: $address",
		"Reply-To: ".
		  ($subscriptions->{$server}->{$group}->{post} || 'dave.null'),
		"X-Newsgroup: $group"
            );
	    while((my $line = shift(@{$article})) ne '') {
		if($line =~ /^\s+/) { $newsheaders[-1] .= $line; }
		 else { push @newsheaders, $line; }
	    }
	    foreach my $line (@newsheaders) {
		if($line =~ /^(Message-Id|Date|Subject|From)/i) {
		    # headers common to mail and news
		    push @headers, $line;
	        } elsif($line =~ /^Path: (.*)$/i) {
                    push @headers, "Received: from $host with NNTP path $1";
		} elsif($line =~ /^References: (.*)$/i) {
		    my @refs = split(/\s+/, $1);
		    push @headers, $line, "In-Reply-To: $refs[-1]";
		} else {
		    push @headers, "X-NNTP-Header-$line";
                }
            }

	    my $body = $article;
            
	    my $sender = Email::Send->new({mail => 'SMTP'});
	    $sender->mailer_args([Host => $smtphost]);
	    $sender->send(
	        join("\n\n",
	            join("\n", sort { $a cmp $b } @headers),
	            join("\n", @{$body})
                )
            );

	    $seen{$msgid} = time(); # so we never fetch this one again
	    $lastretrieved++;
	    open(FOO, ">$confdir/$server/$group.lastretrieved") ||
	        die("Can't write $confdir/$server/$group.lastretrieved\n");
	    print FOO $lastretrieved;
	    close(FOO);
	}
        print "$group: end\n" if(DEBUG);
    }
}

print "optimise seendb\n" if(DEBUG);

# while(my($msgid, $time) = each(%seen)) {
#     if(time() - $time > 2 * 86400) {
#         delete $seen{$msgid};
#     }
# }

# now optimise seendb
# delete anything from 'seen' more than a year old. This is partially for
# dropping cross-posts, (we use lastretrieved to avoid going back in time)
# but also for when a server shits its pants
my %newseen;
$newseen{$_} = $seen{$_} foreach(
    grep { time() - $seen{$_} < 365 * 86400 } keys %seen
);
untie %seen;
unlink "$confdir/seen.dbm";
tie %seen, 'GDBM_File', "$confdir/seen.dbm", GDBM_WRCREAT, 0640;
$seen{$_} = $newseen{$_} foreach(keys %newseen);
untie %seen;

print "finished\n" if(DEBUG);
