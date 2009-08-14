#!/usr/bin/perl

use Gtk '-init';
my $window = new Gtk::Window;

# set the title
$window->set_title("My app - version 1-foo");

# set the default size
$window->set_default_size($width=200, $height=300);

# the window should be managed by the window manager as
# a client of $parent_window
#$window->set_transient_for($parent_window);

# Set some resizing behavior policy
# all the values are boolean
$window->set_policy($allow_shrink=0, $allow_grow=1, $auto_shrink=1);

# Quit the main loop (and possibly exit the program) when
# the user closes the window using the window manager
$window->signal_connect('delete_event', sub {
    Gtk->main_quit;
    return 1;
});

my $button = new Gtk::Button("Quit");
$button->signal_connect("clicked", sub {Gtk->main_quit});



 # create a label
my $label = new Gtk::Label("Text");

# change the text in it (embed newlines to get multi-line labels)
$label->set_text("Blah!\nSecond line");

# justify the lines when there are multiple lines
$label->set_justify('right');

# align the label in it's allocated space
# this is actually a method in the Gtk::Misc package
# Values are in the range 0.0 .. 1.0
$label->set_alignment(my $xalign=0.5, my $yalign=0.33);



# create a table
$table = new Gtk::Table($rows=2, $columns=2, $homogeneous=1);

# add the child widget (in column $top_attach and row $left_attach)
# note that the widget can span multiple rows and columns if
# $right_attach-$left_attach or $bottom_attach-$top_attach are
# different from 1
#$table->attach_defaults($child, $left_attach, $right_attach, $top_attach, $bottom_attach);

#$table->add($button);
#$table->add($label);
#$table->attach_defaults($button, 0,2,0,2);

$table->attach_defaults($button, 0,2,0,1);
$table->attach_defaults($label, 0,2,1,1);

$window->add($table);

$window->show_all;

Gtk->main;

# man Gtk::cookbook
