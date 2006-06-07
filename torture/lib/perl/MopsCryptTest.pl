#!/usr/bin/perl -w
#!/usr/bin/perl -I $1/src/itg/multi_mops/lib -w
#!/usr/bin/perl -I ../../lib -w

#  MopsCryptTest.pl
#    Tests for MopsCrypt.pm
#
#  Copyright (C) 2004 Doolin Technologies
#
#  This code is free software; you can redistribute it and/or modify it
#  under the same terms as Perl itself.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  $Id: MopsCryptTest.pl,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

use strict;

use lib "../../lib";
use lib "./lib";
use MopsCrypt;

use constant GPG_SEND_DIR => "/tmp/MopsCryptTest/send";
use constant GPG_RECEIVE_DIR => "/tmp/MopsCryptTest/receive";
use constant GPG_SEND_NAME => "sender";
use constant GPG_RECEIVE_NAME => "receiver";
use constant GPG_SEND_PASS => "senderpassphrase";
use constant GPG_RECEIVE_PASS => "receiverpassphrase";

my (%gpgsend, %gpgreceive);
$gpgsend{dir} = GPG_SEND_DIR;
$gpgreceive{dir} = GPG_RECEIVE_DIR;
$gpgsend{name} = GPG_SEND_NAME;
$gpgreceive{name} = GPG_RECEIVE_NAME;
$gpgsend{pass} = GPG_SEND_PASS;
$gpgreceive{pass} = GPG_RECEIVE_PASS;

my $dosetup = 0;
my $usage = <<END;
usage: $0 [clean]
END

# command arguments can force clean or setup
while ($ARGV[0]) {

    if ($ARGV[0] !~ "clean") {
	die "$usage";
    } else {
	system "rm -rf $gpgsend{dir} $gpgreceive{dir}";
	die "Next time $0 is run gpg dirs will be created and key generation will be done\n";
    }

}


system "date";

my $testcount;
# check prerequisites, we may need to do setup anyway
# test prerequisites setup
if (! -e $gpgsend{dir} || ! -e $gpgreceive{dir}) {
    $dosetup = 1;
    system "rm -rf $gpgsend{dir} $gpgreceive{dir}";
    system "mkdir -p $gpgsend{dir} $gpgreceive{dir}";
    $testcount = 4 + 2 + 2 + 4 + 0 + 0 + 5 + 4;
} else {
    $testcount = 4 + 0 + 0 + 5 + 4;
}

use Test::Simple tests => 4 + 2 + 4 + 4 + 4 + 4;

$gpgsend{mopscrypt} = 
    MopsCrypt->new( 
		    homedir  => $gpgsend{dir}, 
		    #debug => 1,
		    );

$gpgreceive{mopscrypt} = 
    MopsCrypt->new( 
		    homedir  => $gpgreceive{dir}, 
		    #debug => 1,
		    );

ok($gpgsend{mopscrypt}, "MopsCrypt send object created");
ok($gpgreceive{mopscrypt}, "MopsCrypt receive object created");

ok(-e $gpgsend{dir}, "MopsCrypt send dir $gpgsend{dir} created");
ok(-e $gpgreceive{dir}, "MopsCrypt receive dir $gpgreceive{dir} created");

if ($dosetup) {
    &test_keygen();
    &test_key_exchange();
}

&test_set_key_trust();

&test_passhash();
&test_showkey();
&test_sender();
&test_receiver();

my $hexperiment = 0;

sub hexperimentHead() {
    #global $hexperiment;
    my $testtitle = shift;
    print "_-_-_-_-_-_-_-_-_ ======= _-_-_-_-_-_-_-_-_\n";
    print "Hexperiment ".$hexperiment++." $testtitle\n";
}

sub test_passhash() {
    &hexperimentHead("password hashing and verify");

    my $password = "a vrry seekret passwd"; 

    my $hash = $gpgsend{mopscrypt}->password_hash($password);
    #print "Password hash is $hash\n";
    ok($hash =~ "\\\$1\\\$........\\\$......................\$", "password hashed");

    my $ret = $gpgsend{mopscrypt}->password_verify($password, $hash);
    ok($ret, "password hash verified");

    my $retbad1 = $gpgsend{mopscrypt}->password_verify("wrong password", $hash);
    my $retbad2 = $gpgsend{mopscrypt}->password_verify($password, "wrong hash");
    ok(!$retbad1, "incorrect password verify fails");
    ok(!$retbad2, "incorrect password hash verify fails");
}

sub test_showkey() {
    &hexperimentHead("key list");

    my $ret = $gpgsend{mopscrypt}->show_key($gpgsend{name});
#	|| die "key list failed $!";

    ok ( ($ret =~ "pub.*$gpgsend{name}") &&
	 ($ret =~ "sub"), 
	 "list public and private key for $gpgsend{name}" );

    $ret = $gpgsend{mopscrypt}->show_key($gpgreceive{name});

    ok ( ($ret =~ "pub.*$gpgreceive{name}"), 
	 "sender has public key for $gpgreceive{name}" );

    $ret = $gpgreceive{mopscrypt}->show_key($gpgreceive{name});

    ok ( ($ret =~ "pub.*$gpgreceive{name}") &&
	 ($ret =~ "sub"), 
	 "list public and private key for $gpgreceive{name}" );

    $ret = $gpgreceive{mopscrypt}->show_key($gpgsend{name});

    ok ( ($ret =~ "pub.*$gpgsend{name}"), 
	 "receiver has public key for $gpgsend{name}" );

    #print "key list output: $ret\n";
}

use constant MESSAGE_FILE => "/tmp/MopsCryptTest/plain.txt";
use constant ENCRYPT_FILE => "/tmp/MopsCryptTest/encrypted.txt";
use constant DECRYPT_FILE => "/tmp/MopsCryptTest/decrypted.txt";

# TBD fail case encrypt test
sub test_fail_encrypt() {
    &hexperimentHead("sender: encrypt and sign");

    my $message_file = MESSAGE_FILE;
    my $encrypt_file = ENCRYPT_FILE;

    # 1. no file to encrypt
    system "rm -f $encrypt_file"; 

    # example - sender: encrypt sign
    # this presumes there is gnupg dir created already
    # and has private key for current user $gpgsend{name} (for signing)
    # and has an imported public key for $gpgreceive{name} (for encryption)

    # tidy up from previous test
    system "rm -f $encrypt_file"; 
    system "echo \"Plain text message.\nHey diddle diddle,\nThe cat and the fiddle,\nThe cow jumped over the moon.\nThe little dog laughed\nto see such fun,\nand the dish ran away with the spoon.\" > $message_file"; 

    # try to encrypt for non-existant user
    my $notthere = "nobody";
    # $gpgreceive{name} is recipient, $gpgsend{pass} for signing
    my $out = $gpgsend{mopscrypt}->encrypt_and_sign ( $message_file, $encrypt_file, $notthere, $gpgsend{pass} );

    ok($out eq "1", "encrypt_and_sign output $out");
    my $err = $gpgsend{mopscrypt}->get_gpg_error;
    ok($err ne "" &&
       $err =~ "gpg: no public key for $notthere" &&
       $err =~ "gpg: encrypt_message failed",
       "decrypt_and_verify fail case");
}



sub test_sender() {
    &hexperimentHead("sender: encrypt and sign");

    my $message_file = MESSAGE_FILE;
    my $encrypt_file = ENCRYPT_FILE;
    # example - sender: encrypt sign
    # this presumes there is gnupg dir created already
    # and has private key for current user $gpgsend{name} (for signing)
    # and has an imported public key for $gpgreceive{name} (for encryption)

    # tidy up from previous test
    system "rm -f $encrypt_file"; 
    system "echo \"Plain text message.\nHey diddle diddle,\nThe cat and the fiddle,\nThe cow jumped over the moon.\nThe little dog laughed\nto see such fun,\nand the dish ran away with the spoon.\" > $message_file"; 

    # $gpgreceive{name} is recipient, $gpgsend{pass} for signing
    my $out = $gpgsend{mopscrypt}->encrypt_and_sign ( $message_file, $encrypt_file, $gpgreceive{name}, $gpgsend{pass} );
    ok($out eq "1", "encrypt_and_sign output $out");
    if (!$out) {
	my $err = $gpgsend{mopscrypt}->get_gpg_error;
	print "GPG error: $err";
    }

    my $diffyes = `diff -q $message_file $message_file`;
    my $diffno = `diff -q $message_file $encrypt_file`;
    ok(!$diffyes && $diffno, "diff okay and message file != encrypt file");

    my $grepyes = `grep -c "text" $message_file`;
    my $grepno = `grep -c "text" $encrypt_file`;
    chomp($grepyes); chomp($grepno);
    ok($grepyes && !$grepno, "grep okay $grepyes,$grepno and some plain text not in encrypt file");

    my $hdr = `head -n 3 $encrypt_file`;
    my $headmatch = $hdr =~ "-----BEGIN PGP MESSAGE-----
Version: GnuPG .*

";
    my $tail = `tail -n 1 $encrypt_file`;
    chomp($tail);
    my $tailmatch = $tail eq "-----END PGP MESSAGE-----";
    ok($headmatch && $tailmatch, "encrypt file pgp header & footer $headmatch,$tailmatch");
}

sub test_receiver() {
    &hexperimentHead("receiver: decrypt and check signature");

    my $message_file = MESSAGE_FILE;
    my $encrypt_file = ENCRYPT_FILE;
    my $decrypt_file = DECRYPT_FILE;

    # example - receiver: decrypt verify signature
    # for this test gpg has a private key for $gpgreceive{name} passphrase $gpgreceive{pass}
    # (for decryption)

    my $gpgpass = $gpgreceive{pass};

    # tidy up from previous test
    system "rm -f $decrypt_file"; 

    # fail test, try to decrypt unencrypted file
    my $out = $gpgreceive{mopscrypt}->decrypt_and_verify( $message_file, $decrypt_file, $gpgpass );
    ok($out eq "0", "decrypt_and_verify fail case test output $out");
    my $err = $gpgreceive{mopscrypt}->get_gpg_error;
    ok($err ne "" &&
       $err =~ "gpg: no valid OpenPGP data found." &&
       $err =~ "gpg: decrypt_message failed: eof",
       "decrypt_and_verify fail case");

    # TBD? maybe if have time fail tests
    # TBD try to decrypt encrypted file with no matching public key
    # TBD try to decrypt encrypted file with untrusted matching public key
    # TBD try to decrypt encrypted file with unsigned matching public key (TBD this might work)

    # success
    $out = $gpgreceive{mopscrypt}->decrypt_and_verify( $encrypt_file, $decrypt_file, $gpgpass );
    ok($out eq "1", "decrypt_and_verify output $out");

    my $diffyes = `diff -q $message_file $decrypt_file`;
    ok(!$diffyes, "diff okay and message file == decrypt file");


}

sub test_keygen() {
    &hexperimentHead("key generation");

    print "Key generation will take a few seconds ... please expect a delay ...";
# generate keys
#gpg --homedir $GPGHOME -u "$GPGNAME" --gen-key
#gpg --homedir $CUSTGPGHOME -u "$CUSTGPGNAME" --gen-key
#ls -al $GPGHOME $CUSTGPGHOME >>gpgtest.out
#put $GPGHOME $GPGNAME $CUSTGPGHOME $CUSTGPGNAME and passphrases into mops_config.ini

    my $ret = $gpgsend{mopscrypt}->gen_key(
		      passphrase => $gpgsend{pass},
		      name	 => $gpgsend{name},
		      );

    ok($ret,"key gen success for $gpgsend{name} $ret");
    if (!$ret) {
	my $err = $gpgsend{mopscrypt}->get_gpg_error;
	die "gpg error $err\n";
    }

    $ret = $gpgreceive{mopscrypt}->gen_key(
		      passphrase => $gpgreceive{pass},
		      name	 => $gpgreceive{name},
		      email	 => "MopsCryptTest\@doolin.com",
		      comment	 => "MopsCryptTest keygen expect --command-fd iface",
		      );

    ok($ret,"key gen success for $gpgreceive{name} $ret");
    if (!$ret) {
	my $err = $gpgsend{mopscrypt}->get_gpg_error;
	die "gpg error $err\n";
    }

}

sub test_key_exchange() {
    &hexperimentHead("key exchange");

# export keys (just public keys for $gpgsend{name}).
# Note we are not signing the keys (see GnuPG keysigning docs).
#gpg --homedir $gpgreceive{dir} --armor -u "$gpgreceive{name}" --export >$gpgreceive{dir}/exportedkeys.txt
#ls -al $gpgreceive{dir}/exportedkeys.txt >>gpgtest.out
#cat $gpgreceive{dir}/exportedkeys.txt >>gpgtest.out
#gpg --homedir $gpgsend{dir} --armor -u "$gpgsend{name}" --export >$gpgsend{dir}/exportedkeys.txt
#ls -al $gpgsend{dir}/exportedkeys.txt >>gpgtest.out
#cat $gpgsend{dir}/exportedkeys.txt >>gpgtest.out

# send public keys to each other, check sigs
#cp $gpgreceive{dir}/exportedkeys.txt $gpgsend{dir}/keysforimport.txt
#cp $gpgsend{dir}/exportedkeys.txt $gpgreceive{dir}/keysforimport.txt

# import public keys (for encrypting messages to and checking sigs from)
#gpg --homedir $gpgreceive{dir} --import $gpgreceive{dir}/keysforimport.txt
#gpg --homedir $gpgsend{dir} --import $gpgsend{dir}/keysforimport.txt

#gpg --homedir $gpgreceive{dir} --list-keys "$gpgsend{name}" >>gpgtest.out
#gpg --homedir $gpgsend{dir} --list-keys "$gpgreceive{name}" >>gpgtest.out


    # export keys (just public keys for $gpgsend{name}).
    system "gpg --homedir $gpgreceive{dir} --armor -u \"$gpgreceive{name}\" --export >$gpgreceive{dir}/exportedkeys.txt";
    ok(-e "$gpgreceive{dir}/exportedkeys.txt","receiverer public key exported");

    system "gpg --homedir $gpgsend{dir} --armor -u \"$gpgsend{name}\" --export >$gpgsend{dir}/exportedkeys.txt";
    ok(-e "$gpgsend{dir}/exportedkeys.txt","sender public key exported");

    # import public keys (for encrypting messages to and checking sigs from)
    system "gpg --homedir $gpgreceive{dir} --import $gpgsend{dir}/exportedkeys.txt";
    system "gpg --homedir $gpgsend{dir} --import $gpgreceive{dir}/exportedkeys.txt";

}


#[jamesc@betty] ~/src/itg/multi_mops/$ /usr/bin/gpg --homedir /tmp/MopsCryptTest/send --no-greeting --with-colons --no-tty --command-fd 0 --status-fd 1 --yes -o /tmp/MopsCryptTest/encrypted.txt --armor --recipient receiver --sign --encrypt /tmp/MopsCryptTest/plain.txt
#gpg: WARNING: unsafe permissions on homedir "/tmp/MopsCryptTest/send"
#gpg: WARNING: using insecure memory!
#gpg: please see http://www.gnupg.org/faq.html for more information
#[GNUPG:] USERID_HINT BFC70488D5D0AE04 sender
#[GNUPG:] NEED_PASSPHRASE BFC70488D5D0AE04 BFC70488D5D0AE04 17 0
#[GNUPG:] GET_HIDDEN passphrase.enter
#senderpassphrase
#[GNUPG:] GOT_IT
#[GNUPG:] GOOD_PASSPHRASE
#gpg: 0BCCBF6A: There is no indication that this key really belongs to the owner
#[GNUPG:] GET_BOOL untrusted_key.override
#1
#[GNUPG:] GOT_IT
#[GNUPG:] INV_RECP 10 receiver
#gpg: /tmp/MopsCryptTest/plain.txt: sign+encrypt failed: unusable public key
#[jamesc@betty] ~/src/itg/multi_mops/$ 



#[jamesc@betty] ~/src/itg/multi_mops/$ /usr/bin/gpg --homedir /tmp/MopsCryptTest/send --no-greeting --with-colons --no-tty --command-fd 0 --status-fd 1 --yes -o /tmp/MopsCryptTest/encrypted.txt --armor --recipient receiver --sign --encrypt /tmp/MopsCryptTest/plain.txt
#[jamesc@betty] ~/src/itg/multi_mops/$ /usr/bin/gpg --homedir /tmp/MopsCryptTest/send --no-greeting --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --edit-key receiver
#gpg: WARNING: unsafe permissions on homedir "/tmp/MopsCryptTest/send"
#gpg: WARNING: using insecure memory!
#gpg: please see http://www.gnupg.org/faq.html for more information
#pub:-:1024:17:669C2DFFB21A8380:1076601995:0::-:
#fpr:::::::::0C4EF70C550E38CB9A93CC90669C2DFFB21A8380:
#sub::1024:16:6FC40EBC0BCCBF6A:1076601997:0:::
#fpr:::::::::8D0F56D1A4CE7861D5241D596FC40EBC0BCCBF6A:
#uid:?::::::::receiver (MopsCryptTest keygen expect --command-fd iface) <MopsCryptTest@doolin.com>:::S7 S3 S2 H2 H3 Z2 Z1,mdc:1,p:
#[GNUPG:] GET_LINE keyedit.prompt

sub test_set_key_trust() {
    &hexperimentHead("key set trust");

    # now must set trust level of key so gpg is happy to use it to sign(for sender) and check sig(for receiver)
    # unless use ultimate (5) get untrusted message (must enter BOOL)
    #my $ret = $gpgsend{mopscrypt}->edit_key($gpgreceive{name}, "trust", "4" );
    my $ret = $gpgsend{mopscrypt}->edit_key($gpgreceive{name}, "trust", "5" );
    ok($ret,"sender set receive key trust $ret");

    $ret = $gpgreceive{mopscrypt}->edit_key($gpgsend{name}, "trust", "4" );
    ok($ret,"receiver set send key trust");

    #system "echo \"trust\n4\n1\n\" |gpg --homedir $gpgsend{dir} --no-greeting --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --edit-key $gpgreceive{name} trust";

#gpg --homedir $gpgreceive{dir} --list-keys "$gpgsend{name}" >>gpgtest.out
#gpg --homedir $gpgsend{dir} --list-keys "$gpgreceive{name}" >>gpgtest.out

}







=head1 NAME

MopsCryptKeygenTest - set up sender and receiver gpg dirs and keys

=head1 DESCRIPTION

keygen tests are prerequisite for other tests

makes gpg home directories /tmp/MopsCryptTest/send/ /tmp/MopsCryptTest/receive/
generates public & private keypair for send and receive
keygen takes ... maybe 30 seconds? per key. (random prime number generation)
key exchange export/import relevant public keys

=head1 NOTES

http://www.gnupg.org/gph/en/manual.html
The GNU Privacy Handbook

We _can_ generate keys for testing automatically with gpg like this:

gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key <~/test/inputForBogusKeyGen1.txt

gpg --with-colons --no-tty --command-fd 0 --status-fd 1 --yes --gen-key <~/test/inputForBogusKeyGen2.txt

This is kindof undocumented in gpg.
Should not automate passphrases for keygen in normal use.
Okay for testing and used here.
BUT passphrases are in mops_config.ini for decoding of messages.
... but how else to do it automatically ?
I guess okay once machine is secure.

Would be better to have in databases & in mops_config.ini to have keys
stored after hashing them.

passwd and Linux-PAM (see passwdNotes.txt)

objdump -T /lib/libcrypt.so.1 
objdump -T /lib/libpam_misc.so.0

Sho. ?   hash(passwd) and compare with data from 
what is hash func & where get it?
passwd/PAM operation is different ... how does it work now?

mkdir -p /tmp/itg/multi_mops/test
 ?work in there.

1. key generate test (as it takes a while and likes mouse movement and key twiddling)

   don't rm -rf test dir (ever ... ?)
   make clean in test dir would do this

   make test would do 1 if needed (or skip 1 if already there)

   and run other tests


us Make for this?
hmmmm.

sudo less /etc/shadow
yes has hashed passwds



# generate keys
#gpg --homedir $gpgreceive{dir} -u "$gpgreceive{name}" --gen-key
#gpg --homedir $gpgsend{dir} -u "$gpgsend{name}" --gen-key
#ls -al $gpgreceive{dir} $gpgsend{dir} >>gpgtest.out


#put $gpgreceive{dir} $gpgreceive{name} $gpgsend{dir} $gpgsend{name} and passphrases into mops_config.ini

# export keys (just public keys for $gpgsend{name}).
# Note we are not signing the keys (see GnuPG keysigning docs).
gpg --homedir $gpgreceive{dir} --armor -u "$gpgreceive{name}" --export >$gpgreceive{dir}/exportedkeys.txt
ls -al $gpgreceive{dir}/exportedkeys.txt >>gpgtest.out
cat $gpgreceive{dir}/exportedkeys.txt >>gpgtest.out
gpg --homedir $gpgsend{dir} --armor -u "$gpgsend{name}" --export >$gpgsend{dir}/exportedkeys.txt
ls -al $gpgsend{dir}/exportedkeys.txt >>gpgtest.out
cat $gpgsend{dir}/exportedkeys.txt >>gpgtest.out

# send public keys to each other, check sigs
cp $gpgreceive{dir}/exportedkeys.txt $gpgsend{dir}/keysforimport.txt
cp $gpgsend{dir}/exportedkeys.txt $gpgreceive{dir}/keysforimport.txt

# import public keys (for encrypting messages to and checking sigs from)
gpg --homedir $gpgreceive{dir} --import $gpgreceive{dir}/keysforimport.txt
gpg --homedir $gpgsend{dir} --import $gpgsend{dir}/keysforimport.txt

gpg --homedir $gpgreceive{dir} --list-keys "$gpgsend{name}" >>gpgtest.out
gpg --homedir $gpgsend{dir} --list-keys "$gpgreceive{name}" >>gpgtest.out

##################################################################
#weady to wok and woll

#cust side will be wegulawily:

echo "test" >plain.txt

echo "Encrypt" >>gpgtest.out
gpg --homedir $gpgsend{dir} -a -u "$gpgsend{name}" -r "$gpgreceive{name}" -o encryptedAndSignForSend.txt --encrypt --sign <plain.txt
cat encryptedAndSignForSend.txt >>gpgtest.out

#then email that
cp encryptedAndSignForSend.txt mail.txt

#receive side
echo "Decrypt" >>gpgtest.out
gpg --homedir $gpgreceive{dir} -a  -u "$gpgreceive{name}" -o decryptedAndSignChecked.txt --decrypt mail.txt >decrypt.out 2>&1

grep "gpg: Good signature" decryptedAndSignChecked.txt
grep "test" decryptedAndSignChecked.txt
grep "gpg: Good signature" decryptedAndSignChecked.txt >>gpgtest.out
grep "gpg: Good signature" decrypt.out >>gpgtest.out
grep "test" decryptedAndSignChecked.txt >>gpgtest.out
cat decryptedAndSignChecked.txt >>gpgtest.out

###gpg: Good signature from "James Coleman <jamesc@doolin.com>"

echo "Finished" >>gpgtest.out



=cut
