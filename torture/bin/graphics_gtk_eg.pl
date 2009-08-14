#!/usr/bin/perl

use Gtk '-init';
my $window = new Gtk::Window;
my $button = new Gtk::Button("Quit");
$button->signal_connect("clicked", sub {Gtk->main_quit});
$window->add($button);
$window->show_all;
Gtk->main;


# man Gtk::cookbook
