#!/usr/bin/python

'''
http://stackoverflow.com/questions/6616270/python-right-click-menu-using-pygtk
'''

import sys, os
import pygtk, gtk, gobject

class app:

   def __init__(self):
    window = gtk.Window(gtk.WINDOW_TOPLEVEL)
    window.set_title("TestApp")
    window.set_default_size(320, 240)
    window.connect("destroy", gtk.main_quit)

    # if the  window is shown here the later event mask setting doesn't work.
    #window.show_all()

    # Create a widget to listen for mouse events on. In this case it's a button.
    #button = gtk.Button("A Button")
    #button.show()

    # Create a menu
    menu = gtk.Menu()
    #menu.show()

    ## A vbox to put a menu and a button in:
    vbox = gtk.VBox(False, 0)
    window.add(vbox)
    vbox.show()
    #vbox.pack_end(button, True, True, 2)

    # Create the drawing area
    drawing_area = gtk.DrawingArea()
    drawing_area.set_size_request(200, 200)
    vbox.pack_start(drawing_area, True, True, 0)
    drawing_area.show()

    drawing_area.connect("button_press_event", self.button_pr)

    # Fill menu with menu items
    menu_item = gtk.MenuItem("A menu item")
    menu.append(menu_item)
    menu_item.show()

    # Make the widget listen for mouse press events, attaching the menu to it.
    #button.connect_object("event", self.button_press, menu)

    window.connect_object("event", self.button_press, menu)
    
    #nope window.connect_object("clicked", self.button_click, menu)
    #nope vbox.connect_object("clicked", self.button_click, menu)

    #window.connect("button-release-event", self.button_rel)
    window.set_events(gtk.gdk.EXPOSURE_MASK |
                      gtk.gdk.BUTTON_PRESS_MASK |
                      gtk.gdk.BUTTON_RELEASE_MASK )

    #window.connect("button_press_event", self.button_pr)
    window.connect_object("button_press_event", self.button_pr, menu)
    #window.set_events(gtk.gdk.EXPOSURE_MASK |
    #                  gtk.gdk.BUTTON_PRESS_MASK |
    #                  gtk.gdk.BUTTON_RELEASE_MASK |
    #                  gtk.gdk.LEAVE_NOTIFY_MASK |
    #                  gtk.gdk.POINTER_MOTION_MASK |
    #                  gtk.gdk.POINTER_MOTION_HINT_MASK)

    window.show_all()

   # Then define the method which handles these events. As is stated in the example in the link, the widget passed to this method is the menu that you want popping up not the widget that is listening for these events.

   def button_press(self, widget, event):
       print "button",event.type

       # button <enum GDK_LEAVE_NOTIFY of type GdkEventType>
       # button <enum GDK_ENTER_NOTIFY of type GdkEventType>
       # button <enum GDK_KEY_PRESS of type GdkEventType>
       # button <enum GDK_KEY_RELEASE of type GdkEventType>

       if event.type == gtk.gdk.BUTTON_PRESS and event.button == 3:
           # right click
           print "right click"
           pass
       if event.type == gtk.gdk.BUTTON_PRESS:
           #make widget popup
           widget.popup(None, None, None, event.button, event.time)

   def button_rel(self, widget, event):
       print "button_rel",event.type

   def button_pr(self, widget, event):
       print "button_pr",event.type

   def button_click(self, widget, event):
       print "button_click",event.type

app()
gtk.main()

'''
I wanna right click inside this window, and have a menu pop up like alert, copy, exit, whatever I feel like putting down.

There is a example for doing this very thing found at http://www.pygtk.org/pygtk2tutorial/sec-ManualMenuExample.html

It shows you how to create a menu attach it to a menu bar and also listen for a mouse button click event and popup the very same menu that was created.
'''

