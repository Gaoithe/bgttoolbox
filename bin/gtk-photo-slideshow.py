#!/usr/bin/python

# Taken and customed from Jack Valmadre's Blog:
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
# TODO: keyboard control, next previous ...
# TODO: don't catch exceptions, handle file not found, slow reading (show warning) 

"""gtk-photo-slideshow.py [-hwrd] [dirs]
 -h --help
 -w --window
 -r --repeat
 -d --delay (TODO: doesn't take a number yet)

python script quick and simplish photo slideshow of directories
"""

import os

import pygtk
pygtk.require('2.0')
import gtk
import glib

slide_time = 3
fullscreen = False
repeat = False
lastpainted = -1

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
        global lastpainted
        lastpainted = filename

    def invalidate(self):
        self.queue_draw()

class DemoGtk:

    SECONDS_BETWEEN_PICTURES = slide_time
    FULLSCREEN = fullscreen
    WALK_INSTEAD_LISTDIR = True

    def __init__(self,args):
        self.window = gtk.Window()
        self.window.connect('destroy', gtk.main_quit)
        self.window.set_title('Slideshow')

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
            for directory, sub_directories, files in os.walk(arg):
                print "dir:", directory
                for filename in files:
                    #print "allfile:", filename
                    filepath = os.path.join(directory, filename)
                    if is_image(filepath):
                        self.files.append(filepath)
                        print "dirFile:", filename
                print "%d images."% len(self.files)
          else:
            for filename in os.listdir(arg):
                if is_image(filename):
                    self.files.append(filename)
                    print "File:", filename
                    #print "Images:", self.files

        #print "Images:", self.files
        print "TOTAL: %d images."% len(self.files)
        # sort in order of date of file
        self.files.sort(key=lambda s: os.path.getmtime(s))

    def display(self):
        """ Sent a request to change picture if it is possible """
        if 0 <= self.index < len(self.files):
            self.image.set_from_file(self.files[self.index])
            print "display index", self.index
            print "display true", self.files[self.index]
            return True
        else:
            print "display false"
            return False

    def on_tick(self):
        """ Skip to another picture.

        If this picture is last, go to the first one. """

        # TODO: check did we manage to show the last image?
        if lastpainted == self.files[self.index]:
            print "happiness"
        else:
            print "much SADness, we should wait some more", lastpainted
            print "much SADness, we should wait some more", self.index
            print "much SADness, we should wait some more", self.files[self.index]

        self.index += 1
        if self.index >= len(self.files):
            if repeat:
                print "wrap"
                self.index = 0
            else:
                # end of show
                sys.exit(0)

        return self.display()


import sys
import getopt

def process_args():
    # parse command line options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hwrdf", ["help","window","repeat","delay"] )
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)
    # process options
    #global fullscreen
    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            sys.exit(0)
        if o in ("-w", "--window"):
            fullscreen = False
        if o in ("-f", "--fullscreen"):
            fullscreen = True
        if o in ("-r", "--repeat"):
            repeat = True
        if o in ("-d", "--delay"):
            slide_time = 3
    # e.g. process arguments
    #for arg in args:
    #    process(arg) # process() is defined elsewhere
    return args

if __name__ == "__main__":
    args = process_args()
    gui = DemoGtk(args)
    gtk.main()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
