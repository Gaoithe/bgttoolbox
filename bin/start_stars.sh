#!/bin/bash 

# just a plot of some distant stars
starplot &

# Select ISS. show ground track and footprint.
gpredict &

# show constellation lines, names, star names, other objects, play @ speed
stellarium &

# set openuniverse going in demo mode (it zooms between following different objects in solar system)
openuniverse -fullscreen &

# alarm for ISS pass
gnomeclocks &
