
TARGET = stopWatch
APPNAME = "StopWatch"
APPID = "BoGo"

OBJS = $(TARGET).o
LIBS =

CC = m68k-palmos-gcc
CFLAGS = -Wall -g -O2

PILRC = pilrc
#OBJRES = m68k-palmos-coff-obj-res
#NM = m68k-palmos-coff-nm
OBJRES = m68k-palmos-obj-res
NM = m68k-palmos-nm
BUILDPRC = build-prc
PILOTXFER = pilot-xfer -p /dev/ttyUSB0

all: $(TARGET).prc

############# GCC ##################
# one way of gccing
#CFLAGS = -S -Wall -O2 -DVERBOSE -g -I /PalmDev/sdk/include -I /PalmDev/sdk/include/Core -I /PalmDev/sdk/include/Core/Hardware -I /PalmDev/sdk/include/Core/System -I /PalmDev/sdk/include/Core/UI -I /PalmDev/sdk/include/Dynamic -I /PalmDev/sdk/include/libraries
#%.o: %.c
#	$(CC) $(CFLAGS) $(TARGETFLAGS) -c $< -o $*.S
#	$(AS) $*.S -o $@

# another way
CFLAGS = -Wall -g -O2
.S.o:
	$(CC) $(TARGETFLAGS) -c $<

.c.s:
	$(CC) $(CSFLAGS) $<

############# GCC ##################

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
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBS)
	! $(NM) -u $(TARGET) | grep .

install: send
send: $(TARGET).prc
	$(PILOTXFER) -i $(TARGET).prc

depend:
	makedepend -Y -I. *.c

clean:
	-rm -f *.[oa] $(TARGET) *.bin bin.res *.grc Makefile.bak

veryclean: clean
	-rm -f $(TARGET).prc pilot.ram pilot.scratch

