#!/usr/bin/python

"""gtk-photo-slideshow.py [-hwrd] [dirs]
 -h --help
 -w --window
 -r --repeat
 -d --delay (TODO: doesn't take a number yet)
 -f --fullscreen
 -n --name # sort files by name, not by datetime
 -s --nosort # no sorting

python script quick and simplish photo slideshow of directories
"""

"""
# originally originally . . . Taken and customed from Jack Valmadre's Blog:
# http://jackvalmadre.wordpress.com/2008/09/21/resizable-image-control/
# 
# Put together and created the time switching by Izidor Matusov <izidor.matusov@gmail.com>
#
# taken from here: http://stackoverflow.com/questions/6450170/using-pygtk-how-can-i-make-a-simple-fullscreen-slide-show
# 18/6/2012 jamesc 
#  fix the dir walk and file list didn't pick up files
#  add debug file counts
#  pass in dir(s) on cmd line argv
# 
# 6/10/2012 sort files by datetime, freezing on pics?, or failing to load, adding debug. It is slow to load. And the next image is triggered on a timer. So a series of images failing to load looks like  a freeze. What happens me is it seems images are shown till a freeze. Next showing it gets further. Some kind of buffering/caching? Showing slideshow on laptop over wireless mount of NAS. The problem seems to be worse with fullscreen. 
# FAIL:
# set from pixbuf 2
# display index 156
# display true 20120912to23JohnAndCarlyVisitDubAndKillarney40thAnniversaryMumAndDad/P1070550.JPG
# SUCCESS draw:
# set from pixbuf 2
# display index 157
# display true 20120912to23JohnAndCarlyVisitDubAndKillarney40thAnniversaryMumAndDad/P1070551.JPG
# draw
# paint
#
#set from pixbuf 2
#set from pixbuf fin
#display index 0
#display true 20120912to23JohnAndCarlyVisitDubAndKillarney40thAnniversaryMumAndDad/P1070359.JPG
#draw1
#draw2
#draw3
#draw
#paint1
#paint2
#paint
#happiness
#
# 7/10/2012 start window maximised
#
# TODO: keyboard control, next previous photo ... next album/dir
# TODO: don't catch exceptions, handle file not found, slow reading (show warning) 
# TODO: disable  screensaver
# TODO: profile prog in fullscreen and windowed mode, is there a slowdown? where is it?
# TODO: loading file list, show loading info and start showing images earlier

###############################################
23/10/2012
ODO: configurable debug and logging messages 
TODO: track time it takes to build list of images, time to display images/dirs, use for profiling and debug info
TODO: HOW TO control: right or left mouse click -> menu For/Back 1, jump 10, next dir, next ...
TODO: turn mouse arrow into mostly transparent thing
TODO: exclude __private, __thumb, hidden dirs.
TODO(INPROG 9/2/2015): forward/back scroll list of photos, m of n photo est time,   *mark photo (for attention, rotating, hiding, ...) 
TODO: time/play bar like video

cd /mnt/GreenSpaceMultimedia/FamilyPhotos/AllPictures/

###############################################
8/2/2015
before cub scouts. sort by date/time was not showing by date time
because . . . some dirs had files date/times messed up. 
better to sort by filename in those cases (added -n --name option)
Default: sort by create date/time.
Another Option: -s --nosort  (sorted by the way python reads in files - disk order).

###############################################
9/2/2015 (also see TODOs 23/10/2012)
STARTED: add some key/mouse control
DONE: key QUIT
DONEish: key PAUSE/UNPAUSE   (should quit immediately - it does)
DONEish: key NEXT/PREV       (should display immediately - it does)
TODO: faster/slower
TODO: key PAUSE/UNPAUSE  cute fade in & out paws animation  -  like snake - paws footprints walking around screen - old ones fading out 
TODO: key HELP/MENU - text key/control menu on screen
TODO: key INFO (info on picture set (pic number i of n, eta T:S min/sec) and info on current image (name, dir, resolution, . . .))
TODO: mousemove/key cute fade in menu hint

"""

import os

import pygtk
pygtk.require('2.0')
import gtk
import glib

g_slide_time = 3
g_fullscreen = False
g_repeat = False
g_sort = "byDatetime"
g_lastpainted = -1
g_pause = False
g_help = False
g_info = False
g_info_text = False
g_info_speed = False

g_help_text = '''======= key/mouse control =======
q/Q/Esc . . . . . . . . . QUIT
<space> . . . . . . . . . PAUSE/UNPAUSE
n/N or p/P  . . . . . . . NEXT or PREVIOUS
+/- . . . . . . . . . . . FASTer/SLOWer
i/I . . . . . . . . . . . TODO: INFO - show info on image - show progress
m/M h/H . . . . . . . . . TODO: MENU / HELP - quick keypress/control help
* . . . . . . . . . . . . TODO: MARK image
======= key/mouse control =======
''' 

def is_image(filename):
    """ File is image if it has a common suffix and it is a regular file """

    if not os.path.isfile(filename):
        return False

    for suffix in ['.jpg', '.png', '.bmp']:
        if filename.lower().endswith(suffix):
            return True

    return False

def resizeToFit(image, frame, aspect=True, enlarge=False):
    """Resizes a rectangle to fit within another.

    Parameters:
    image -- A tuple of the original dimensions (width, height).
    frame -- A tuple of the target dimensions (width, height).
    aspect -- Maintain aspect ratio?
    enlarge -- Allow image to be scaled up?

    """
    if aspect:
        return scaleToFit(image, frame, enlarge)
    else:
        return stretchToFit(image, frame, enlarge)

def scaleToFit(image, frame, enlarge=False):
    image_width, image_height = image
    frame_width, frame_height = frame
    image_aspect = float(image_width) / image_height
    frame_aspect = float(frame_width) / frame_height
    # Determine maximum width/height (prevent up-scaling).
    if not enlarge:
        max_width = min(frame_width, image_width)
        max_height = min(frame_height, image_height)
    else:
        max_width = frame_width
        max_height = frame_height
    # Frame is wider than image.
    if frame_aspect > image_aspect:
        height = max_height
        width = int(height * image_aspect)
    # Frame is taller than image.
    else:
        width = max_width
        height = int(width / image_aspect)
    return (width, height)

def stretchToFit(image, frame, enlarge=False):
    image_width, image_height = image
    frame_width, frame_height = frame
    # Stop image from being blown up.
    if not enlarge:
        width = min(frame_width, image_width)
        height = min(frame_height, image_height)
    else:
        width = frame_width
        height = frame_height
    return (width, height)


class ResizableImage(gtk.DrawingArea):

    def __init__(self, aspect=True, enlarge=False,
            interp=gtk.gdk.INTERP_NEAREST, backcolor=None, max=(1600,1200)):
        """Construct a ResizableImage control.

        Parameters:
        aspect -- Maintain aspect ratio?
        enlarge -- Allow image to be scaled up?
        interp -- Method of interpolation to be used.
        backcolor -- Tuple (R, G, B) with values ranging from 0 to 1,
            or None for transparent.
        max -- Max dimensions for internal image (width, height).

        """
        super(ResizableImage, self).__init__()
        self.pixbuf = None
        self.aspect = aspect
        self.enlarge = enlarge
        self.interp = interp
        self.backcolor = backcolor
        self.max = max
        self.connect('expose_event', self.expose)
        self.connect('realize', self.on_realize)

    def on_realize(self, widget):
        if self.backcolor is None:
            color = gtk.gdk.Color()
        else:
            color = gtk.gdk.Color(*self.backcolor)

        self.window.set_background(color)

    def expose(self, widget, event):
        # Load Cairo drawing context.
        print "draw1"
        self.context = self.window.cairo_create()
        print "draw2"
        # Set a clip region.
        self.context.rectangle(
            event.area.x, event.area.y,
            event.area.width, event.area.height)
        print "draw3"
        self.context.clip()
        # Render image.
        print "draw"
        self.draw(self.context)
        return False

    def draw(self, context):
        # Get dimensions.
        print "paint1"
        rect = self.get_allocation()
        x, y = rect.x, rect.y
        # Remove parent offset, if any.
        parent = self.get_parent()
        if parent:
            offset = parent.get_allocation()
            x -= offset.x
            y -= offset.y
        # Fill background color.
        if self.backcolor:
            context.rectangle(x, y, rect.width, rect.height)
            context.set_source_rgb(*self.backcolor)
            context.fill_preserve()
        # Check if there is an image.
        if not self.pixbuf:
            print "ERR: no image :("
            return
        width, height = resizeToFit(
            (self.pixbuf.get_width(), self.pixbuf.get_height()),
            (rect.width, rect.height),
            self.aspect,
            self.enlarge)
        x = x + (rect.width - width) / 2
        y = y + (rect.height - height) / 2
        print "paint2"
        context.set_source_pixbuf(
            self.pixbuf.scale_simple(width, height, self.interp), x, y)
        print "paint"
        #print "paint", self.index
        #self.lastpainted = self.index
        context.paint()

    def set_from_pixbuf(self, pixbuf):
        width, height = pixbuf.get_width(), pixbuf.get_height()
        # Limit size of internal pixbuf to increase speed.
        if not self.max or (width < self.max[0] and height < self.max[1]):
            print "set from pixbuf 1"
            self.pixbuf = pixbuf
        else:
            print "set from pixbuf 2"
            width, height = resizeToFit((width, height), self.max)
            self.pixbuf = pixbuf.scale_simple(
                width, height,
                gtk.gdk.INTERP_BILINEAR)
        self.invalidate()
        print "set from pixbuf fin"

    def set_from_file(self, filename):
        self.set_from_pixbuf(gtk.gdk.pixbuf_new_from_file(filename))
        global g_lastpainted
        g_lastpainted = filename

    def invalidate(self):
        self.queue_draw()



import zipfile

class DemoGtk:

    SECONDS_BETWEEN_PICTURES = g_slide_time
    old_slide_time = g_slide_time
    FULLSCREEN = g_fullscreen
    WALK_INSTEAD_LISTDIR = True

    def __init__(self,args):
        self.window = gtk.Window()
        self.window.connect('destroy', gtk.main_quit)
        self.window.set_title('Slideshow')

        self.window.add_events(gtk.gdk.KEY_PRESS_MASK |
              gtk.gdk.POINTER_MOTION_MASK |
              gtk.gdk.BUTTON_PRESS_MASK | 
              gtk.gdk.SCROLL_MASK)

        #self.window.connect("motion-notify-event", self.handle_input)
        self.window.connect("key-press-event", self.handle_input)
        self.window.connect("button-press-event", self.handle_input)
        #self.window.connect("scroll-event", self.handle_input)

        self.image = ResizableImage( True, True, gtk.gdk.INTERP_BILINEAR)
        self.image.show()
        self.window.add(self.image)

        self.load_file_list(args)

        if len(self.files) > 0:
            self.window.show_all()

            if self.FULLSCREEN:
                self.window.fullscreen()
            else: 
                self.window.maximize()
                print "window size:", self.window.get_size()

            glib.timeout_add_seconds(self.SECONDS_BETWEEN_PICTURES, self.on_tick)
            self.display()
        else:
            print "%d images found."% len(self.files)
            print __doc__
            sys.exit(0)

    def load_file_list(self,args):
        """ Find all images """
        self.files = []
        self.index = 0

        for arg in args:
          print "arg:", arg
          if self.WALK_INSTEAD_LISTDIR:    
            #print "WALK"
            for directory, sub_directories, files in os.walk(arg):
                print "dir:%s sub:%s files:%s", (directory, sub_directories, files)
                for filename in files:
                    #print "allfile:", filename
                    filepath = os.path.join(directory, filename)
                    if is_image(filepath):
                        self.files.append(filepath)
                        print "dirFile:", filename
                    elif zipfile.is_zipfile(filepath):
                        print 'TODO: handle zip files. %20s  %s' % (filepath, zipfile.is_zipfile(filepath))
                print "%d images."% len(self.files)
            if zipfile.is_zipfile(arg):
                print 'TODO: handle zip files. %20s' % (arg)
          else:
            print "LIST"
            for filename in os.listdir(arg):
                print "allfile:", filename
                if is_image(filename):
                    self.files.append(filename)
                    print "File:", filename
                    #print "Images:", self.files
                elif zipfile.is_zipfile(filename):
                    print 'TODO: handle zip files. %20s  %s' % (filename, zipfile.is_zipfile(filename))

        #print "Images:", self.files
        print "TOTAL: %d images."% len(self.files)
        # sort in order of date of file
        if g_sort:
            if g_sort == "byDatetime":
                print "Sort by date/time:", g_sort
                self.files.sort(key=lambda s: os.stat(s).st_mtime)
                #self.files.sort(key=lambda s: os.path.getmtime(s))
                #self.files.sort(key=lambda s: os.path.getctime(s))
            else:
                print "Sort by name/number:", g_sort
                def getint(name):
                    basename = name.partition('.')
                    alpha, num = basename.split('_')
                    return int(num)
                #self.files.sort(key=getint)
                self.files.sort(key=lambda s: s)
            # no else needed?? default is sorted by name as they're read in. ehrrr. nope.
        else:
            print "No sort:", g_sort

        # debug test list sorted?
        for i in range(0, len(self.files)):
            print "sortfile:", self.files[i]
        

    def display(self):
        """ Sent a request to change picture if it is possible """
        if 0 <= self.index < len(self.files):
            self.image.set_from_file(self.files[self.index])
            print "display index", self.index
            print "display true", self.files[self.index]

            ## show menu/help and/or info text
            ## tooltip is a bit clunky and ugly but quick qand easy TODO: make beautiful, draw onto image.
            text = ""
            global g_help, g_help_text, g_info, g_info_speed, g_info_text
            if g_help:
                text = g_help_text
            if g_info:
                text += self.get_info_text()
            if g_info_text:
                text += g_info_text
                g_info_text = False
            if g_info_speed:
                text += g_info_speed
                g_info_speed = False
            if text:
                self.window.set_tooltip_text(text)
            else:
                self.window.set_tooltip_text(None)

            return True
        else:
            print "display false"
            return False

    def get_info_text(self):
        """ Return info on current image and on list of files progress """
        text = "image %3d of %5d filename:%s" % (self.index, len(self.files), self.files[self.index])
        return text

    def on_tick(self):
        """ Skip to another picture.

        If this picture is last, go to the first one. """

        # TODO: check did we manage to show the last image?
        if g_lastpainted == self.files[self.index]:
            print "happiness"
        else:
            print "much SADness, we should wait some more", g_lastpainted
            print "much SADness, we should wait some more", self.index
            print "much SADness, we should wait some more", self.files[self.index]

        global g_pause
        if not g_pause:
            self.index += 1
            if self.index >= len(self.files):
                if g_repeat:
                    print "wrap"
                    self.index = 0
                else:
                    # end of show
                    sys.exit(0)

        rv = self.display()

        if self.old_slide_time != self.SECONDS_BETWEEN_PICTURES:
            # change time and register new time
            glib.timeout_add_seconds(self.SECONDS_BETWEEN_PICTURES, self.on_tick)
            self.old_slide_time = self.SECONDS_BETWEEN_PICTURES
            rv = False

        # returning false destroys the old timer
        return rv


    def handle_input(self, widget, event):
        print "Handle user input. Event number:%d" % event.type
        # http://www.pygtk.org/pygtktutorial/sec-eventhandling.html
        x,y,state = 0, 0, ""
        if event.type == gtk.gdk.KEY_PRESS:
            keyname = gtk.gdk.keyval_name(event.keyval)
            print "Key %s (%d) was pressed" % (keyname, event.keyval)

            if ( event.keyval == 27 or keyname == 'q' or keyname == 'Q' or keyname == 'Escape' or
               ( keyname == 'C' or keyname == 'c' and ( event.state == gtk.gdk.CONTROL_MASK | gtk.gdk.MOD2_MASK))):
                print "exit because of ESC or Ctrl-c or 'q' key"
                sys.exit(0)

            elif event.keyval == 32:
                # TODO: toggle pause
                global g_pause
                g_pause = not g_pause
                if g_pause:
                    global g_info_text
                    g_info_text = "\nPaused\nHit <space> to unpause.\n"
                    print g_info_text

            elif keyname == 'n' or keyname == 'N' or keyname == 'Right':
                # NEXT image
                self.index += 1
                if self.index >= len(self.files):
                    if g_repeat:
                        print "wrap"
                        self.index = 0
                    else:
                        # end of show
                        sys.exit(0)
                # display immediately
                self.display()

            elif keyname == 'p' or keyname == 'P' or keyname == 'Left':
                # PREV image
                self.index -= 1
                if self.index < 0:
                    self.index = 0
                # display immediately
                self.display()

            elif keyname == "minus":
                self.SECONDS_BETWEEN_PICTURES+=1
                if self.SECONDS_BETWEEN_PICTURES>360:
                    self.SECONDS_BETWEEN_PICTURES=360
                global g_info_speed
                g_info_speed = "\nSLOWER! %d\n" % (self.SECONDS_BETWEEN_PICTURES)
                print g_info_speed

            elif keyname == "plus":
                self.SECONDS_BETWEEN_PICTURES-=1
                if self.SECONDS_BETWEEN_PICTURES<0:
                    self.SECONDS_BETWEEN_PICTURES=0
                global g_info_speed
                g_info_speed = "\nFASTER! %d\n" % (self.SECONDS_BETWEEN_PICTURES)
                print g_info_speed

            elif keyname == 'i' or keyname == 'I':
                global g_info
                g_info = not g_info

            elif ( keyname == 'h' or keyname == 'H' or
                   keyname == 'm' or keyname == 'M' ):
                # TODO: print help/menu on run screen :- toggle show/hide help menu here
                global g_help, g_help_text
                g_help = not g_help
                print g_help_text

            else:
                global g_info_text
                g_info_text = "\nUnknown/unhandled key press.\nTry 'h' for help.\nkey:%s val:%d\n" % (keyname, event.keyval)
                print g_info_text
                g_info_text = False

        elif event.type == gtk.gdk.BUTTON_PRESS or event.is_hint:
            x, y, state = event.window.get_pointer()

        else:
            x = event.x
            y = event.y
            state = event.state
            print "event x,y state:%d,%d %s" % (x,y,state)


import sys
import getopt

def process_args():
    # parse command line options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hwrdfns", ["help","window","repeat","delay","fullscreen","name","nosort","no"] )
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)
    # process options
    global g_fullscreen,g_repeat,g_slide_time,g_sort
    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            sys.exit(0)
        if o in ("-w", "--window"):
            g_fullscreen = False
        if o in ("-f", "--fullscreen"):
            g_fullscreen = True
        if o in ("-r", "--repeat"):
            g_repeat = True
        if o in ("-d", "--delay"):
            g_slide_time = 3
        if o in ("-n", "--name"):
            g_sort = "byName"
            print "Sort by name:", g_sort            
        if o in ("-s", "--nosort"):
            g_sort = None
            print "Sort by none:", g_sort            
    # e.g. process arguments
    #for arg in args:
    #    process(arg) # process() is defined elsewhere
    return args

if __name__ == "__main__":
    args = process_args()
    gui = DemoGtk(args)
    gtk.main()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
