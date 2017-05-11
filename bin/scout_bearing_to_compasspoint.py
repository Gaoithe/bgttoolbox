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



###########################################################################################
def print_post(bearing,postAlpha):
    # TODO: letterLocation = [][]
    print "########################################"
    print "#"
    print("# POST: {} => {}".format(bearing, compass(bearing)[0]))
    print "#"
    print "#        1   2   3   4   5 - Easting"
    print "#"
    print "#    5  ",#A  B  C  D  E"
    # TODO: record location of letters  easting,westing and use to verify
    for i in range (0,5):
        print "%c  " % postAlpha[i],
    print "\n#    4  ",#F  G  H  J  K  I"
    for i in range (5,11):
        print "%c  " % postAlpha[i],
    print "\n#    3  ",#L  M  N  O  P"
    for i in range (11,16):
        print "%c  " % postAlpha[i],
    print "\n#    2  ",#Q  R  S  T  U"
    for i in range (16,21):
        print "%c  " % postAlpha[i],
    print "\n#    1  ",#V  W  X  Y  Z"
    for i in range (21,26):
        print "%c  " % postAlpha[i],
    print "\n#     \\"
    print "#      Northing"
    print "#"
    print "########################################"
    print ""

import random
import re



###########################################################################################
# http://stackoverflow.com/questions/32092899/plot-equation-showing-a-circle/32097654#32097654
# circle of posts, location of posts

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.lines as lines

# theta goes from 0 to 2pi
theta = np.linspace(0, 2*np.pi, 100)

# the radius of the circle
r = np.sqrt(1.0)

# compute x1 and x2 . . x,y arrays
x1 = r*np.cos(theta)
x2 = r*np.sin(theta)

# create the figure
fig, ax = plt.subplots(1)
ax.plot(x1, x2)
##markers_on = [10,20,30,40,50,60,70,80,90]
#markers_on = [0,100/16]
#ax.plot(x1, x2,'-gD',markevery=markers_on)
ax.set_aspect(1)
#plt.show()

# eta goes from 0 to 2pi in 8 steps
eta = np.linspace(0, 2*np.pi, 9)
x81 = r*np.cos(eta)
x82 = r*np.sin(eta)
ax.plot(x81, x82)
print "x8.1 is: " 
print x81
print "x8.2 is: " 
print x82

# tau goes from 0 to 2pi in 16 steps
tau = np.linspace(0, 2*np.pi, 17)
x161 = r*np.cos(tau)
x162 = r*np.sin(tau)
markers_on = [0,1]
ax.plot(x161, x162,'-gD',markevery=markers_on)
#print "x16.1 is: " 
#print x161
#print "x16.2 is: " 
#print x162

###########################################################################################
# print posts, randomize alphabets
alphabet = "ABCDEFGHJKILMNOPQRSTUVWXYZ"
posts = np.arange(0, 360, 22.5) #[0, 22.5, 45 . . . 337.5]
    
xy = []
postAlpha = []
postAlpha.append(alphabet)
i=0
for p in posts:
    print_post(p,postAlpha[-1])
    postAlpha.append(''.join(random.sample(alphabet,len(alphabet))))
    ip=i + 4
    xy.append((-x161[ip%16],x162[ip%16]))
    i+=1

###########################################################################################

def print_blanks(quote):
    ''' Print __ ___ ____ form of quote. '''
    print "#" * (len(quote) + 4)
    print "#%s#" % (" "*(len(quote)+2))
    print "# %s #" % quote
    print "#%s#" % (" "*(len(quote)+2))
    print "#" * (len(quote) + 4)
    print ""
    blanks = re.sub(r" ","  ",quote)
    blanks = re.sub(r"[A-Za-z]","__ ",blanks)
    print "#" * (len(blanks) + 4)
    print "#%s#" % (" "*(len(blanks)+2))
    print "#%s#" % (" "*(len(blanks)+2))
    print "# %s #" % blanks
    print "#%s#" % (" "*(len(blanks)+2))
    print "#" * (len(blanks) + 4)
    print ""

def print_instructions(quote):
    ''' Print instructions '''
    # for each word in quote WORD: 1, x letters
    iw = 1
    alphabet = "ABCDEFGHJKILMNOPQRSTUVWXYZ"
    for word in quote.split():
        wordpath=[]
        wordpathr=[]
        print "########################################"
        print "#"
        print "# Word %d" % iw
        # Start at POST XX
        # pick random start post
        r = random.randrange(16)
        b = posts[r]
        wordpath.append(b)
        wordpathr.append(r)
        #alpha = postAlpha[r]
        print("# START at POST: {} => {}".format(b, compass(b)[0]))
        print "#"

        i=1
        for c in word:
            if c.upper() in alphabet:
                # pick random next post
                n = random.randrange(16)
                while n == r:
                    n = random.randrange(16)
                b = posts[n]
                wordpath.append(b)
                wordpathr.append(n)
                alpha = postAlpha[n]
                # Follow bearing XXX to next Post,
                #    Record letter @ Easting 2, Northing 2  _______
                # Follow bearing XXX to next Post,
                #    Record letter @ Easting 2, Northing 2  _______
                # 
                print("# {}. Follow bearing {} to next Post,".format(i,bearing(xy[r],xy[n])))
                pos = alpha.index(c.upper())
                easting = (pos + 1) % 5
                northing = 5 - (pos/5)
                if (pos == 10):
                    easting=6
                    northing=4
                if (pos > 10):
                    easting = pos % 5
                    northing = 5 - ((pos-1)/5)
                print "#    Record letter @ Easting %d, Northing %d  _______" % (easting,northing)
                print "#    DEBUG post:{} ({:1.2f},{:1.2f}) c:{}".format(b,xy[n][0],xy[n][1],c)
                # next
                r = n
                i+=1
        print "#"
        print "########################################"
        print "#",
        print "# Word {} is {}, post path is {}".format(iw,word,wordpath)
        print "########################################"
        iw += 1

quote = "We are what we pretend to be, so we must be careful about what we pretend to be."
print_blanks(quote)

print_instructions(quote)


print "=================================================="
print "circle start at North=(0,1)"
print "x^2 + y^2 = 0"
print "circle advance by 360/8 => NE=(?,?)"




X, Y = np.meshgrid(x81,x82)
X2, Y2 = np.meshgrid(x161,x162)
ax.plot(X,Y)
ax.plot(X2,Y2)
# grid
ax.plot(X2,Y2, marker='.', color='k', linestyle='none')

# a line - doesnt work
ax.plot([-1,-1],[1,1],color='k',marker='o')
# this line does work:
line = lines.Line2D([0.3,0.6],[0.9,0.3],linestyle='dashed',color='k')
plt.axes().add_line(line)

#for i in range(0,16):
#  x=x161[i]
#  y=x162[i]
#  for j in range(0,16):
#    x3=x161[j]
#    y3=x162[j]
#    ax.plot([x,y],[x3,y3],color='k',marker='o')

for i in range(0,8):
  x=x81[i]
  y=x82[i]
  for j in range(0,8):
    x3=x81[j]
    y3=x82[j]
    ax.plot([x,x3],[y,y3],color='k',marker='o')


# i=0 or j=0 Eastern most point
for i in range(0,8):
  x=x81[i]
  y=x82[i]
  A=(x,y)
  for j in range(0,8):
    x3=x81[j]
    y3=x82[j]
    B=(x3,y3)
    #ax.plot([x,x3],[y,y3],color='k',marker='o')
    print "i=%d j=%d A=(%0.1f,%0.1f) B=(%0.1f,%0.1f) bearing=%0.1f" % (i,j,x,y,x3,y3,bearing(A,B))


##ax.plot(-0.5,-0.5,0.7,0.9)



plt.show()






########################################
#
# Word 0
# START at POST: 67.5 => ENE
#
# 0. Follow bearing 123.75 to next Post,
#    Record letter @ Easting 1, Northing 1  _______
#    DEBUG post:45.0 c:W
# 0. Follow bearing 146.25 to next Post,
#    Record letter @ Easting 6, Northing 4  _______
#    DEBUG post:22.5 c:e
#
########################################
# # Word 0 is We, post path is [67.5, 45.0, 22.5]
########################################


########################################
#
# POST: 337.5 => NNW
#
#        1   2   3   4   5 - Easting
#
#    5   Y   H   T   M   G   
#    4   W   B   C   I   U   Q   
#    3   K   P   Z   R   L   
#    2   S   X   O   N   J   
#    1   F   V   E   D   A   
#     \
#      Northing
#
########################################




import curses
stdscr = curses.initscr()
curses.start_color()
#curses.noecho()
#curses.cbreak()
#stdscr.keypad(1)

yxmax = stdscr.getmaxyx()

pad = curses.newpad(yxmax)
#pad = curses.newpad(100, 100)
#  These loops fill the pad with letters; this is
# explained in the next section
for y in range(0, yxmax[0]-10):
    for x in range(0, yxmax[1]-10):
        try:
            pad.addch(y,x, ord('a') + (x*x+y*y) % 26)
        except curses.error:
            pass

#  Displays a section of the pad in the middle of the screen
pad.refresh(0,0, 5,5, yxmax[0]-5,yxmax[1]-5) ## pminrow, pmincol, sminrow, smincol, smaxrow, smaxcol

curses.init_pair(1, curses.COLOR_RED, curses.COLOR_WHITE)
curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
pad.addstr(0,0, "red/white", curses.color_pair(1))
pad.addstr(1,10, "red/black", curses.color_pair(2))
pad.addstr(2,20, "red/blue", curses.color_pair(3))
pad.refresh(0,0, 5,5, yxmax[0]-5,yxmax[1]-5) ## pminrow, pmincol, sminrow, smincol, smaxrow, smaxcol

#curses.nocbreak(); stdscr.keypad(0); curses.echo()
curses.endwin()
