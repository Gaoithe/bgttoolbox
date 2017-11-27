#!/bin/python

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
