/* Main code for Test Template */

#include <PalmOS.h>

#include "stopWatchRsc.h"
#define VERSION "0.1"

void DEBUGBOX(char *ARGSTR1, char *ARGSTR2) {
  char buf[1000];
  int l=0;
  l+=StrPrintF(buf+l, "debugbox - %s %s:%d\n", 
     __FUNCTION__, __FILE__, __LINE__);
  FrmCustomAlert(alertInfo, buf, ARGSTR1, ARGSTR2);
}

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
     // playFreq(sndCmdFrqOn,x*20,y*10,10); // freq,maxdur, amp(0 - sndMaxAmp)
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

void drawCount(UInt32 dtik) {
    char buf[100];
    int l=0;
    unsigned long int s,hour,min,sec,hs;
    //l=0;
    //l+=StrPrintF(buf+l, "Ticks %lu", dtik);
    //FntSetFont(largeBoldFont);
    //WinPaintChars(buf,l,1,100);

    //ms = dtik / (SysTicksPerSecond()/1000);
    s = dtik / (SysTicksPerSecond()/100);
    hs = s % 100;
    s = s / 100;
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
    if (sec == 0) {
	int i;
	for(i=0;i<min%10;i++){
	    playFreq(sndCmdFrqOn,100+min*4,10,10); // freq,maxdur, amp(0 - sndMaxAmp)
	}
	// and progress bar
	/* eraseRectangleSafe(0, 20, 160, 20); // x,y,width,height
	drawRectangleSafe(0, 20, min * 4, 20); // x,y,width,height
	eraseRectangleSafe((min * 4)-1, 41, 160, 1); // x,y,width,height
	drawRectangleSafe((min * 4)-1, 41, 1, 1); // x,y,width,height
	if ((min%5)==0){
	    eraseRectangleSafe((min * 4)-2, 41, 160, 2); // x,y,width,height
	    drawRectangleSafe((min * 4)-2, 41, 2, 2); // x,y,width,height
	    } */

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
	drawRectangleSafe(4+36*(((min-1)/5)%4), 
			  20 + 30*((min-1)/20) + 5*((min-1)%5), 
			  32, 3); // x,y,width,height

    }

    /* for testing
    drawRectangleSafe(4+36*(((sec-1)/5)%4), 
		      20 + 30*((sec-1)/20) + 5*((sec-1)%5), 
		      32, 3); // x,y,width,height
    */
}

static Boolean MainFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    static UInt32 start_sec=0;
    static UInt32 start_tik;
    static UInt32 end_sec;
    static UInt32 end_tik;
    static int run = 0;
    
    switch (e->eType) {
    case frmOpenEvent:
	frm = FrmGetActiveForm();
	FrmDrawForm(frm);
	handled = true;
	break;

    case menuEvent:
	MenuEraseStatus(NULL);

	switch(e->data.menu.itemID) {
	    // TODO add to TestTemp code
	    //case itemBar:
	    case itemRun:
		if (start_sec == 0) {
		    start_sec = TimGetSeconds();
		    start_tik = TimGetTicks();
		}
		{
		    UInt32 tik,dtik;
		    int i;
		    run=1;
		    while(run==1) {
			tik = TimGetTicks();
			dtik = tik - start_tik;
			drawCount(dtik);

			// call this periodically to hold off auto off  
			EvtResetAutoOffTimer();

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
		end_tik = 0;
		drawCount(0);
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
		break;

	    case itemTest2:
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
		    start_sec = TimGetSeconds();
		    start_tik = TimGetTicks();
		}
		{
		    UInt32 tik,dtik;
		    int i;
		    run=1;
		    while(run==1) {
			tik = TimGetTicks();
			dtik = tik - start_tik;
			drawCount(dtik);

			// call this periodically to hold off auto off  
			EvtResetAutoOffTimer();

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
		start_sec = 0;
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
	}
	handled = true;
    }

    return handled;
}

/* Get preferences, open (or create) app database */
static UInt16 StartApplication(void)
{
    FrmGotoForm(MainForm);
    return 0;
}

/* Save preferences, close forms, close app database */
static void StopApplication(void)
{
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
