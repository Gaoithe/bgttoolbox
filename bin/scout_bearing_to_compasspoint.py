#!/bin/python

# https://geonet.esri.com/thread/183454-python-scriptexpression-for-field-calculator-for-converting-bearings-to-directions

import numpy as np
global a
global c
a = np.arange(11.25, 360., 22.5)
c = np.array(['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 
              'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N'])

def compass(angle):
    """ test """
    return c[np.digitize([angle], a)]

# Expression for the field calculator
#compass(!Field_with_the_angles!)  # using the python processor of course
 
# For general testing or for single entry use and testing.
 
angles = np.arange(0, 360, 22.5) #[0, 44, 46, 134, 136, 224, 226, 314, 316, 359]
for i in angles:
    print("{} => {}".format(i, compass(i)))
