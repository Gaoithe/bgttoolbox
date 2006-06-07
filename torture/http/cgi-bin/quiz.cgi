#!/usr/bin/perl -w

#############################################################################
# hacked FROM: Quiz Me! Fun Internet Quizer Version 0.6, from MikeSpice.com
#############################################################################

use CGI qw(:standard);
srand(time);

print_http_type();
#print "YEAH got HERE! 0 $0 1 $1 2 $2 ARGV0 is $ARGV[0] ARGV1 is $ARGV[1]\n";
# how do we tell if we are on command line or in browser?

$cur=CGI->new();
#use Data::Dumper; print "cgi obj ". Dumper($cur);# if ($debug);

my ($logo, $title, $bgcolor, $tablecolor, $darkrowcolor, $gradeby, $mode );
my $quiz_file;
my $commandline;

my $debug = 0;
getconfig();

if($mode eq "grademe") {
    printstart();
    $debug = 1;
    grademe();
    $debug = 0;
}

if($quiz_file =~ /\.ascii$/) { 
    readasciiquiz($quiz_file);
} else {
    readdatquiz($quiz_file);
}

if($mode eq "default") {
    printstart();
    # TODO: print quiz command line OR html
    # TODO: print quiz questions one by one or all together
    # TODO:  answer info straight after question OR all together at end
    printquiz();
    # TODO:  answer info at end, present original question and options 
    #  + correct answers for incorrect questions
}

if($mode eq "grademe") {
    printstart();

#print "mode: $mode\n"; exit;

    printwronganswers();
}

printend();

exit;

# TODO: not secure (ANSWERS and points with question in form)


sub getconfig {

    $mode = "default";

    #setting default values in case they are not in the config file
    $title= "Quizzy quiz quiz";
    $logo= "";
    $bgcolor = "#FFFFFF";
    $tablecolor= "#E0D5E5";
    $darkrowcolor= "#A967E2";
    $gradeby = "percent";

    while (defined($ARGV[0])) {

	# both called from cmd line and browser
	print "YEAH got HERE! ARGV0 is $ARGV[0]\n";
	if ($ARGV[0] =~ "-d") {
	    $debug = shift(@ARGV);
	} elsif ($ARGV[0] =~ "-t") {
	    $commandline = shift(@ARGV);
	} elsif ($ARGV[0] =~ "-m") {
	    shift(@ARGV);
	    $mode = shift(@ARGV);
	} else {
	    if (!defined($quiz_file)) {
		$quiz_file = shift(@ARGV);
		print "YEAH got HERE TOO $quiz_file" if ($debug);
	    } else {
		die "unknown param " . shift(@ARGV) . "\n";
	    }
	}

    }

    #getting config file
    if (!defined($quiz_file)) {

	print_http_type() if (!defined($commandline));

	if($cur->param("quiz")) {
	    $quiz_file = $cur->param("quiz");
	} else {
	    dietext("You must specify which quiz you would like to take.");
	    # TODO: set default file quiz.dat 
	    # better: write a form, choose quiz

	    html_form_top("Choose quiz to take");

	    for my $q (@quizfiles) {

		##use Data::Dumper; print "QDUMP ". Dumper($q);# if ($debug);
		my $qfn = $q->{name};

		html_form_orow("quiz",$qfn,$qfn);

	    }
	    
	    html_form_lrow("Go!");

	}
    }

    if (! -f $quiz_file) {
	$quiz_file .= ".dat";
    }

    if($cur->param("mode")) {
	$mode = $cur->param("mode");
    }

    #my $texthex = join("", map { sprintf "%02x", $_ } unpack("C*",$quiz_file));
    #my $err = "name: $quiz_file, hex of name: " . $texthex;
    #dietext("Ngeh: $err");


    #if (defined($quiz_file)) {
	#unless($quiz_file=~ /^[a-z]+$/i){
	#    dienice("Possible hack detected!  Please use only
	#		letters for the quiz_file!");
	#}
    #}
	
    open(CONFIG,"$quiz_file") 
	|| dietext("Could not open quiz file $quiz_file.");
    flock(CONFIG,2); #keep others from messin while we are here

    while(<CONFIG>) {
	chomp;
	if($_ =~ /^\#/) {
	    $_ =""; #make sure that I ignore all commented lines
	}
	if($_ =~ /^title\s*=\s*/) {
	    ($nothing,$title)=split(/=/,"$_");
	}
	if($_ =~ /^logo\s*=\s*/) {
	    ($nothing,$logo)=split(/=/,"$_");
	}
	if($_ =~ /^background\s*=\s*/) {
	    ($nothing,$bgcolor)=split(/=/,"$_");
	}
	if($_ =~ /^tablecolor\s*=\s*/) {
	    ($nothing,$tablecolor)=split(/=/,"$_");
	}
	if($_ =~ /^darkrowcolor\s*=\s*/) {
	    ($nothing,$darkrowcolor)=split(/=/,"$_");
	}
	if($_ =~ /^gradeby\s*=\s*/) {
	    ($nothing,$gradeby)=split(/=/,"$_");
	}
	
			
    }
    close(CONFIG);
}

my ($totalpoints, $highest_value);
my @questions; #an array, an array of references
#$questions[0..n]->{question};
#$questions[0..n]->{answer}->[0..n]->{text};
#$questions[0..n]->{answer}->[0..n]->{points};
#$questions[0..n]->{answer}->[0..n]->{explain};
#$questions[0..n]->{explain};

sub readdatquiz {

    my $quiz_file = shift;

    open(CONFIG,"$quiz_file") 
	|| dienice("Could not find quiz file $quiz_file: $!");
    flock(CONFIG,2);
    $newquestion = 0; 
    #is this a new question?  use this to add up total possible points
    $totalpoints = 0; # total possible points.
    $highest_value = 0; # the highest value for each question
    $question_number = -1;

    while(<CONFIG>) {
	chomp;

	if($_ =~ /^\#/) {
	    $_ =""; #make sure that I ignore all commented lines
	}

	if($_ =~ /^[qQ]=/) {
	    $newquestion = 1; $answer_number = -1;
	    $question_number++;
	    $totalpoints = $totalpoints + $highest_value;
	    $highest_value = 0;
	    ($nothing,$question) = split(/=/,"$_");

	    $questions[$question_number]->{question} = $question;
	    $questions[$question_number]->{number} = $question_number;
	    #TODO set $questions[$question_number]->{explain};
	}

	if($_ =~ /^[aA]=/) {
	    $newquestion = 0;
	    $answer_number++;
	    ($nothing,$answer,$answer_value) = split(/=/,"$_");

	    my $current_answer = \$questions[$question_number]->{answer}[$answer_number];

	    $$current_answer->{text} = $answer;
	    $$current_answer->{points} = $answer_value;
	    # TODO sometimes individual explainations of answers $$current_answer->{explain};

	    if($answer_value > $highest_value) {
		$highest_value = $answer_value;
	    }
	}
	
    }
    close(CONFIG);

    use Data::Dumper; print "QDUMP ". Dumper(@questions) if ($debug);

    if($newquestion == 0) { 
        # in most cases, we need to add the highest value of the last question
	$totalpoints = $totalpoints + $highest_value;
    }

    # remember $question_number is one less than you might think

}


sub readasciiquiz {

    my $quiz_file = shift;
    my $filetitle;

    open(CONFIG,"$quiz_file") 
	|| dienice("Could not find quiz file $quiz_file: $!");
    flock(CONFIG,2);
    $newquestion = 0; 
    #is this a new question?  use this to add up total possible points
    $totalpoints = 0; # total possible points.
    $highest_value = 0; # the highest value for each question
    $question_number = 0;
    $solution_number = 0;

    $suppressquestseqwarn=0;
    $suppresssolseqwarn=0;

    $qflag=0; $aflag=0;

    my $current_answer;

    my ($crud,$white,$rest);

    while(<CONFIG>) {
	chomp;

	#if($_ =~ /^\#/) {
	#    $_ =""; #make sure that I ignore all commented lines
	#}

	# magic removal of crud at start of pages
	# BE CAREFUL
	# crud can be useful to make sure nothing is wrong
	s/\f[\s\w:]+\sPage\s(\d+)//g; 
	#s/\f[\s\w:]+\sPage\s(\d+)/Page$1/g; 

	#s/[\s\w:]+\sPage\s(\d+)/Page$1/g;
	#s/Page\s(\d+)/Page$1/g;
	#s/Page\s(\d+)//g;

	#if(defined($filetitle) && $filetitle) {
	#    # magic removal of crud at start of pages
	#    s/$filetitle[\s\w:]+\sPage\s(\d+)/Page$1/g;
	#}

	s/Answers:\s+\w+[\s\.]+\.(\s\s+)//g; 
	#s/Answers:\s+\w+[\s\.]+\.(\s\s+)/Answers:$1/g; 

	while ($_) {

            # SPLIT WHOLE THING UP ON TWO-SPACE+ TOKENS	

	    if (m/^(\d+)\s\s+([A-H])\s\s+/) {

		$solution_number++;

		# SOLUTION ANSWERS
		($qnum,$anum,$_) = m/(\d+)\s\s+([A-H])\s\s+(.*)/;
		print "solution: $qnum, $anum\n" if ($debug);
		($solution,$_)=split(/\s\s+/,$_,2);
		print "sol: $solution\n" if ($debug);

		if (!$suppresssolseqwarn && $qnum != $solution_number) {
		    warn "AIE! $qnum and $solution_number should match";
		    $suppresssolseqwarn=1;
		}

		#$questions[$qnum]->{solution} = $solution;
		$questions[$solution_number]->{solution} = $solution;

		$questions[$solution_number]->{solution} = $solution;
		$questions[$solution_number]->{correctanswer} = $anum;
		$questions[$solution_number]->{answer}[unpack("C",$anum)-65]->{points}=1;

	    } elsif (m/^(\d+)\s\s+/) {

		warn "WAUGH we match a question within solutions or vice-versa".
		    "something smells rotten :(" if ($solution_number>0);

		$question_number++;

		($qnum,$_) = m/(\d+)\s\s+(.*)/;
		print "qnum: $qnum\n" if ($debug);

		if (!$suppressquestseqwarn && $qnum != $question_number) {
		    warn "AIE! $qnum and $question_number should match";
		    $suppressquestseqwarn=1;
		}

		#($question,$_) = m/((^\s\s))\s\s+([\S].*)$/g;
		($question,$_)=split(/\s\s+/,$_,2);
		print "q: $question\n" if ($debug);

		$qflag = 1; $aflag=0;

		#while ($_ !~ "[A-H]\.^") {
		#    ($moreq,$_)=split(/\s\s+/,$_,2);
		#    $question .= " " . $moreq;
		#}

		$answer_number = 0;
		$questions[$question_number]->{question} = $question;
		$questions[$question_number]->{number} = $question_number;
		$totalpoints++;

		#if ($qnum - 1 ne $question_number ) {
		#    warn "QUESTION NUMBER $qnum out of sequence? ".
		#	"expected $question_number + 1. parse error?";
		#}

	    } elsif (m/^([A-H])\.\s\s+/) {

		warn "WAUGH we match a question within solutions or vice-versa".
		    "something smells rotten :(" if ($solution_number>0);

		($anum,$_) = m/([A-H])\.\s\s+(.*)/;
		print "anum: $anum\n" if ($debug);
		($answer,$_)=split(/\s\s+/,$_,2);
		print "ans: $answer\n" if ($debug);

		$current_answer = \$questions[$question_number]->{answer}[$answer_number];
		$$current_answer->{id} = $anum;
		$$current_answer->{text} = $answer;
		$$current_answer->{points} = 0;

		$qflag=0; $aflag=1;

		$answer_number++;

	    } else {

		# crud at start 

		# or crud in middle? last double space in middle of question or answer? oerrr :(

		#($before,$_) = m/(.*)\s\s+([\S].*)$/g;
		($before,$_)=split(/\s\s+/,$_,2);

		print "crud: $before\n" if ($debug);

		if ($solution_number>0) {
		    $questions[$solution_number]->{solution} .= " ".$before;
		} elsif ($qflag) {
		    $questions[$question_number]->{question} .= " ".$before;
		} elsif ($aflag) {
		    $$current_answer->{text} .= " ".$before;
		} else {
		    $crud .= $before;
		    if(!defined($filetitle) || ! $filetitle) {
			$filetitle = $crud;
			print "ftitle: $filetitle\n" if ($debug);

			#if(defined($filetitle) && $filetitle) {
			#    # magic removal of crud at start of pages
			#    $_ =~ s/$filetitle[\s\w:]+\sPage\s(\d+)/Page$1/g;
			#}

		    }	
		    print "crud: $crud\n" if ($debug);
		}

	    }

#YEAH got HERE! ARGV0 is scope.ascii ftitle: crud: ftitle: ftitle: Sample Questions crud: Sample Questions ftitle: Sample Questions crud: Sample QuestionsScopeSample Questions: Scope ftitle: Sample Questions crud: Sample QuestionsScopeSample Questions: ScopePage2 Sample Questions: Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ftitle: Sample Questions

	    # TODO sometimes individual explainations of answers $$current_answer->{explain};

	}
	
    }
    close(CONFIG);

    if(defined($filetitle) && $filetitle) {
	$title = $filetitle;
    }

    use Data::Dumper; print "QDUMP ". Dumper(@questions) if ($debug);

    if($newquestion == 0) { 
        # in most cases, we need to add the highest value of the last question
	$totalpoints = $totalpoints + $highest_value;
    }

    # remember $question_number is one less than you might think

}


sub printquiz {
    if (defined($commandline)) {
	printquiztext();
    } else {
	printquizhtml();
    }
}

sub printwronganswers {
    if (defined($commandline)) {
	printwronganswerstext();
    } else {
	printwronganswershtml();
    }
}

sub printquizhtml {

    html_form_top($title);

    for my $q (@questions) {

	##use Data::Dumper; print "QDUMP ". Dumper($q);# if ($debug);
	my $question = $q->{question};
	my $qnum = $q->{number};
	
	html_form_qrow($qnum,$question);

	my $opt = 0;
	while (my $a = $q->{answer}->[$opt]) {

	    $opt++;
	    ##use Data::Dumper; print "QADUMP ". Dumper($a);# if ($debug);

	    my $anum = $a->{id};
	    my $answer = $a->{text};
	    my $answer_value = $a->{points};
	    # TODO sometimes individual explainations of answers $$current_answer->{explain};

	    html_form_orow("answer$qnum",$anum,$answer,$answer_value);

	}
	
    }

    print <<HTML;
    <tr bgcolor="$darkrowcolor">
	<td align="middle" colspan=2><font color=white>
	<input type="hidden" name="quiz" value="$quiz_file">
	<input type="hidden" name="question_number" value="$question_number">
	<input type="hidden" name="total" value="$totalpoints">
	<input type="hidden" name="mode" value="grademe">
	<input type="submit" value="Grade Me!">
	</font></td>
	</tr>
	</table>
	</form>
	</center>
HTML
;

}


sub printwronganswershtml {

    # gradme must be called first to populate question results 
    # $questions[$i]->{givenanswer} = $answer;
    # $questions[$i]->{givenanswerpoints} = $points;

    # readasciiquiz populates:
    #$questions[$solution_number]->{solution} = $solution;
    #$questions[$solution_number]->{correctanswer} = $anum;
    #$questions[$solution_number]->{answer}[unpack("C",$anum)-65]->{points}=1;

    html_form_top($title);

    for my $q (@questions) {

	if (defined($q->{number}) && defined($q->{question})) {

	##use Data::Dumper; print "QDUMP ". Dumper($q);# if ($debug);
	    my $question = $q->{question};
	    my $qnum = $q->{number};

	    if (!defined($q->{givenanswer})) {
		warn "no given answer for question $q->{number}";
	    }

	    ## show question and options again for wrong or missing answers
	    ## show solution
	    if (!defined($q->{givenanswer}) || !$q->{givenanswer} ||
		$q->{givenanswer} ne $q->{correctanswer}) {

		my $problemtext;

		$problemtext = "NGEH";

		$problemtext = "UNANSWERED" 
		    if (!defined($q->{givenanswer}) || !$q->{givenanswer});

		$q->{givenanswer} = ""
		    if (!defined($q->{givenanswer}));

		$problemtext = "INCORRECT" 
		    if ($q->{givenanswer} &&
			$q->{givenanswer} ne $q->{correctanswer});
		
		use Data::Dumper; print "Q WRONG SOLUTION". Dumper($q) if ($debug);

		html_form_qrow($qnum,"$problemtext: ".$q->{givenanswer}." ".$question,"red");

		html_form_qrow($qnum,"SOLUTION: ".$q->{correctanswer}." ".$q->{solution});

		my $opt = 0;
		while (my $a = $q->{answer}->[$opt]) {
		
		    $opt++;
		    use Data::Dumper; print "Q WRONG SOLUTION A". Dumper($a) if ($debug);
		    
		    my $anum = $a->{id};
		    my $answer = $a->{text};
		    my $answer_value = $a->{points};
		    # TODO sometimes individual explainations of answers $$current_answer->{explain};

		    # mark out correct and incorrect answers
		    #undef $flagcol; 
		    my $flagcol;
		    if (defined($anum) && 
			defined($q->{correctanswer}) 
			&& $anum eq $q->{correctanswer}) {
			$flagcol = "green";
		    } elsif (defined($q->{givenanswer}) && $anum eq $q->{givenanswer}) {
			$flagcol = "red";
		    }
		    html_form_orow("answer$qnum",$anum,$answer,$answer_value,$flagcol);

		}
	    } else {

		html_form_qrow($qnum,"Correct ".$q->{givenanswer}."=".$q->{correctanswer},"green");
		# TODO: for correct answer put in hidden form element?
		#  or should take out form stuff for showing answers

	    }
	}	
    }

    print <<HTML;
    <tr bgcolor="$darkrowcolor">
	<td align="middle" colspan=2><font color=white>
	<input type="hidden" name="quiz" value="$quiz_file">
	<input type="hidden" name="question_number" value="$question_number">
	<input type="hidden" name="total" value="$totalpoints">
	<input type="hidden" name="mode" value="grademe">
	<input type="submit" value="Grade Me!">
	</font></td>
	</tr>
	</table>
	</form>
	</center>
HTML
;

}



sub grademe {
    my $answerstring = ""; my $grade = 0;
    my $ip = $ENV{"REMOTE_ADDR"};
    my $time = localtime(time());

    #$quiz_file = $cur->param("quiz");
    $question_number = $cur->param("question_number"); #total number of questions

    #print "question_number is $question_number\n"; exit;

    $totalpoints = $cur->param("total"); #total possible points
    $grade =0; #start with a grade of 0 and add up points
    for($i=0;$i<($question_number+1);$i++) {

	$ans = $cur->param("answer$i");

	if (defined($ans)) {

	    ($points,$answer) = split(/\,/,$ans);
	    #print "i is $i ans is $ans given is $answer points is $points\n" if ($debug);

	    if (defined($points)) {
		$grade = $grade + $points;
	    } else {
		$points = "";
	    }
	    # store how many points they get with each question
	    $answerstring = $answerstring . "$i($points)"; 
	    #print "grade is $grade after $answer.<br>";

	    print "<br>question_number is $question_number\n" if ($debug); 
	    print "i is $i ans is $ans given is $answer points is $points\n" if ($debug);

	    $questions[$i]->{givenanswer} = $answer;
	    $questions[$i]->{givenanswerpoints} = $points;

	    #if ($i>35) { exit; }
	}

    }
	
    #check for a log directory.  If there is not one, make one. It would
    # be better here to use mkdir() and umask() but I dnot know how yet
    if(!(-e "logs")) {
	`mkdir logs`;
	if(!(-e "logs")) {
	    print <<HTML;
	    <p>There was no log/ directory to store results in. 
		I tried to make it but failed. Check permissions.</p>
HTML
;
	}
    }
    open(LOGOUT,">>logs/$quiz_file") 
	|| dienice("<p>I could not write to the log file for this quiz.".
		   " Check permissions.</p>");
    flock(LOGOUT,2);
    print LOGOUT "$grade|$ip|$time|$answerstring\n";
    close(LOGOUT);
	
    open(LOGIN,"logs/$quiz_file") 
	|| dienice("<p>There is no quiz file (or you do not have permissions to read it.</p>");
    flock(LOGIN,2);
    while(<LOGIN>){
	chomp;
	($grade_in,$ip_in,$time_in,$answerstring_in)=split(/\|/,"$_");
	print "unused stuff $time_in; $ip_in; $answerstring_in;\n" if ($debug);
	push(@grades,$grade_in);
    }
    @grades = sort(@grades); #lets put them in order
    #get an average for the crades
    $number_of_grades = (@grades);
    $sum =0;
    $higher =0;
    $lower=0;
    $same =0;
    foreach $gr (@grades) {
	$sum = $sum + $gr;
	if($gr > $grade) { #number of higher grades
	    $higher++;
	}
	if($gr < $grade) { #number of lower grades
	    $lower++;
	}
	if($gr == $grade) { #number of the same grades
	    $same++;
	}
    }
    $average = $sum/$number_of_grades;
    
    #time to see what the description of our score is
    open(CONFIG,"$quiz_file") 
	|| dienice("Could not find the config file: $!");
    flock(CONFIG,2); # locking so we dong get f*cked
    $still_in_description = 0;
    while(<CONFIG>) {
	chomp;
	if($_ =~ /^\#/) {
	    $_ =""; #make sure that I ignore all commented lines
	}
	
	if($gradeby =~ /percent/i) {
	    if($_ =~ /^(-?\d{1,2})\s*-\s*(-?\d{1,3})\s*%\s*=\s*.*/) {
		$low_level = $1;
		$high_level = $2;
		$still_in_description = 0;
		if(($high_level >= ($grade/$totalpoints*100)) && (($grade/$totalpoints*100) >= $low_level)) {
		    $still_in_description = 1;
		}
	    }
	    if($still_in_description) {
		$line = $_;
		$line =~ s/^(-?\d{1,2})\s*-\s*(-?\d{1,3})\s*%\s*=\s*/<b>$grade points is in the $1 through $2\ precent<\/b><br>/g;
		$description .= "$line<br>\n";
	    }
	}elsif ($gradeby =~ /points/i) {
	    if($_ =~ /^(-?\d{1,2})\s*-\s*(-?\d{1,3})\s*\s*=\s*.*/) {
		$low_level = $1;
		$high_level = $2;
		$still_in_description = 0;
		if(($high_level >= $grade) && ($grade >= $low_level)) {
		    $still_in_description = 1;
		}
	    }
	    if($still_in_description) {
		$line = $_;
		$line =~ s/^(-?\d{1,2})\s*-\s*(-?\d{1,3})\s*\s*=\s*/<b>$grade points is in the $1 through $2\ points<\/b><br>/g;
		$description .= "$line<br>\n";
	    }		
	} else {
	    $description .= "Oops, someone forgot to have a gradeby=points or gradeby=percent in the
			config file!";
	}
	
    }
    close(CONFIG);
    print <<HTML;
    <center>
	<table cellpadding=5 bgcolor="$tablecolor" border="0" cellspacing="0">
	<tr bgcolor="$darkrowcolor">
	<td align=middle><font color=white><b>$title Results</b></td>
	</tr>
	<tr>
	<td align="middle">
	<font size="+4">Your Score: </font><b><font color="red" size="+4">$grade</font><font size=+4 color=black> / $totalpoints</font></b>
	</td>
</tr>
<tr>
	<td>
HTML
;

    printbar($grade,$totalpoints,"YOUR SCORE");
    printbar($average,$totalpoints,"AVG SCORE");
    print <<HTML;
    <p><b><font color=red>$number_of_grades </font>have taken this test so far.</b></p>
	<p><b><font color=red>$higher </font>people have scored higher than you.</b></p>
	<p><b><font color=red>$lower </font>people have scored lower than you.</b></p>
	<p><b><font color=red>$same </font>people made the same grade as you.</b></p>
	</td>
	</tr>
	<tr bgcolor="$darkrowcolor">
	<td align=middle><font color=white><b>What does this mean? *</b></td>
	</tr>
	<tr><td>$description</td></tr>
	<tr><td><font size="-1">* These results are just for fun. Do not sue me.  Have a sense of humor.</font></td></tr>
	</table>
	</center>
HTML
;
	
    close(LOGIN);
}

#useage printbar(number,total,"Coolness");
sub printbar {
    my $number_bar = shift;
    my $snumber_bar = sprintf "%10.1f",$number_bar;
    my $total_bar = shift;
    
    my $percentage;
    if ($number_bar && $total_bar > 0) {
	$percentage = ($number_bar/$total_bar)*100;
    }

    my $bartitle = shift;
    my $percentagewidth = $percentage * 4;

    print "<br><b><font color=\"#006600\"> $bartitle </font></b><br> ";
    
    my $spercent = sprintf("%10.1f",$percentage) . "%";

    #print "Debug $percentage $spercent\n";

    print <<HTML;
    <table border=0 cellpadding=0 cellspacing=0>
	<tr><td width=$percentagewidth bgcolor=0000ff>
	<font color=white><b>$spercent</b></font>&nbsp;</td>
    	<td><font size="-1">&nbsp;&nbsp;&nbsp; $snumber_bar 
	  points out of $total_bar</font></td>
	</tr>
	</table>
HTML
;

}

sub dienice {
    my($msg) = @_;

    if (defined($commandline)){
	die "Error: $msg";
    } else {
    print <<HTML;
    <br>
	<center><table width="400">
	<tr bgcolor="#FC3C3C"><td align="middle"><b><big>!! Oops !!</big></b></td></tr>
	<tr bgcolor="lightgrey"><td>$msg</td></tr>
	</table></center>
	</body></html>
HTML
;
    }

    #printendhtml();
    exit;
}

sub dietext {
    my($msg) = @_;
    die "Error: $msg";
}

sub html_form_top {
    my $title = shift;

    print <<HTML;
    <center>
	<form method="post">
	<table width="85%" cellspacing="0" border="0" bgcolor="$tablecolor">
	<tr bgcolor="$darkrowcolor"><td align="middle" colspan=2>
	<font color=white><b>$title</b></font></td></tr>
	<tr><td align="middle" colspan=2>&nbsp;</td></tr>
HTML
;
}

sub html_form_qrow {
    my $qnum = shift;
    my $question = shift;
    my $bgcolor = shift || $darkrowcolor;
    print "    <tr bgcolor=\"$darkrowcolor\">".
	"<td align=\"left\" colspan=2><font color=white><b>$qnum</b> ".
	"<b>$question</b></font></td></tr>\n";
}

# TODO: for wrong answer could make button selected
sub html_form_orow() {
    my $oname = shift;
    my $anum = shift;
    my $answer = shift;
    my $answer_value = shift;
    my $bgcolor = shift;
    print "        <tr".((defined($bgcolor))?" bgcolor=\"$bgcolor\"":"").">";
    print "<td align=\"left\">$anum. ".
	"<input type=\"radio\" name=\"$oname\" ".
	"value=\"$answer_value,$anum\"></td><td align=\"left\">$answer</td></tr>\n";
}

sub html_form_lrow {

    my $submit = shift;
    my $otherstuff = shift || "";

    #<input type="hidden" name="quiz" value="$quiz_file">
    print <<HTML;
    <tr bgcolor="$darkrowcolor">
	<td align="middle"><font color=white>
	$otherstuff
	<input type="submit" value="$submit">
	</font></td>
	</tr>
	</table>
	</form>
	</center>
HTML
;
}

sub print_http_type {
    print "Content-Type: text/html; charset=ISO-8859-1\n\n";
;
}

sub printstart {
    if (defined($commandline)) {
	printstarttext();
    } else {
	printstarthtml();
    }
}

sub printend {
    if (defined($commandline)) {
	printendtext();
    } else {
	printendhtml();
    }
}

sub printstarttext {
    print "Quiz: $title\n\n";
}

sub printendtext {
}

sub printstarthtml {

    print <<HTMLHEADER;    
    <html><head>
    <title>$title</title>
    </head>
    <body bgcolor="$bgcolor">
HTMLHEADER
;

    if($logo) {
	print"<center><img src=\"$logo\" alt=\"$title\"></center>";
    } else {
    }
}

sub printendhtml {
    print <<HTMLEND
	<br><hr><footer><br>
	</body>
	</html>
HTMLEND
;
}

