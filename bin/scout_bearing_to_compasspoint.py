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



# https://en.wikipedia.org/wiki/Kurt_Vonnegut
# https://en.wikiquote.org/wiki/Kurt_Vonnegut
quote1 = "We are what we pretend to be, so we must be careful about what we pretend to be."
quote2 = "I sometimes wondered what the use of any of the arts was. The best thing I could come up with was what I call the canary in the coal mine theory of the arts. This theory says that artists are useful to society because they are so sensitive. They are super-sensitive. They keel over like canaries in poison coal mines long before more robust types realize that there is any danger whatsoever."
quote3 = "Well, I've worried some about, you know, why write books . . .  why are we teaching people to write books when presidents and senators do not read them, and generals do not read them. And it's been the university experience that taught me that there is a very good reason, that you catch people before they become generals and presidents and so forth and you poison their minds with . . .  humanity, and however you want to poison their minds, it's presumably to encourage them to make a better world."

from math import acos
from math import sqrt
from math import pi

def length(v):
    return sqrt(v[0]**2+v[1]**2)
def add(v,w):
   return (v[0]+w[0],v[1]+w[1])
def diff(v,w):
   return (v[0]-w[0],v[1]-w[1])
def dot_product(v,w):
   return v[0]*w[0]+v[1]*w[1]
def determinant(v,w):
   return v[0]*w[1]-v[1]*w[0]
def inner_angle(v,w):
   cosx=dot_product(v,w)/(length(v)*length(w))
   rad=acos(cosx) # in radians
   return rad*180/pi # returns degrees
def angle_clockwise(A, B):
    inner=inner_angle(A,B)
    det = determinant(A,B)
    if det<0: #this is a property of the det. If the det < 0 then B is clockwise of A
        return inner
    else: # if the det > 0 then A is immediately clockwise of B
        return 360-inner

def bearing(A, B):
    # translate A to origin A-A
    # translate B the same B-A
    # get angle of B-A 
    T = diff(B,A)
    North = (0, 1)
    return angle_clockwise(North,T) % 360

A = (1, 0)
B = (1, -1)
North = (0, 1)
O = (0, 0)

#print(angle_clockwise(A, O))
#print(inner_angle(A, O))
#print(angle_clockwise(B, O))
#print(inner_angle(B, O))

print(angle_clockwise(A, B))
print(inner_angle(A, B))
# 45.

print(angle_clockwise(B, A))
print(inner_angle(B, A))

print(angle_clockwise(North, A))
print(angle_clockwise(North, B))

print(bearing(A,B))
print(bearing(B,A))
print(bearing(North,A))
print(bearing(A,North))
print(bearing(North,B))
print(bearing(B,North))

print "=================================================="
print "circle start at North=(0,1)"
print "x^2 + y^2 = 0"
print "circle advance by 360/8 => NE=(?,?)"


# http://stackoverflow.com/questions/32092899/plot-equation-showing-a-circle/32097654#32097654

import numpy as np
import matplotlib.pyplot as plt

# theta goes from 0 to 2pi
theta = np.linspace(0, 2*np.pi, 100)

# the radius of the circle
r = np.sqrt(1.0)

# compute x1 and x2
x1 = r*np.cos(theta)
x2 = r*np.sin(theta)

# create the figure
fig, ax = plt.subplots(1)
#ax.plot(x1, x2)
#markers_on = [10,20,30,40,50,60,70,80,90]
markers_on = [0,100/16]
ax.plot(x1, x2,'-gD',markevery=markers_on)
ax.set_aspect(1)
#plt.show()


# eta goes from 0 to 2pi in 8 steps
eta = np.linspace(0, 2*np.pi, 9)
x81 = r*np.cos(eta)
x82 = r*np.sin(eta)
ax.plot(x81, x82)

# tau goes from 0 to 2pi in 16 steps
tau = np.linspace(0, 2*np.pi, 17)
x161 = r*np.cos(tau)
x162 = r*np.sin(tau)
markers_on = [0,1]
ax.plot(x161, x162,'-gD',markevery=markers_on)

#X, Y = np.meshgrid(x81,x82)
#X2, Y2 = np.meshgrid(x81,x82)
#ax.plot(X,Y,X2,Y2)







plt.show()
