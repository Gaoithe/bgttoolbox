#!/bin/bash
# Author: Andrew Martin
# Credit: http://ubuntuforums.org/showthread.php?t=1309247
# Via: http://www.thetechrepo.com/main-articles/502-how-to-change-the-primary-monitor-in-ubuntu-or-other-linux-distributions


# xprop -root
# xdpyinfo
# xvinfo

##xrandr --prop | grep "[^dis]connected" | cut --delimiter=" " -f1	# query connected monitors
INFO=$(xrandr --prop | grep "[^dis]connected")                          # query connected monitors
echo "$INFO"

echo "Enter the primary display from the following:"			# prompt for the display
DEVICES=$(echo "$INFO" | cut --delimiter=" " -f1)                       # show monitor id to user for selection.
echo "$DEVICES"

MONITORS=$(xrandr --verbose | awk '
/[:.]/ && hex {
    sub(/.*000000fc00/, "", hex)
    hex = substr(hex, 0, 26) "0a"
    sub(/0a.*/, "0a", hex)
    print hex
    hex=""
}
hex {
    gsub(/[ \t]+/, "")
    hex = hex $0
}
/EDID.*:/ {
    hex=" "
}' | xxd -r -p)
echo "MONITORS=$MONITORS"


#for d in $DEVICES; do 
# echo device/port=$d
# # $d:0 is not a display - it's the ?device/port/?
# # how get display from 
# #xmessage --display $d:0 "device/port=$d"
# #zenity --display $d:0 --info --text "device/port=$d"
# # notify-send -u critical "Mwahhh"
# # notify-send -u normal "Mwahhh"
# zenity --info --text "device/port=$d"
#done;

read choice								# read the users's choice of monitor
 
xrandr --output $choice --primary					# set the primary monitor
 



exit






[james@nebraska bin]$ who
james    :0           2015-01-20 10:35 (:0)
james    pts/0        2015-01-20 10:35 (:0)
james    pts/1        2015-01-20 10:36 (:0)
james    pts/2        2015-01-20 10:45 (:0)
james    pts/3        2015-01-20 10:47 (:0)
james    pts/4        2015-01-20 10:47 (:0)
james    pts/5        2015-01-20 10:49 (:pts/3:S.0)
james    pts/6        2015-01-20 10:49 (:pts/3:S.1)
james    pts/7        2015-01-20 10:49 (:pts/3:S.2)
james    pts/8        2015-02-20 12:09 (:pts/4:S.0)
james    pts/10       2015-01-20 11:10 (:0)
james    pts/11       2015-01-20 11:34 (:0)
james    pts/12       2015-01-20 14:00 (:0)
james    pts/13       2015-01-22 14:03 (:0)
james    pts/15       2015-01-22 16:58 (:pts/3:S.3)
james    pts/16       2015-01-22 17:15 (:pts/3:S.4)
james    pts/17       2015-01-23 14:44 (:pts/3:S.5)
james    pts/18       2015-01-29 12:23 (:pts/3:S.6)
james    pts/19       2015-01-30 14:03 (:0)
james    pts/20       2015-02-02 13:21 (:0)
james    pts/21       2015-02-04 13:30 (:0)
james    pts/22       2015-02-05 10:10 (:0)
james    tty2         2015-02-24 13:05
[james@nebraska bin]$ who -hs
who: invalid option -- 'h'
Try 'who --help' for more information.
[james@nebraska bin]$ w -hs
james    :0        ?xdm?  gdm-session-worker [pam/gdm-password]
james    pts/0     29days /usr/libexec/gnome-terminal-server
james    pts/1     19days bash
james    pts/2     19days bash
james    pts/3     11days screen
james    pts/4     22:25m screen
james    pts/5     20days /bin/bash
james    pts/6     11days /bin/bash
james    pts/7     13days /bin/bash
james    pts/8     22:25m ssh omn@vb-48
james    pts/10    53:03  bash
james    pts/11     7.00s w -hs
james    pts/12     1:42m /usr/libexec/gnome-terminal-server
james    pts/13     7days /usr/libexec/gnome-terminal-server
james    pts/15    11days /bin/bash
james    pts/16    18days /bin/bash
james    pts/17    18days /bin/bash
james    pts/18    27days /bin/bash
james    pts/19     9days bash
james    pts/20     2days bash
james    pts/21    27:20m ssh omn@valhalla-1
james    pts/22     4days bash
james    tty2      24:36m -bash

xvinfo -display :0  -short


[james@nebraska bin]$ xprop -display :0 
WM_STATE(WM_STATE):
		window state: Normal
		icon window: 0x0
_NET_FRAME_EXTENTS(CARDINAL) = 6, 6, 32, 6
_NET_WM_DESKTOP(CARDINAL) = 4294967295
_NET_WM_ALLOWED_ACTIONS(ATOM) = _NET_WM_ACTION_MOVE, _NET_WM_ACTION_RESIZE, _NET_WM_ACTION_FULLSCREEN, _NET_WM_ACTION_MINIMIZE, _NET_WM_ACTION_SHADE, _NET_WM_ACTION_MAXIMIZE_HORZ, _NET_WM_ACTION_MAXIMIZE_VERT, _NET_WM_ACTION_CHANGE_DESKTOP, _NET_WM_ACTION_CLOSE, _NET_WM_ACTION_ABOVE, _NET_WM_ACTION_BELOW
_NET_WM_STATE(ATOM) = _NET_WM_STATE_MAXIMIZED_HORZ, _NET_WM_STATE_MAXIMIZED_VERT
WM_HINTS(WM_HINTS):
		Client accepts input or input focus: True
		Initial state is Normal State.
		window id # of group leader: 0x2200001
XdndAware(ATOM) = BITMAP
_MOTIF_DRAG_RECEIVER_INFO(_MOTIF_DRAG_RECEIVER_INFO) = 0x6c, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x10, 0x0, 0x0, 0x0
_GTK_APP_MENU_OBJECT_PATH(UTF8_STRING) = "/org/gnome/Gedit/menus/appmenu"
_GTK_WINDOW_OBJECT_PATH(UTF8_STRING) = "/org/gnome/Gedit/window/1"
_GTK_APPLICATION_OBJECT_PATH(UTF8_STRING) = "/org/gnome/Gedit"
_GTK_UNIQUE_BUS_NAME(UTF8_STRING) = ":1.1802"
_GTK_APPLICATION_ID(UTF8_STRING) = "org.gnome.Gedit"
WM_WINDOW_ROLE(STRING) = "gedit-window-1421945727-378003-0-nebraska.ie.openmindnetworks.com"
_NET_WM_WINDOW_TYPE(ATOM) = _NET_WM_WINDOW_TYPE_NORMAL
_NET_WM_SYNC_REQUEST_COUNTER(CARDINAL) = 35651623, 35651624
_NET_WM_USER_TIME_WINDOW(WINDOW): window id # 0x2200026
WM_CLIENT_LEADER(WINDOW): window id # 0x2200001
_NET_WM_PID(CARDINAL) = 22004
WM_LOCALE_NAME(STRING) = "en_GB.UTF-8"
WM_CLIENT_MACHINE(STRING) = "nebraska.ie.openmindnetworks.com"
WM_NORMAL_HINTS(WM_SIZE_HINTS):
		program specified minimum size: 491 by 230
		program specified base size: 0 by 0
		window gravity: NorthWest
WM_PROTOCOLS(ATOM): protocols  WM_DELETE_WINDOW, WM_TAKE_FOCUS, _NET_WM_PING, _NET_WM_SYNC_REQUEST
WM_CLASS(STRING) = "gedit", "Gedit"
WM_ICON_NAME(STRING) = "mm1_phone_HOWTO (1) (~/Downloads) - gedit"
_NET_WM_ICON_NAME(UTF8_STRING) = "mm1_phone_HOWTO (1) (~/Downloads) - gedit"
WM_NAME(STRING) = "mm1_phone_HOWTO (1) (~/Downloads) - gedit"
_NET_WM_NAME(UTF8_STRING) = "mm1_phone_HOWTO (1) (~/Downloads) - gedit"




[james@nebraska bin]$ lspci |grep DVI-I-1
[james@nebraska bin]$ lspci |grep DVI
[james@nebraska bin]$ lspci |grep -i DVI
[james@nebraska bin]$ lspci |grep -i DELL
[james@nebraska bin]$ lspci |less
[james@nebraska bin]$ lspci |grep -i vga
01:00.0 VGA compatible controller: NVIDIA Corporation G92 [GeForce GTS 240] (rev a2)
[james@nebraska bin]$ lspci 
00:00.0 Host bridge: Intel Corporation Core Processor DMI (rev 11)
00:03.0 PCI bridge: Intel Corporation Core Processor PCI Express Root Port 1 (rev 11)
00:08.0 System peripheral: Intel Corporation Core Processor System Management Registers (rev 11)
00:08.1 System peripheral: Intel Corporation Core Processor Semaphore and Scratchpad Registers (rev 11)
00:08.2 System peripheral: Intel Corporation Core Processor System Control and Status Registers (rev 11)
00:08.3 System peripheral: Intel Corporation Core Processor Miscellaneous Registers (rev 11)
00:10.0 System peripheral: Intel Corporation Core Processor QPI Link (rev 11)
00:10.1 System peripheral: Intel Corporation Core Processor QPI Routing and Protocol Registers (rev 11)
00:16.0 Communication controller: Intel Corporation 5 Series/3400 Series Chipset HECI Controller (rev 06)
00:1a.0 USB controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06)
00:1b.0 Audio device: Intel Corporation 5 Series/3400 Series Chipset High Definition Audio (rev 06)
00:1c.0 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 1 (rev 06)
00:1d.0 USB controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a6)
00:1f.0 ISA bridge: Intel Corporation 5 Series Chipset LPC Interface Controller (rev 06)
00:1f.2 SATA controller: Intel Corporation 5 Series/3400 Series Chipset 6 port SATA AHCI Controller (rev 06)
00:1f.3 SMBus: Intel Corporation 5 Series/3400 Series Chipset SMBus Controller (rev 06)
01:00.0 VGA compatible controller: NVIDIA Corporation G92 [GeForce GTS 240] (rev a2)
02:00.0 Ethernet controller: Broadcom Corporation NetLink BCM57780 Gigabit Ethernet PCIe (rev 01)
ff:00.0 Host bridge: Intel Corporation Core Processor QuickPath Architecture Generic Non-Core Registers (rev 04)
ff:00.1 Host bridge: Intel Corporation Core Processor QuickPath Architecture System Address Decoder (rev 04)
ff:02.0 Host bridge: Intel Corporation Core Processor QPI Link 0 (rev 04)
ff:02.1 Host bridge: Intel Corporation Core Processor QPI Physical 0 (rev 04)
ff:03.0 Host bridge: Intel Corporation Core Processor Integrated Memory Controller (rev 04)
ff:03.1 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Target Address Decoder (rev 04)
ff:03.4 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Test Registers (rev 04)
ff:04.0 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 0 Control Registers (rev 04)
ff:04.1 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 0 Address Registers (rev 04)
ff:04.2 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 0 Rank Registers (rev 04)
ff:04.3 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 0 Thermal Control Registers (rev 04)
ff:05.0 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 1 Control Registers (rev 04)
ff:05.1 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 1 Address Registers (rev 04)
ff:05.2 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 1 Rank Registers (rev 04)
ff:05.3 Host bridge: Intel Corporation Core Processor Integrated Memory Controller Channel 1 Thermal Control Registers (rev 04)
