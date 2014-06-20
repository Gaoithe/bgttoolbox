#!/usr/bin/perl

use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Surface;
use SDL::Cursor;
use SDL::Event;
use SDL::Mixer;
use SDL::Sound;
use SDL::TTFont;

my $app = new SDL::App(
        -title=>'kaboom!',
        -width=>800,
        -height=>600,
        -depth=>32,
        -flags=>SDL_DOUBLEBUF | SDL_HWSURFACE | SDL_HWACCEL,
);

my $mixer = new SDL::Mixer(-frequency=>44100, -channels=>2, -size=>1024);

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
    if ($level) {
        if ($playing) {
            # update game state
        } else {
            # draw paused screen
        }
    } else {
        # intro screen
    }
    return 50;
}
