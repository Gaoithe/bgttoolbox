## Makefile for keepEupE for cygwin
# by James Coleman <jamesc@dspsrv.com>

######### somewhat crippled prc-tools on win98 cygwin lead to nastiness #######
### gcc -c whatever.c -o whatever.o => Assembler called with no args?
### so do gcc -c -S first, then as
### *whew*!      what a mess.
### related to problem with gcc and CYGWIN1.DLL ? maybe.

TARGET = keepEupE
APPNAME = "keepEupE"
APPID = "kEuE"

OBJS = $(TARGET).o keepEupEDraw.o keepEupEGame.o keepEupESound.o
LIBS = -lc

CC = /usr/m68k-palmos/bin/gcc -c -mown-gp
AS = m68k-palmos-as
LD = m68k-palmos-ld -mown-gp
#CFLAGS = -x c -S -Wall -O2 -DVERBOSE -g -I /PalmDev/sdk/include
CFLAGS = -S -Wall -O2 -DVERBOSE -g -I /PalmDev/sdk/include -I /PalmDev/sdk/include/Core -I /PalmDev/sdk/include/Core/Hardware -I /PalmDev/sdk/include/Core/System -I /PalmDev/sdk/include/Core/UI -I /PalmDev/sdk/include/Dynamic -I /PalmDev/sdk/include/libraries

PERL = perl
PILRC = pilrc
OBJRES = m68k-palmos-obj-res
BUILDPRC = build-prc
PILOTXFER = pilot-xfer -p /dev/ttyUSB0
#[jamesc@localhost keepEupE]$ pilot-xfer -p /dev/ttyUSB0 -i keepEupE.prc 
SYSTRAP_H = /usr/local/pilot/m68k-palmos-coff/include/PalmOS/System/SysTraps.h
M68328HWR_H = /usr/local/pilot/m68k-palmos-coff/include/PalmOS/Hardware/M68328Hwr.h

all: $(TARGET).prc

#difficulty overriding default rule?
#%.o: %.c
#	$(CC) $(CFLAGS) $(TARGETFLAGS) -c $< -o $*.S
#	$(AS) $*.S -o $@
# This results in Emul exception VERY hard to debug problems.

# another way, this seems to work
CFLAGS = -Wall -g -O2
.S.o:
	$(CC) $(TARGETFLAGS) -c $<

.c.s:
	$(CC) $(CSFLAGS) $<

$(TARGET).o: $(TARGET)Rsc.h $(TARGET).h

$(TARGET).prc: $(TARGET) $(TARGET)Rsc.h code0000.$(TARGET).grc code0001.$(TARGET).grc data0000.$(TARGET).grc pref0000.$(TARGET).grc rloc0000.$(TARGET).grc bin.res
	$(BUILDPRC) $(TARGET).prc $(APPNAME) $(APPID) code0001.$(TARGET).grc code0000.$(TARGET).grc data0000.$(TARGET).grc *.bin pref0000.$(TARGET).grc rloc0000.$(TARGET).grc

code0000.$(TARGET).grc: $(TARGET)
	$(OBJRES) $(TARGET)

code0001.$(TARGET).grc: code0000.$(TARGET).grc

data0000.$(TARGET).grc: code0000.$(TARGET).grc

pref0000.$(TARGET).grc: code0000.$(TARGET).grc

rloc0000.$(TARGET).grc: code0000.$(TARGET).grc

bin.res: $(TARGET).rcp $(TARGET).pbm
	$(PILRC) $(TARGET).rcp .
	touch bin.res

$(TARGET): $(OBJS)
	m68k-palmos-gcc -g $(OBJS) -o $(TARGET) -lc

install: send
send: $(TARGET).prc
	$(PILOTXFER) -i $(TARGET).prc

debug:
	m68k-palmos-coff-gdb $(TARGET)

depend:
	makedepend -Y -I. *.c

clean:
	bash -c "rm -f *.[oa] *.[isS] $(TARGET) *.bin bin.res *.grc Makefile.bak"

veryclean: clean
	-rm -f $(TARGET).prc pilot.ram pilot.scratch








