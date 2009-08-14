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

my $actions = {};
&event_loop();

sub event_loop {
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
        $app->delay(5);
    }
}
