#!/usr/bin/perl

=head1 NAME

weights40.pl - check you can make each weight from 1 to 40 balance

=head1 DESCRIPTION

This doesn't solve the puzzle but does prove that the solution works.

The puzzle is you have a balance (bilancia in Italian).
And you can choose some unit weights to help weigh things. 
If you get any unit weight from 1 to 40 you need to be able to determine the weight.
 (You have to make the scales balance, you're not allowed to measure 
  it as lighter than w+1 and heavier than w-1 hence is w.) 
What is the minimum number of weights you can do this in ?

If the puzzle is told properly then you probably have to bring the 
balance and weights up a big mountain with dragons on top so you wish to use the absolute minimum 
number of weights (or possibly minimum weight of weights - is it the same answer I wonder?)

=cut 

my @weights = ( 1, 3, 9, 27 );

for(my $w=-1; $w<=41; $w++) {

    # brute force, try balance all permutations, weights on both sizes

    # try position of not there, left, right for each weight 
    my @weight_pos = ( 0, 0, 0, 0 );
    my $wi = 0;

    # print terrible message if not found otherwise might miss one 
    my $terribleness = "BAH! :( not good, no match for $w\n";
    my $found = 0;

    for($weight_pos[0]=0; $weight_pos[0]<3 && $found==0; $weight_pos[0]++) {
    for($weight_pos[1]=0; $weight_pos[1]<3 && $found==0; $weight_pos[1]++) {
    for($weight_pos[2]=0; $weight_pos[2]<3 && $found==0; $weight_pos[2]++) {
    for($weight_pos[3]=0; $weight_pos[3]<3 && $found==0; $weight_pos[3]++) {

	# start with $w always on left
	my $left_tot = $w;
	my $right_tot = 0;
	my @leftside = ( $w );
	my @rightside = ();

	# print '$#weights is ' . $#weights . " (number of elements in weights array)\n";

	# put weights on balance
	for($wi=0;$wi<=$#weights;$wi++) {

	    #print "dbg w=$w wi=$wi pos=$weight_pos[$wi]\n";

	    if ($weight_pos[$wi] == 1) {
		#printf "L";
		push @leftside, $weights[$wi]; 
		$left_tot += $weights[$wi];
	    } elsif ($weight_pos[$wi] == 2) {
		#printf "R";
		push @rightside, $weights[$wi]; 
		$right_tot += $weights[$wi];
	    }
	    #$ls += "(".$weights[$wi].) ";
	    #$rs += "(".$weights[$wi].) ";
	}

	
	#print "dbg w: $w, balance $left_tot = $right_tot, left: @leftside - right: @rightside\n"; 

	if ($left_tot == $right_tot) {
	    print "w: $w, balance $left_tot = $right_tot, left: @leftside - right: @rightside\n"; 
	    $terribleness = "";
	    $found = 1;
	    break;
	}

    }
    }
    }
    }

    print $terribleness;
}

