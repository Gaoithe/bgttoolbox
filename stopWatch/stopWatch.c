#include "stopWatch.h"

stopWatchPreferenceType stopWatchPrefs;

void playFreq(SndCmdIDType cmd, int freq, int time, int amp)
{
   SndCommandType soundCmd;
  
   //soundCmd.cmd=sndCmdFreqDurationAmp; // blocking

   // non-blocking!  better to use this and key press start sound, key up ends it.
   soundCmd.cmd=cmd; // sndCmdFrqOn; 

   soundCmd.param1 = freq; /*freq in hz */
   soundCmd.param2 = time; /*max dur in ms */
   soundCmd.param3 = amp; /*amp 0 - sndMaxAmp */

   SndDoCmd(NULL, &soundCmd, 0/*nowait*/);

      //} else {
      // if sound off delay useful for playback
      //if (cmd == sndCmdFreqDurationAmp) // force delay
      //   SysTaskDelay((time * SysTicksPerSecond())/1000);
      //}
}

void stopFreq()
{
   SndCommandType soundCmd;
   soundCmd.cmd=sndCmdQuiet;
   SndDoCmd(NULL, &soundCmd, 0/*nowait*/);
}

static void doPenAction(int e, int x, int y, int endx, int endy)
{

   switch(e){
   case penDownEvent:
   case penMoveEvent:

     /* doing dialog debug box on penUp gives us infinate loop */
     if (0){
       char buf[1000];
       int l=0;
       l+=StrPrintF(buf+l, "event: %d x,y %d,%d end x,y %d,%d\n",
		    e, x, y, endx, endy);
       buf[l]=0;
       DEBUGBOX("doPenAction",buf);
     }

     // Middle C is 262Hz
     // playFreq(sndCmdFrqOn,x*20,y*10,stopWatchPrefs.vol); // freq,maxdur, amp(0 - sndMaxAmp)
     // this could possibly get annoying

     break;

   case penUpEvent:
       // stopFreq();
     break;
         
   }
}

void eraseRectangleSafe(int sx, int sy, int w, int h) // x,y,width,height
{
   int y,x;
   for(y=sy,x=sx;y<sy+h;y++)
       WinEraseLine(x,y,x+w,y);
}

void drawRectangleSafe(int sx, int sy, int w, int h) // x,y,width,height
{
   int y,x;
   //DEBUGBOX("drawRect","");
   for(y=sy,x=sx;y<sy+h;y++)
      WinDrawLine(x,y,x+w,y);
   //RectangleType r; // = { {0, l, {160, 12} };
   //RctSetRectangle(&r, sx, sy, w, h); // x,y,width,height
   //WinDrawRectangleFrame(dialogFrame, &r); 
   // sdk/include/Core/System/Window.h
}

void clearScreen(void)
{
    //WinEraseRectangle(&dis_area, 0);
}

//extern void WinDrawLineF(Coord x1, Coord y1, Coord x2, Coord y2);
//extern void WinEraseLineF(Coord x1, Coord y1, Coord x2, Coord y2);
//void WinDrawLine (Coord x1, Coord y1, Coord x2, Coord y2) // and WinEraseLine
typedef void (*WinDrawLine_fn)(Coord x1, Coord y1, Coord x2, Coord y2);

void WinDrawLineF(Coord x1, Coord y1, Coord x2, Coord y2)
{
   WinDrawLine(x1,y1,x2,y2);
}

void WinEraseLineF(Coord x1, Coord y1, Coord x2, Coord y2)
{
   WinEraseLine(x1,y1,x2,y2);
}

typedef struct {
    int w,h;
    int tw,th;
} digiFontType;

void drawHSeg(int sx, int sy, digiFontType ft, WinDrawLine_fn WinDrawLine)
{
    int x1,x2,y1,y2;
    int i;
    x1 = sx;
    x2 = sx + ft.w + (ft.th-1)*2; // maybe (ft.th-1)
    for(i=0;i<=ft.th;i++){
	y1=sy+i;
	y2=sy-i;
	WinDrawLine(x1,y1,x2,y1);
	WinDrawLine(x1,y2,x2,y2);
	x1++; x2--;
    }
}

void drawVSeg(int sx, int sy, digiFontType ft, WinDrawLine_fn WinDrawLine)
{
    int x1,x2,y1,y2;
    int i;
    y1 = sy;
    y2 = sy + ft.w + (ft.th-1)*2; // maybe (ft.th-1)
    for(i=0;i<=ft.th;i++){
	x1=sx+i;
	x2=sx-i;
	WinDrawLine(x1,y1,x1,y2);
	WinDrawLine(x2,y1,x2,y2);
	y1++; y2--;
    }
}

void bigStr(int x, int y, digiFontType ft, char *s, WinDrawLine_fn WinDrawLine)
{
} 

void bigDigit(int x, int y, char c, WinDrawLine_fn WinDrawLine) 
{
    digiFontType ft;
    ft.h = 20;
    ft.w = 12;
    ft.th = 4; ft.tw = 7;

    if (c=='0' || c=='2' || c=='3' || c=='5' || 
	c=='6' || c=='7' || c=='8' || c=='9') 
	drawHSeg(x+1,y,ft,WinDrawLine);
    if (c=='0' || c=='4' || c=='5' || 
	c=='6' || c=='8' || c=='9') 
	drawVSeg(x,y+1,ft,WinDrawLine);
    if (c=='0' || c=='1' || c=='2' || c=='3' || c=='4' || 
	c=='7' || c=='8' || c=='9') 
	drawVSeg(x+20,y+1,ft,WinDrawLine);
    if (c=='2' || c=='3' || c=='4' || c=='5' || 
	c=='6' || c=='8' || c=='9') 
	drawHSeg(x+1,y+20,ft,WinDrawLine);
    if (c=='0' || c=='2' ||
	c=='6' || c=='8') 
	drawVSeg(x,y+21,ft,WinDrawLine);
    if (c=='0' || c=='1' || c=='3' || c=='4' || c=='5' || 
	c=='6' || c=='7' || c=='8' || c=='9') 
	drawVSeg(x+20,y+21,ft,WinDrawLine);
    if (c=='0' || c=='2' || c=='3' || c=='5' || 
	c=='6'  || c=='8') 
	drawHSeg(x+1,y+40,ft,WinDrawLine);
}

void drawDiamond(int sx, int sy, int diw, WinDrawLine_fn WinDrawLine) // x,y,width
{
   int y,xl,xr;
   for(y=sy,xl=xr=sx+(diw/2);xr-xl<diw;y++,xl--,xr++)
      WinDrawLine(xl,y,xr,y);
   for(;xr>xl;y++,xl++,xr--)
      WinDrawLine(xl,y,xr,y);
}

void drawTriangle(int sx, int sy, int triw, WinDrawLine_fn WinDrawLine) // x,y,width
// only one way ... like this xxxxxx
//                                     xxxx
//                                      xx
{
   int y,xl,xr;
   for(y=sy,xl=sx,xr=xl+triw;xr>xl;y++,xl++,xr--)
      WinDrawLine(xl,y,xr,y);
}

// TODO: use timestamp stored in porefs so if palm turned off
//   or app switch, stopwatch should continue running
void drawCount(UInt32 dtik) {
    char buf[100];
    int l=0;
    unsigned long int s,hour,min,sec,hs;
    static unsigned long int lastsec=666;
    static unsigned long int lastmin=666;

    if (stopWatchPrefs.showTicks) {
	l=0;
	l+=StrPrintF(buf+l, "Ticks %lu", dtik);
	FntSetFont(largeBoldFont);
	WinPaintChars(buf,l,1,100);
    }

    //ms = dtik / (SysTicksPerSecond()/1000);
    s = dtik / (SysTicksPerSecond()/100);
    // for resumption of interrupted timer
    hs = s % 100;
    s = s / 100;
    s += stopWatchPrefs.tik_timestamp - stopWatchPrefs.timestamp;
    sec = s % 60;
    s = s / 60;
    min = s % 60;
    s = s / 60;
    hour = s % 60;
    l=0;
    l+=StrPrintF(buf+l, "%02d:%02d:%02d:%02d", (int)hour,(int)min,(int)sec,(int)hs);
    FntSetFont(largeBoldFont);
    WinPaintChars(buf,l,1,120);

    // a minute alarm
    if (sec == 0 && stopWatchPrefs.vol!=0) {
	int i;
	for(i=0;i<min%10;i++){
	    playFreq(sndCmdFrqOn,100+min*4,10,stopWatchPrefs.vol); 
            // freq,maxdur, amp(0 - sndMaxAmp)
	}
    }

    // not wanted every update, every second should do.
    if (sec != lastsec) {
	lastsec = sec;
	switch(stopWatchPrefs.visual) {
	    case btnVisualNum:
		// a big font

		// gfx too big & flickery ugly to flick every sec
		if (min != lastmin) {
		    lastmin=min;
		    bigDigit(5,20,'8',WinEraseLineF);
		    bigDigit(40,20,'8',WinEraseLineF);
		    //bigDigit(5,70,'8',WinEraseLineF);
		    bigDigit(80,20,'8',WinEraseLineF);
		    bigDigit(115,20,'8',WinEraseLineF);

		    l=0;
		    //l+=StrPrintF(buf+l, "%02d:%02d", (int)min,(int)sec);
		    l+=StrPrintF(buf+l, "%02d:%02d", (int)hour, (int)min);

		    bigDigit(5,20,buf[0],WinDrawLineF);
		    bigDigit(40,20,buf[1],WinDrawLineF);
		    //bigDigit(5,70,'7',WinDrawLineF);
		    bigDigit(80,20,buf[3],WinDrawLineF);
		    bigDigit(115,20,buf[4],WinDrawLineF);
		}
		break;

	    case btnVisualHour:
		break;

	    case btnVisualBar:
		eraseRectangleSafe(0, 20, 160, 20); // x,y,width,height
		drawRectangleSafe(0, 20, min * 4, 20); // x,y,width,height
		eraseRectangleSafe((min * 4)-1, 41, 160, 1); // x,y,width,height
		drawRectangleSafe((min * 4)-1, 41, 1, 1); // x,y,width,height
		if ((min%5)==0){
		    eraseRectangleSafe((min * 4)-2, 41, 160, 2); // x,y,width,height
		    drawRectangleSafe((min * 4)-2, 41, 2, 2); // x,y,width,height
		}
		break;

	    case btnVisualSticks:

		/* count like this 1 line = 1 minute
		   -----  -----  -----  -----
		   -----  -----  -----  -----
		   -----  -----  -----  -----
		   -----  -----  -----  -----
		   -----  -----  -----  -----
		   
		   -----
		   -----
		   160/4 = 40 => width 32 + 4 each side
		   base weights 1, 5, 20, oh look rns :)
		   3 height with 2 sep + 5 sep big blocks
		*/

		// better visually but is not a bar anymore
		/*drawRectangleSafe(4+36*(((min-1)/5)%4), 
				  20 + 30*((min-1)/20) + 5*((min-1)%5), 
				  32, 3); // x,y,width,height*/
		drawRectangleSafe(4+36*(((min)/5)%4), 
				  20 + 30*((min)/20) + 5*((min)%5), 
				  (32*sec)/59, 3); // x,y,width,height

		break;
	}

    }

    /* for testing
    drawRectangleSafe(4+36*(((sec-1)/5)%4), 
		      20 + 30*((sec-1)/20) + 5*((sec-1)%5), 
		      32, 3); // x,y,width,height
    */
}

int run = 0;
void RunCount(UInt32 start_tik)
{
    UInt32 tik,dtik;
    run=1;
    while(run==1) {
	tik = TimGetTicks();
	dtik = tik - start_tik;
	drawCount(dtik);

	// call this periodically to hold off auto off  
	if (stopWatchPrefs.disableAutoOff) EvtResetAutoOffTimer();

	// delay one tenth of a sec (.09 acksherly to be sly)
	SysTaskDelay((90 * SysTicksPerSecond())/1000);
	// within loop call SysHandleEvent to
	//  give system opportunity to break in? 
	// /opt/palmdev/sdk-5/include/Core/UI/Event.h
	{ 
	    UInt16 err;
	    EventType e;
	    EvtGetEvent(&e, 0);
	    if (! SysHandleEvent (&e))
		if (! MenuHandleEvent (NULL, &e, &err))
		    if (! ApplicationHandleEvent (&e))
			FrmDispatchEvent (&e);
	}
    }

}

static Boolean MainFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    static UInt32 start_sec=0;
    static UInt32 start_tik;
    static UInt32 end_sec;
    static UInt32 end_tik;
    //static int run = 0;
    
    switch (e->eType) {
    case frmOpenEvent:
	frm = FrmGetActiveForm();
	FrmDrawForm(frm);

	// resume interrupted count
	// note now stopWatchPrefs.tik_timestamp != stopWatchPrefs.timestamp
        // now this does work okay when switching away from app BUT
        // not when palm is turned off & on but stays in app
        // I think possibly GetTicks gets ticks from start of app
        // when palm off the ticks do not increment
	if (stopWatchPrefs.timestamp != 0) {
	    stopWatchPrefs.tik_timestamp = TimGetSeconds();
	    start_tik = TimGetTicks();
	    RunCount(start_tik);
	}

	handled = true;
	break;

    case menuEvent:
	MenuEraseStatus(NULL);

	switch(e->data.menu.itemID) {
	    // TODO add to TestTemp code
	    //case itemBar:
	    case itemRun:
		if (start_sec == 0) {
		    stopWatchPrefs.tik_timestamp =
			stopWatchPrefs.timestamp = 
			start_sec = TimGetSeconds();
		    start_tik = TimGetTicks();
		}
		RunCount(start_tik);
		break;
	    case itemHold:
		// break the run loop
		run = 0;
		break;
	    case itemStop:
		// break the run loop
		run = 0;
		end_sec = TimGetSeconds();
 		end_tik = TimGetTicks();
		break;
	    case itemClear:
		// break the run loop
		run = 0;
		start_sec = 0;
		stopWatchPrefs.timestamp = 0;
		stopWatchPrefs.tik_timestamp = 0;
		end_tik = 0;
		drawCount(0);
		break;

	    case itemPrefs:
		FrmPopupForm(PrefForm);
		break;

	    case itemTest1:

		WinDrawLine(20,20,50,50);
//void WinDrawChar (WChar theChar, Coord x, Coord y)
///void WinDrawChars (const Char *chars, Int16 len, Coord x, Coord y)
//void WinPaintChar (WChar theChar, Coord x, Coord y)
//void WinPaintChars (const Char *chars, Int16 len, Coord x, Coord y)
///opt/palmdev/sdk-5/include/Core/System/Window.h
// Font.h
		WinDrawChar('X',20,50);
		FntSetFont(symbol11Font);
		WinDrawChar('Y',40,50);
		FntSetFont(largeFont);
		WinDrawChar('Z',60,50);
		WinDrawChars("large Font",10,80,50);
		FntSetFont(largeBoldFont);
		WinDrawChars("large Bold",10,110,50);

		{
		    char buf[100];
		    int l=0;
		    UInt32 t = SysTicksPerSecond();
		    l+=StrPrintF(buf+l, "SysTicksPerSec is %lu", t);
		    FntSetFont(largeBoldFont);
		    WinPaintChars(buf,l,1,20);
		}

		if (0){
		    digiFontType ft;
		    ft.h = 20;
		    ft.w = 16;
		    ft.th = 4; ft.tw = 7;
		    drawHSeg(11,9,ft,WinDrawLineF);
		    drawVSeg(10,10,ft,WinDrawLineF);
		    drawHSeg(11,36,ft,WinDrawLineF);
		    drawVSeg(39,10,ft,WinDrawLineF);
		}

		if (0){
		    digiFontType ft;
		    ft.h = 20;
		    ft.w = 12;
		    ft.th = 4; ft.tw = 7;
		    drawHSeg(11,59,ft,WinDrawLineF);
		    drawVSeg(10,60,ft,WinDrawLineF);
		    drawVSeg(38,60,ft,WinDrawLineF);
		    drawHSeg(11,79,ft,WinDrawLineF);
		    drawVSeg(10,80,ft,WinDrawLineF);
		    drawVSeg(38,80,ft,WinDrawLineF);
		    drawHSeg(11,99,ft,WinDrawLineF);
		}

		bigDigit(5,20,'2',WinDrawLineF);
		bigDigit(40,20,'5',WinDrawLineF);
		bigDigit(5,70,'7',WinDrawLineF);
		break;

	    case itemTest2:

		bigDigit(5,20,'8',WinEraseLineF);
		bigDigit(40,20,'8',WinEraseLineF);
		bigDigit(5,70,'8',WinEraseLineF);

		WinDrawChars("Hello",5,20,80);
		WinPaintChars("Paint",5,20,110);

		//Err err; err = TimInit();
		{
		    char buf[100];
		    int l=0;
		    UInt32 s,t;
		    UInt32 hour,min,sec;
		    UInt32 day;
		    // seconds since 1/1/1904
		    //void TimSetSeconds(UInt32 seconds) 	
		    // ticks since power on
		    t = TimGetTicks();
		    s = TimGetSeconds();
		    
		    l+=StrPrintF(buf+l, "Secs %lu", s);
		    FntSetFont(largeBoldFont);
		    WinPaintChars(buf,l,1,20);

		    l=0;
		    l+=StrPrintF(buf+l, "Ticks %lu", t);
		    FntSetFont(largeBoldFont);
		    WinPaintChars(buf,l,1,40);

		    day = s / (UInt32)(24 * 60 * 60);
		    s = s - day * (24 * 60 * 60);
		    hour = s / (60 * 60);
		    s = s - hour * (60 * 60);
		    min = s / 60;
		    sec = s - min * 60;
		    l=0;
		    l+=StrPrintF(buf+l, "%07d:%02d:%02d:%02d", day, hour,min,sec);
		    FntSetFont(largeBoldFont);
		    WinPaintChars(buf,l,1,60);

		}
		break;

		// call this periodically to hold off auto off  
		// Err EvtResetAutoOffTimer(void)

// SystemMgr.h
//Err SysTimerCreate(UInt32 *timerIDP, UInt32 *tagP, 
//            SysTimerProcPtr timerProc, UInt32 periodicDelay, UInt32	param)
//Err		SysTimerDelete(UInt32 timerID)
//Err		SysTimerWrite(UInt32 timerID, UInt32 value)
//Err		SysTimerRead(UInt32 timerID, UInt32 *valueP)

//      SysTaskDelay((100 * SysTicksPerSecond())/1000);

	    case itemOptHelp:
		FrmHelp(hlpHelp);
		break;
		//case itemOptDbgDump:
		//debugDump(e->eType);
		//break;
	    case itemOptCopy:
		FrmHelp(hlpCopy);
		break;
	    case itemOptAbout:
		FrmCustomAlert(alertInfo, 
			       "stopWatch v" VERSION " not even Alpha. "
			       "Built " __DATE__ ", " __TIME__ ". "
			       "James Coleman http://www.dspsrv.com/~jamesc "
			       "copyleft me.", "", "");
		break;

	}

	//DEBUGBOX("menuEvent","");

    	handled = true;
	break;

    case ctlSelectEvent:
	switch(e->data.ctlSelect.controlID) {

	    case btnRun:
		if (start_sec == 0) {
		    stopWatchPrefs.tik_timestamp =
			stopWatchPrefs.timestamp = 
			start_sec = TimGetSeconds();
		    start_tik = TimGetTicks();
		}
		RunCount(start_tik);
		break;
	    case btnHold:
		// break the run loop
		run = 0;
		break;
	    case btnStop:
		// break the run loop
		run = 0;
		end_sec = TimGetSeconds();
 		end_tik = TimGetTicks();
		break;
	    case btnClear:
		// break the run loop
		run = 0;
		stopWatchPrefs.timestamp = start_sec = 0;
		stopWatchPrefs.tik_timestamp = 0;
		end_tik = 0;
		drawCount(0);
		break;

	}
	break;

    //case ctlRepeatEvent:
    //break;

    case penDownEvent:
    case penMoveEvent:
      doPenAction( e->eType, e->screenX, e->screenY, 0, 0); 
      //FrmCustomAlert(alertInfo, "pen down", "ARGSTR1", "ARGSTR2");
      break;

    case penUpEvent:
      doPenAction( penUpEvent, 
      	   e->data.penUp.start.x, e->data.penUp.start.y, 
      	   e->data.penUp.end.x, e->data.penUp.end.y);
      break;

    case keyDownEvent:

      {
	char buf[1000];
	int l=0;
	l+=StrPrintF(buf+l, "Char: %c %02x\n",e->data.keyDown.chr,e->data.keyDown.chr);
	buf[l]=0;
	DEBUGBOX("keyDownEvent",buf);
      }

      switch(e->data.keyDown.chr) {
      case pageUpChr:
      case pageDownChr:
	handled = true;
	break;
      case prevFieldChr:
      case nextFieldChr:
      case '\n':
	handled = true;
	break;
      default:
	if (!TxtCharIsCntrl(e->data.keyDown.chr)) {
	  handled = true;                 /* Swallow event */
	}
	break;
      }
      break;

    default:
        break;
    }

    return handled;
}

static void PrefFormSetValue(FormPtr frm, UInt16 id, UInt16 value)
{
    ControlPtr ctr;
    ctr = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, id));
    CtlSetValue(ctr, value);
}

static Boolean PrefFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    UInt16 i;
    
    frm = FrmGetActiveForm();
    switch (e->eType) {
        case frmOpenEvent:
            FrmDrawForm(frm);
            PrefFormSetValue(frm, chkDisableAutoOff, 
			     stopWatchPrefs.disableAutoOff);
            PrefFormSetValue(frm, chkShowTicks, 
			     stopWatchPrefs.showTicks);

            PrefFormSetValue(frm, btnSoundOff, 
			     btnSoundOff == stopWatchPrefs.sound);
            PrefFormSetValue(frm, btnSound1, 
			     btnSound1 == stopWatchPrefs.sound);
            PrefFormSetValue(frm, btnSound2, 
			     btnSound2 == stopWatchPrefs.sound);
            PrefFormSetValue(frm, btnSound3, 
			     btnSound3 == stopWatchPrefs.sound);
            PrefFormSetValue(frm, btnSoundHigh, 
			     btnSoundHigh == stopWatchPrefs.sound);

            PrefFormSetValue(frm, btnVisualNum, 
			     btnVisualNum == stopWatchPrefs.visual);
            PrefFormSetValue(frm, btnVisualBar, 
			     btnVisualBar == stopWatchPrefs.visual);
            PrefFormSetValue(frm, btnVisualSticks, 
			     btnVisualSticks == stopWatchPrefs.visual);
            PrefFormSetValue(frm, btnVisualHour, 
			     btnVisualHour == stopWatchPrefs.visual);

            handled = true;
            break;

        case menuEvent:
            MenuEraseStatus(NULL);
            handled = true;
            break;

        case ctlSelectEvent:
            switch(e->data.ctlSelect.controlID) {
		case chkDisableAutoOff:
		    stopWatchPrefs.disableAutoOff=e->data.ctlSelect.on;
                    break;
		case chkShowTicks:
		    stopWatchPrefs.showTicks=e->data.ctlSelect.on;
                    break;

                case btnSoundOff:
                    stopWatchPrefs.sound=e->data.ctlSelect.controlID;
                    stopWatchPrefs.vol=0;
                    break;
                case btnSound1:
                    stopWatchPrefs.sound=e->data.ctlSelect.controlID;
                    stopWatchPrefs.vol=5;
                    break;
                case btnSound2:
                    stopWatchPrefs.sound=e->data.ctlSelect.controlID;
                    stopWatchPrefs.vol=10;
                    break;
                case btnSound3:
                    stopWatchPrefs.sound=e->data.ctlSelect.controlID;
                    stopWatchPrefs.vol=30;
                    break;
                case btnSoundHigh:
                    stopWatchPrefs.sound=e->data.ctlSelect.controlID;
                    stopWatchPrefs.vol=50;
                    break;
		case btnVisualNum:
		case btnVisualBar:
		case btnVisualSticks:
		case btnVisualHour:
                    stopWatchPrefs.visual=e->data.ctlSelect.controlID;
                    break;

                case btnOk:
                    // set things
                    /* tell main form to update itself. */
                    //FrmUpdateForm(MainForm, UPDATE_LISTING);
                    /* FALLTHROUGH */
                case btnCancel: // cancel is TODO
                    FrmReturnToForm(MainForm);
                    handled = true;
                    break;

            }
            break;

        default:
            break;
    }
    
    return handled;
}

static Boolean ApplicationHandleEvent(EventPtr e)
{
    FormPtr frm;
    UInt16    formId;
    Boolean handled = false;

    if (e->eType == frmLoadEvent) {
	formId = e->data.frmLoad.formID;
	frm = FrmInitForm(formId);
	FrmSetActiveForm(frm);

	switch(formId) {
	    case MainForm:
		FrmSetEventHandler(frm, MainFormHandleEvent);
		break;
            case PrefForm:
                FrmSetEventHandler(frm, PrefFormHandleEvent);
                break;
	}
	handled = true;
    }

    return handled;
}

/* Get preferences, open (or create) app database */
static UInt16 StartApplication(void)
{
    UInt16 prefsize,i;
    /* Fetch application preferences */
    prefsize = sizeof(stopWatchPreferenceType);
    i = PrefGetAppPreferences('StWt', 0, &stopWatchPrefs, &prefsize, true);

    /* If no prefs were found, reset all values. */
    if (noPreferenceFound == i) {
        //DEBUGBOX("no prefs","");
        stopWatchPrefs.timestamp = 0;
        stopWatchPrefs.vol=10;
        stopWatchPrefs.sound=btnSound2;
        stopWatchPrefs.visual=btnVisualNum;
        stopWatchPrefs.disableAutoOff = 1;
    }

    FrmGotoForm(MainForm);
    return 0;
}

/* Save preferences, close forms, close app database */
static void StopApplication(void)
{
    PrefSetAppPreferences('StWt', 0, stopWatchPrefVersionNum,
            &stopWatchPrefs, sizeof(stopWatchPreferenceType), true);
    FrmSaveAllForms();
    FrmCloseAllForms();
}

/* The main event loop */
static void EventLoop(void)
{
    UInt16 err;
    EventType e;

    do {
	EvtGetEvent(&e, evtWaitForever);
	if (! SysHandleEvent (&e))
	    if (! MenuHandleEvent (NULL, &e, &err))
		if (! ApplicationHandleEvent (&e))
		    FrmDispatchEvent (&e);
    } while (e.eType != appStopEvent);
}

/* Main entry point; it is unlikely you will need to change this except to
   handle other launch command codes */
UInt32 PilotMain(UInt16 cmd, void *cmdPBP, UInt16 launchFlags)
{
    UInt16 err;

    if (cmd == sysAppLaunchCmdNormalLaunch) {

	err = StartApplication();
	if (err) return err;

	EventLoop();
	StopApplication();

    } else {
	return sysErrParamErr;
    }

    return 0;
}
