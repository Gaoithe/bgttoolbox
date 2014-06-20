#!/usr/bin/perl

use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Surface;
use SDL::Cursor;
use SDL::Event;
#use SDL::Mixer;
use SDL::Sound;
use SDL::TTFont;

=head1 foo

TODO PErl SDL Blockus
TODO Blockus font >;)

TODO: animated transparent blocks moving into place, grey background/board seen underneath
shiny/reflective blocks surface
3D?
1. ascii 2. web 3. skype 4. graphics sdl/perl, windows, linux, mobile devices

TODO blockus fun sounds + animations, 
T-piece Mr T animates + A Team theme, 
customisable animations

TODO customisable bot-comments 


=cut

my $app = new SDL::App(
        -title=>'kaboom!',
        -width=>800,
        -height=>600,
        -depth=>32,
        -flags=>SDL_DOUBLEBUF | SDL_HWSURFACE | SDL_HWACCEL,
);

#my $mixer = new SDL::Mixer(-frequency=>44100, -channels=>2, -size=>1024);

my $level = 0;
my $playing = 0;

my $actions = {};
&event_loop();

sub event_loop {
    my $next_heartbeat = $app->ticks;
    my $event = new SDL::Event;

  MAIN_LOOP:
    while(1) {
        while ($event->poll) {
            my $type = $event->type();

            last MAIN_LOOP if ($type == SDL_QUIT);
            last MAIN_LOOP if ($type == SDL_KEYDOWN && $event->key_name() eq 'escape');

            if ( exists($actions->{$type}) && ref( $actions->{$type} ) eq "CODE" ) {
                $actions->{$type}->($event);
            }
        }
        if ($app->ticks >= $next_heartbeat) {
            my $n = &heartbeat() || 50;
            $next_heartbeat = $app->ticks + $n;
        }
        $app->delay(5);
    }
}

sub heartbeat {
    print "hb level=$level playing=$playing\n";
    if ($level) {
        if ($playing) {
            # update game state
        } else {
            # draw paused screen
        }
    } else {
        &draw_intro_screen();
        return 500;
    }
    return 50;
}


{
    my ($rcolor, $gcolor, $bcolor, $ycolor);
    my ($rbcolor, $gbcolor, $bbcolor, $ybcolor);
    my($bgcolor, $bgfcolor, $fgcolor, $titlefont, $actionfont, $titletext, $titlexpos, $actiontext, $actionxpos);
    my ($g1col,$g2col);

    sub config_intro_screen {
	print "intro c\n";
	print "intro c $titlexpos $actionxpos\n";

	#our ($titlexpos,$actionxpos);

        $g1col = new SDL::Color(-r=>96, -g=>96, -b=>96); # grey? white?
        $g2col = new SDL::Color(-r=>128, -g=>128, -b=>128); # darker grey

        $bgcolor = new SDL::Color(-r=>192, -g=>192, -b=>192); # grey
        $bgfcolor = new SDL::Color(-r=>192, -g=>0, -b=>0); # reddish
        $fgcolor = new SDL::Color(-r=>0, -g=>0, -b=>0); # black
        $rcolor = new SDL::Color(-r=>255, -g=>0, -b=>0); # red
        $gcolor = new SDL::Color(-r=>0, -g=>255, -b=>0); # green
        $bcolor = new SDL::Color(-r=>0, -g=>0, -b=>255); # blue
        $ycolor = new SDL::Color(-r=>255, -g=>255, -b=>0); # yellow
        $rbcolor = new SDL::Color(-r=>255, -g=>50, -b=>50); # red/whitish? how do transparent?
	print Dumper($bgcolor);
	print Dumper($fgcolor);

	#my $fffont = "lib-kaboom/fonts/Vera.ttf";
	my $fffont = "/usr/share/childsplay/Data/Domestic_Manners.ttf";
	#my $fffont = "/usr/share/k3d/fonts/K-3D.ttf";
	#my $fffont = "/usr/share/k3d/fonts/VeraBd.ttf";
	#my $fffont = "/usr/share/games/singularity/data/vera.ttf";


        $titlefont = new SDL::TTFont(-name=>$fffont, -size=>80, -bg=>$bgcolor, -fg=>$fgcolor);
        $actionfont = new SDL::TTFont(-name=>$fffont, -size=>25, -bg=>$bgfcolor, -fg=>$fgcolor);

	use Data::Dumper;
	print "hijo font $titlefont, $actionfont\n";
	print Dumper($titlefont);

        $titletext = "Kaboom!";
        $titlexpos = int(($app->width - $@{$titlefont->width($titletext)}[0]) / 2);

        $actiontext = "press mouse button to .. do nothing";
        $actionxpos = int(($app->width - $@{$actionfont->width($actiontext)}[0]) / 2);
	print "intro c end $titlexpos $actionxpos\n";

	print $titlefont->width($titletext);  ## it's an array!
	print Dumper($titlefont->width($titletext));  ## it's an array!
	print "app width is " . $app->width . "\n";

    }

    sub draw_intro_screen {
	#our ($titlexpos,$actionxpos);

	print "intro d $titlexpos $actionxpos\n";
        &config_intro_screen unless (defined($bgcolor));

        SDL::Cursor::show(undef, 1);
        $app->grab_input(SDL_GRAB_OFF);

        $app->fill(0, $bgcolor);

	$titlefont->text_solid();
        $titlefont->print($app, $titlexpos, 20, $titletext);

        $actionfont->print($app, $actionxpos, 500, $actiontext);


	my $background = SDL::Surface->new(-width => $app->width, -height => $app->height, -depth => 32, -Amask => '0 but true');
	my $jrect1 = SDL::Rect->new(-width => 50, -height => 30, -x => 50, '-y' => 50);
	$background->blit($jrect1, $app, $jrect1);

	my $jrect2 = SDL::Rect->new(-width => 50, -height => 30, -x => 50, '-y' => 100);
	#$jrect2->color($bgcolor);
	$background->blit($jrect2, $app, $jrect2);

	### HAHAHA SEGFAULT:
        #$background->print($actionfont, $actionxpos, 500, $actiontext);
        $background->print("MAAAAHHHH");

	# blockus grey background
	my $blrectg1 = SDL::Rect->new(-width => 300, -height => 300, -x => 50, '-y' => 150);
	my $blrectg2 = SDL::Rect->new(-width => 30, -height => 30, -x => 150, '-y' => 250);
	$app->fill( $blrectg1, $g1col );
	$app->fill( $blrectg2, $g2col );

	# TODO: animated transparent blocks moving into place, grey background/board seen underneath
	# blockus blocks
	my $blrectr = SDL::Rect->new(-width => 30, -height => 30, -x => 50, '-y' => 150);
	my $blrectrb = SDL::Rect->new(-width => 32, -height => 32, -x => 49, '-y' => 149);
	my $blrectg = SDL::Rect->new(-width => 30, -height => 30, -x => 50, '-y' => 182);
	my $blrectb = SDL::Rect->new(-width => 30, -height => 30, -x => 82, '-y' => 150);
	my $blrecty = SDL::Rect->new(-width => 30, -height => 30, -x => 82, '-y' => 182);
	$app->fill( $blrectrb, $rbcolor );
	$app->fill( $blrectr, $rcolor );
	$app->fill( $blrectg, $gcolor );
	$app->fill( $blrectb, $bcolor );
	$app->fill( $blrecty, $ycolor );
	#$background->blit($blrect, $app, $blrect);

	BEGIN { srand() if $] < 5.004 }
	my @blcols = ($rcolor, $gcolor, $bcolor, $ycolor);
	my $blcol = $blcols[rand(4)];
	my $blx = rand(20)*32 + 50;
	my $bly = rand(20)*32 + 150;
	my $blr = SDL::Rect->new(-width => 30, -height => 30, -x => $blx, '-y' => $bly);
	$app->fill( $blr, $blcol );

        #$actionfont->print($app, $background, 20, 20, $actiontext);
        ####### YES!
        $titlefont->print($app, 20, 20, $titletext);
        $actionfont->print($app, 20, 120, "Press ESC to exit.");

	$actionfont->print($app, 20, 170, "TODO Perl SDL Blockus");
	$actionfont->print($app, 20, 220, "TODO Blockus font >;)");

        $app->sync();
    }
}

