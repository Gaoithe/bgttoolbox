#  MopsCrypt.pm
#    - providing a simple object for general encrypt/decrypt needs
#    - interact with GnuPG
#    - do password hashing and verification
#        (as for /etc/passwd /etc/shadow crypt) 
#
#  Copyright (C) 2004 Doolin Technologies
#
#  This module is free software; you can redistribute it and/or modify it
#  under the same terms as Perl itself.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  $Id: MopsCrypt.pm,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

package MopsCrypt;

use strict;

sub new($%) {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %args = @_;

    my $self = {};
    if ($args{homedir}) {
	die ( "Invalid home directory: $args{homedir}\n")
	    unless -d $args{homedir} && -w _ && -x _;
	$self->{homedir} = $args{homedir};
    }
    if ( $args{gnupg_path} ) {
	die ( "Invalid gpg path: $args{gnupg_path}\n")
	    unless -x $args{gnupg_path};
	$self->{gnupg_path} = $args{gnupg_path};
    } else {
	my ($path) = grep { -x "$_/gpg" } split /:/, $ENV{PATH};
	die ( "Couldn't find gpg in PATH ($ENV{PATH})\n" )
	    unless $path;
	$self->{gnupg_path} = "$path/gpg";
    }
    if ($args{debug}) {
	$self->{debug} = $args{debug};
    }

    $self->{error} = "";

    bless $self, $class;
}

sub get_gpg_error {
    my $self = shift;
    return $self->{error};
}


# Interfacing to GPG

# GnuPG::Interface does anonymous file handles, STDIN, STDOUT redirect/attach
#   this module doesn't hide/abstract this mess (for security)
#   to use it need to mess with file handles 
#   see L<perlipc/"Bidirectional Communication with Another Process">

# GnuPG module also forks and does an awful lot of messing with
# file handles and redirection

# these interfaces are quite usable BUT provide more than needed.
# in case of GnuPG::Interface would want to add layer on top
# e.g. GnuPG::Simple to abstract/hide messy file handle stuff

# yes I know I'm a bit silly & rewriting/inventing code. Sigh.
# I kindof got sucked into it. :-7
# other modules use more perl modules (probably all okay, perl internal)
# other modules have user base, have that much testing and usability worked out
# humm :-7


# Tried all below trying to find best way.
# use fork and STDIN/STDOUT redirection?
# use open (GPGCMD, |-) which also spawns a child ?
# use named pipe ? (fifo/lock) ?
# use anonymous file handles
# http://iis1.cps.unizar.es/Oreilly/perl/cookbook/ch16_10.htm

# careful --batch will make gpg not ask
# existing files will be overwritten etc... carefulness required
# ugly :(  especially echo $pass | gnupg --passphrase "this is ignored"
# --passphrase-fd 0 (0 is stdin)
# re --passphrase-fd "Don't use this option if you can avoid it."

# another gpg command line iface method
#bash$ gpg --with-colons --no-tty --command-fd 0 \
#>       --status-fd 1 --yes --gen-key

# and yep cmd line is way all other ifaces go too as there is no lib access
# why no lib is in gpg faq somewhere
# 4.16) Can't we have a gpg library?
# This has been frequently requested. However, the current viewpoint of the GnuPG maintainers is that this would lead to several security issues and will therefore not be implemented in the foreseeable future. However, for some areas of application gpgme could do the trick. You'll find it at <ftp://ftp.gnupg.org/gcrypt/alpha/gpgme>. 
# security through obscurity ?  .... ? a bit.
# not really more of a don't make it easy for users to do stupid things ?
# what are the "several security issues" exactly I wonder?
# can\'t find em.

# http://www.gnupg.org/related_software/gpgme/
# Because the direct use of GnuPG from an application can be a complicated programming task, it is suggested that all software should try to use GPGME instead. 
# oh gosh. yet another interface
# hmmm ... looked at it ... not mature enough



##
#
# TBD: automate test input using --command-fd option of gpg
#
# using --command-fd option of gpg makes this dependant on that gpg interface
# which is not presented directly as an interface to gpg .... 
# from man gpg:
#  --command-fd n
#    This is a replacement for the depreciated shared-memory IPC mode. 
#    If this option is enabled, user input on questions is not expected 
#    from the TTY but from the given file descriptor. It should be used
#    together with --status-fd. See the file doc/DETAILS in the source
#    distribution for details on how to use it.
# 
# http://www.gnupg.org/gph/en/manual.html
# http://www.gnupg.org/documentation/faqs.html
#
#
#gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key <~/test/inputForBogusKeyGen1.txt
#
#gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key <~/test/inputForBogusKeyGen2.txt
#
#gpg --list-keys
#gpg --with-colons --list-keys
#
# Generate keys (interactive - key type, passphrase)
#   (1) DSA and ElGamal (default), 1024 bits., 0 = key does not expire
#
# using --command-fd  really means should parse output as well
# and automate properly. Otherwise tie heavily to order of
# current gpg behaviour.   THOUGH this used for testing
# only SO not a disaster.



##
# sub _call_gpg 
# 
# call gpg with minimal interface
#  all gpg info needed on command line 
#   or 
#  pass passphrase if needed into gpg STDIN
# 

sub _call_gpg {
    my $self = shift;
    my $arg = shift;
    my $pass = shift;
    my $passarg = "";
    my $passpre = "";
    if ($pass) {
	$passarg = "--passphrase 0";
	$passpre = "echo \"$pass\"|";
    }
    my $cmd = "${passpre}$self->{gnupg_path} --no-greeting --no-tty --batch $passarg --homedir $self->{homedir} $arg";
    if ($self->{debug}) {
	print STDERR "$cmd\n";
    }
    my $output = `$cmd`;
    if ($self->{debug}) {
	print STDERR "_call_gpg gpg output: $output\n";
    }
    return $output;
}

##
# sub _expect_gpg 
# 
# call gpg using --command-fd 0 interface
# 
#  e.g.
#
#  $mopscrypt->gen_key(
#	         passphrase => $gpgpass,
#		 name	     => $gpguser,
#		) || die "key generation failed $!";
#
#  # and gen_key function calls _expect_gpg function like this:
#  $self->_expect_gpg(
#            "GET_LINE keygen.algo" => "\r",
#            "GET_LINE keygen.size" => "\r",
#            "GET_LINE keygen.valid" => "\r",
#            "GET_LINE keygen.name" => "$args{name}\r",
#           );
#
#  spawn gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key
#  expect "GET_LINE keygen.algo"
#  send -- "\r"
#  expect "GET_LINE keygen.size"
#  send -- "\r"
#  expect "GET_LINE keygen.valid"
#  send -- "\r"
#  expect "GET_LINE keygen.name"
#  send -- "$username\r"
#  etc...

use IPC::Open3;

sub _expect_gpg($%) {
    my $self = shift;
    my %args = @_;
    my %rethash;

    $self->{error} = "";

    # e.g.  spawn gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key

    if ($args{command}) {

	# child writes to it\'s STDOUT, parent reads this from GPGOUT
	# child reads from it\'s STDIN, parent writes commands to GPGIN
	# we use open3  to connect parent GPGOUT and GPGIN to child STDOUT and STDIN
	my ($gpgcmdfd, $gpgoutfd) = (fileno STDIN, fileno STDOUT);

	my $gpgarg = "--no-greeting --with-colons --no-tty " . 
	    "--command-fd $gpgcmdfd --status-fd $gpgoutfd --yes";
	my $cmd = "$self->{gnupg_path} --homedir $self->{homedir} $gpgarg $args{command}";

	if ($self->{debug}) {
	    print STDERR "$cmd\n";
	}

	# read perldoc perlipc, .... and weep?
	# prone to deadlock among other errors BUT ...
        # know that gpg iface is fixed, don't write until expected GPG end string
	my $pid = open3(*GPGIN, *GPGOUT, *GPGERR, $cmd);
	#my $pid = open(GPGCMD, "|-");
	#my $pid = fork;

	die( "error forking: $!" ) unless defined $pid;

	if ($pid) {   # parent
	    # Parent
	    # talk to child

	    # read from GPGOUT and out to GPGIN (connected with open3 to child STDOUT and STDIN)
	    # child write to STDOUT, parent read from GPGOUT, (this dup to STDOUT also?)
	    # parent write GPGIN, child read from STDIN

	    my $key;
	    while (<GPGOUT>){
		#foreach $args if match write, talk to gdb

		#$self->{error} = $_;

		#if ($self->{debug}) {
		#    print STDERR "From gpg: $_";
		#}

		my $matched = 0;
		foreach $key (keys(%args)) {
		    if (!m/command/ && m/$key/) {
			$matched = 1;

			if (!defined $rethash{$key}) {
			    $rethash{$key}=0;
			} else {
			    $rethash{$key}++;
			}

			if ($self->{debug}) {
			    print STDERR "From gpg expected match: $rethash{$key} $key\n";
			}

			my $cmdtosend = $args{$key};
			if ($cmdtosend ne "") {
			    my @cmdlist = split (/\n/,$args{$key});
			    if ($#cmdlist) {
				if ($rethash{$key} > $#cmdlist) { $rethash{$key} = $#cmdlist; }
				$cmdtosend = $cmdlist[$rethash{$key}];
			    } else {
				$cmdtosend = $args{$key};
			    }

			    # special check if we want to QUIT at a certain stage
			    #if ($cmdtosend eq "QUITNOW") { 
			    #    print GPGIN "quit\nquit\nquit\nquit\n";
			    #    close GPGIN;
			    #}

			    # send response if match
			    print GPGIN "$cmdtosend\n";
			    if ($self->{debug}) {
				print STDERR "      send to gpg: $cmdtosend\n";
			    }

			}

		    }
		}

		# we didn't match something in our expected list
		# this is mostly okay
		# BUT on occasion we get stuck with GPG waiting for input
		# in particular if GPG want's to GET something
		if (!$matched) {
		    if (m/GET/) {
			$self->{error} = "ERROR: From gpg unexpected GET $_";
			print STDERR "$self->{error}\n";
			print STDERR "ERROR: aborting gpg :(\n";
			$rethash{ERROR} = 1;
			$rethash{ABORT} = $_;
			print GPGIN "quit\nquit\nquit\nquit\n";
			close GPGIN;
		    }
		}

	    }

	} else {
	    # not reached (open3 does exec & child never returns from there)
	    #exec($cmd); # a forked (not forked with open2 or open3) child would come here
	    exit();
	}

	close GPGOUT;
	close GPGIN; # TBD is it alright to close fh that might already be closed?

	while (<GPGERR>){
	    #chomp;
	    if (!/gpg: WARNING/ && !/gpg: please see/) {
		$self->{error} .= $_;
	    }
	}
	close GPGERR;

	waitpid $pid, 0
	    or die "error while waiting for child to cross the road: $!\n";

    }

    return \%rethash;
}


sub gen_key()
{
    my $self = shift;
    my %args = @_;
    my $ret = 0;

    # if ($args{email} || $args{comment}) are optional;
    # if pass "" to expect expect will not send \n to gpg
    # messy :-7  TBD: fix it.
    my $email = $args{email}; 
    if (!$email) { $email = " "; }
    my $comment = $args{comment}; 
    if (!$comment) { $comment = " "; }

    if ($args{name} && $args{passphrase}) {
	my $rethash = $self->_expect_gpg(
			   command => "--gen-key",
			   "GET_LINE keygen.algo" => "1",
			   "GET_LINE keygen.size" => "1024",
			   "GET_LINE keygen.valid" => " ",
			   "GET_LINE keygen.name" => "$args{name}",
			   "GET_LINE keygen.email" => "$email",
			   "GET_LINE keygen.comment" => "$comment",
			   "GET_HIDDEN passphrase.enter" => "$args{passphrase}",

			   "BAD_PASSPHRASE" => "",
			   "GOOD_PASSPHRASE" => "",
			   "KEY_CREATED" => "",

			   ) || die "key generation failed $!";

	if ( !$$rethash{ERROR} && defined $$rethash{KEY_CREATED} ) {
	    $ret = 1;
	}

    }

    return $ret;
}      


# using _call_gpg has disadvantage in that we cannot get feedback from gpg
# about success or failure
sub encrypt_and_sign_old {
    my $self = shift;
    my $input_file = shift;
    my $output_file = shift;
    my $recipient = shift;
    $self->_call_gpg("-o $output_file --armor --recipient $recipient --sign --encrypt $input_file");
}

sub decrypt_and_verify_old {
    my $self = shift;
    my $input_file = shift;
    my $output_file = shift;
    my $pass = shift;
    $self->_call_gpg("-o $output_file --decrypt $input_file", $pass );
}

sub encrypt_and_sign {
    my $self = shift;
    my $input_file = shift;
    my $output_file = shift;
    my $recipient = shift;
    my $pass = shift;
    my $cmd = "-o $output_file --armor --recipient $recipient --sign --encrypt $input_file";
    my $rethash = 
	$self->_expect_gpg(
		       command => $cmd,
		       "SIG_CREATED" => "",
		       "BEGIN_ENCRYPTION" => "",
		       "END_ENCRYPTION" => "",
		       "GET_HIDDEN passphrase.enter" => "$pass",
		       "GOOD_PASSPHRASE" => "",
# unless use ultimate (u) (5) trust get untrusted message (must enter BOOL)
#		       "GET_BOOL untrusted_key.override" => "Y\n",   
# TBD careful we are unsecure, we do bad things with untrusted keys
# how, if we get stuck, can we fail?  Timeout.
# if we want timeout we can't read and block :-7
# => make things MORE complicated & select & .... hm.

# we get stuck if key is not signed and not trusted.

# TBD fix this
# TBD fix other TBD + hack
# command checking , pass to expect should be seperate from cmd list
# cmd list needs .... handling for multiple expected and in particular quit for --edit-key trust

# TBD test check and exit if have unusable keys

		       "BAD_PASSPHRASE" => "",
		       ) || die "encryption failed $!";

    if ( !$$rethash{ERROR} && 
	 defined $$rethash{SIG_CREATED} && 
	 defined $$rethash{BEGIN_ENCRYPTION} && 
	 defined $$rethash{END_ENCRYPTION} ) {
	return 1;
    } else {
	return 0;
    } 
}

sub decrypt_and_verify {
    my $self = shift;
    my $input_file = shift;
    my $output_file = shift;
    my $pass = shift;

    my $rethash = $self->_expect_gpg(
		       command => "-o $output_file --decrypt $input_file",
		       "GET_HIDDEN passphrase.enter" => "$pass\n",
		       "GOOD_PASSPHRASE" => "",
		       "GOODSIG" => "",
		       "VALIDSIG" => "",
		       "DECRYPTION_OKAY" => "",
		       ) || die "key generation failed $!";

    if ($self->{debug}) {
	foreach my $key (keys(%$rethash)) {
	    print STDERR "From gpg: $key $$rethash{$key}\n";
	}
    }

    if ( !$$rethash{ERROR} && 
	 defined $$rethash{GOODSIG} && 
	 defined $$rethash{VALIDSIG} && 
	 defined $$rethash{DECRYPTION_OKAY} ) {
	return 1;
    } else {
	return 0;
    } 

}

# Do not need verify sig without decrypt (for now)
#sub verify {
#    my $self = shift;
#    my $input_file = shift;
#    my $pass = shift;
#    my $out = $self->_call_gpg("--verify $input_file", $pass );
#    return $out;
#}

sub show_key {
    my $self = shift;
    my $key = shift;
    my $out = $self->_call_gpg("--with-colons --list-keys $key");
    return $out;
}

#e.g. $ret = $gpgsend{mopscrypt}->edit_key($gpgsend{name}, "trust", "4" );
sub edit_key {
    my $self = shift;
    my $name = shift;
    my $command = shift;
    my $value = shift;

    my $rethash = $self->_expect_gpg(
		       command => "--edit-key $name",

                       # multiple responses to gpg prompt (we use \n as seperator) 
		       # split in the expect function
		       "GET_LINE keyedit.prompt" => "$command\nsave\nquit",

		       "GET_LINE edit_ownertrust.value" => "$value",

                       # bool true is not 1 not t not y is Y
		       "GET_BOOL edit_ownertrust.set_ultimate.okay" => "Y",
		       "GET_BOOL " => "Y",

		       ) || die "key generation failed $!";

    if ( !$$rethash{ERROR} ) {
	return 1;
    } else {
	return 0;
    } 

}

sub password_verify {

    #password passed in or a default for testing & hexperimentation
    my ( $this, $password, $phash ) = @_;

    # get password hash from somewhere
    my $res = crypt($password,$phash);
    #$reswrong = crypt($phash, $password);
    #print "AND $res NOT $reswrong";

    return($res eq $phash);
}

# make password hash that can be stored
sub password_hash {

    # password passed in or a default for testing & hexperimentation
    my ( $this, $password ) = @_;

    # generate salt (for MD5 this is, conforming to what passwd does)
    # this is currently how my redhat 9.1 linux shadow passwd system generates password hashes
    # $1$ then 8 random chars (from [./0-9a-zA-Z]) then $
    # of course we could generate our own style salt
    # e.g. $salt = "\$1\$abcdefgh\$";   $salt = "\$1\$abc\$";   $salt = "Ga";   

    my $salt = "\$1\$";
    $salt .= join("", (".", "/", 0..9, "A".."Z", "a".."z")
		  [rand 64, rand 64, rand 64, rand 64, rand 64, rand 64, rand 64, rand 64]); 

    # or 3 char md5
    #$salt .= join("", (".", "/", 0..9, A..Z, a..z)[rand 64, rand 64, rand 64]); 

    $salt .= "\$";

    # or 2 char des (not md5 (no \$1\$))
    #$salt = join("", (".", "/", 0..9, A..Z, a..z)[rand 64, rand 64]); 

    my $phash = crypt($password,$salt);
    #print "salt $salt passwd $passwd\nhash $phash\n";

    return $phash;
}

1;


=head1 NAME

MopsCrypt - a simple object for general crypto needs

=head1 SYNOPSIS

  #!/usr/bin/perl -w

  use strict;
  use MopsCrypt;

  # example - password hash and verify with hash

  my $gpgdir = "$ENV{HOME}/.gnupg";
  my $mopscrypt = MopsCrypt->new( homedir  => $gpgdir);

  my $password = "a vrry seekret passwd"; 
  print "Password is $password\n";

  my $hash = $mopscrypt->password_hash($password);
  print "Password hash is $hash\n";

  my $ret = $mopscrypt->password_verify($password, $hash);
  print "Password verify is $ret\n";

  my $retbad1 = $mopscrypt->password_verify("wrong password", $hash);
  my $retbad2 = $mopscrypt->password_verify($password, "wrong hash");
  print "Wrong Password verify is $retbad1 $retbad2\n";



  # example - sender: encrypt sign
  # this presumes there is gnupg dir created already
  # and has private key for current user (for signing)
  # and has an imported public key for $gpguser (for encryption)

  my $gpguser = "alphyra";
  my $message_file = "plain.txt";
  my $cipher_file = "encrypted.txt";

  # $gpguser is recipient
  my $out = $mopscrypt->encrypt_and_sign ( $message_file, $cipher_file, $gpguser );


  # example - receiver: decrypt verify signature
  # AND, for this test, (unrealistic) has a private key for $gpguser passphrase $gpgpass (for encryption)

  my $gpgpass = "something";
  my $cipher_file = "encrypted.txt";

  $out = $mopscrypt->verify( $cipher_file, $gpgpass );
  print "STATUS: $out\n";

  $out = $mopscrypt->decrypt_and_verify( $cipher_file, $cipher_file.".decrypted", $gpgpass );
  print "STATUS: $out\n";


=head1 DESCRIPTION

MopsCrypt provides a perl object for interacting with GnuPG,
able to perform functions needed by MOPS

=head1 DESIGN

Want as simple as possible a module which allowed 
crypto functionality we need and demonstrated how
to do the crypt/decrypt/sign/verify.

=head1 DERIVATION & ACKNOWLEDGMENTS

http://www.gnupg.org/gph/en/manual.html
The GNU Privacy Handbook

Looked at many existing perl modules, they could be used
but we want small parts of several modules and want
to write them so code is simple. (see code for more)

Thanks to these module developers, some code here is 
taken and derived from these modules.

  e.g. perl modules

  GnuPG::Interface
  GnuPG 
  Crypt::*lots*  we don't want to do all hard work in perl
   not used, getting old, probably deprecated, but interesting

also interesting and useful is gpg-dialog.pl
Jagadeesh Venugopal gpg-dialog@jagadeesh.org
recommend to help with key management & other gpg work by hand
works grand to interface to GnuPG 1.2.1

=cut
