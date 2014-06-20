#!/usr/bin/perl

use Gnome;
init Gnome "simplegraph";

my $x = 400; my $y = 400;
my $t = Gtk::Window->new('-toplevel');
my $c = Gnome::Canvas->new();
$c->set_usize($x,$y);
$c->set_scroll_region(0,0,$x,$y);
$t->add($c);
$t->show_all;

my $BP=0;

$c->signal_connect("event", sub {
    my($w, $e) = @_;
    print "WE: $w, $e: $e->{type}\n";
    if($e->{type} eq "button_press") {
        $BP++;
        print "eek! button press!\n"; 
    }
});

# draw a line
my $l = $c->root->new($c->root, "Gnome::CanvasLine",
		points => [ 10, 10, 200, 200],
		fill_color => 1,
		width_units => 5,
		);


print "Waiting... Click a button in the window\n";
Gtk->main_iteration while !$BP;
print "Continuing...\n";
