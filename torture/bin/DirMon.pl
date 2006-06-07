#!/usr/bin/perl -w

# A direct kernel hook is cleaner, more resource efficient but less portable.
# e.g. dnotify, watch, changedfiles
# using stat instead of e.g. system("ls") is a good compromise

use strict;

my $verbose;
if ($ARGV[0] =~ /-v/) { 
    $verbose = $ARGV[0]; 
    shift;
}

my $dirToMon = $ARGV[0];
my $scriptToRun = $ARGV[1];
unless ($dirToMon) { die "usage $0 [-v[erbose]] <directoryToMonitor>\n"; }

my @info=stat($dirToMon) or die "Can't stat $dirToMon $!";
my (@newinfo, $x, $changed);
my @what=qw(Device Inum Mode Links Owner Group Rdev Size Atime Mtime Ctime PBlock Blocks);

while (1) {

    #my $whoismessing = system("/sbin/fuser -v $dirToMon");
    my $whoismessing = system("/sbin/fuser $dirToMon");
    if ($whoismessing != 0 && $whoismessing != 256){

	my $pid = $whoismessing;
	# to get here e.g. need to move mouse fast & lots between 2 windows
        # and be patient.   and maybe make sleep less
	print "fuser output: $dirToMon $whoismessing\n" ;
	#my ( $file, $user, $pid, $access, $cmd ) = split( / +/, $whoismessing, 5 );
	#print "file $file user $user pid $pid acc $access cmd $cmd\n";
	#if ( $user) {
	    my $pstree=system ("ps -lf $pid");
	    print $pstree;
	#}
	#my $whops = system ( "ps -fl $whoismessing");
	#print "fuser ps: $whops\n";
    }

    # I don't want to die ... if dir goes away that is fine. It might come back.
    #   die at this stage would kill script that possibly has to be always running.
    #@newinfo=stat($dirToMon) or die "Can't stat $dirToMon $!";
    @newinfo=stat($dirToMon);

    $x=0;
    $changed=0;
    #while ($info[$x]) {    # Aie! It did work ... then strangely rdev was always undefined and AS WELL AS THAT I think printing mtime atime ctime didn't change (though was that after I moved @info = @newinfo; ?
    # declaring it my changed
    # rdev 0  (so while exited when the "type" changed)
    # must've missed printing fields when always getting updated stats
    while ($x < 13) {
	if ($info[$x] ne $newinfo[$x]) {
            $changed = 1;
	    if ($verbose) {
		#system("/bin/echo $x $what[$x] $info[$x] $newinfo[$x]");
		print("/bin/echo $x $what[$x] $info[$x] $newinfo[$x]\n");
	    }
            #fflush STDOUT;
        }
	$x++; #print $x;
    }
    if ($changed) {
        # beware that doing something to this dir (e.g. ls) will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which will do something to this dir which will fire script which ....

# e.g. just like this: (actually fuser doesn't touch file so is OK)
# but equally at this point file has been touched and is not being touvched now
	#my $whoismessing = system("/sbin/fuser -auv $dirToMon");
	#print "fuser output: \n";
	#my $whoismessing = system("/sbin/fuser -v $dirToMon");
	#my $whoismessing = system("/sbin/fuser -v $dirToMon");
	#my $whoismessing = system("/sbin/fuser -u $dirToMon");
	#print "fuser output: $dirToMon $whoismessing\n";
	#my $whops = system ( "ps -fl $whoismessing");
	#print "fuser ps: $whops\n";
	

# a solution might be not to look at atime   (mtime, ctime sufficient)
# can then process file & remove it
# does system wait till other script finishes?
# yes, parent waits for child. That's okay multiple handler scripts will not be called.

# also beware ... what if we fire off handler before file is fully written?
# now we need locking :(  oh dear.
# or use fuser or lsof to make sure file is not used
	if ($scriptToRun) { system("$scriptToRun $dirToMon"); }
	@info=@newinfo;
    }
    if ($verbose) {
	print("slerep $info[6] $info[7] $info[8] $info[9] $info[10]\n");
    }

    # comment sleep out for more inefficient but catch more events
    sleep 1;
}




#
#e.g. ~/bin/DirMon.pl ~/.focus
#
#                     USER        PID ACCESS COMMAND
#/home/jamesc/.focus  jamesc    23116 f....  perl
#my ( $file, $user, $pid, $access, $cmd ) = split( ' ', $_[0], 4 );
