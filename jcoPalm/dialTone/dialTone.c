/* Main code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#define dialTone_DEBUG
#define dialTone_FUN

#include "dialToneRsc.h"

#include "dialTone.h"


#define HACKDEBUG 1
void dialToneDEBUG(char *s, EventPtr e)
{
#if HACKDEBUG
  char buf[1000];
  int l=0;

  l+=StrPrintF(buf+l, "%s", s);

  if (e != NULL){
    l+=StrPrintF(buf+l, "\nEvent type %d", e->eType);
  }

  buf[l]=0;

  FrmCustomAlert(alertInfo, "dialToneDEBUG", buf, "");

#endif
}






dialTonePreferenceType dialTonePrefs;

/* Version number of preference-structure. Change when changing
 * dialTonePreferenceType. */
#define dialTonePrefVersionNum 0

static char *dbs_buf = NULL;
static long current_address;

//static long last_address = 0;
//static int first_time = 1;
// moving them up here didn't help

static void doPenAction(dialToneGameType g, int e, int x, int y, int endx, int endy);

void debugDump(char c)
{
  char buf[1000];
  int l=0;

  l+=StrPrintF(buf+l, "State sound/game/enableEdit/enableStupid/debug: %d/%d/%d/%d/%d\n",
               dialTonePrefs.state.sound,
               dialTonePrefs.state.game,
               dialTonePrefs.state.enable_edit,
               dialTonePrefs.state.enable_stupid,
               dialTonePrefs.state.debug);

  l+=StrPrintF(buf+l, "Address: %ld %lx\n",
               dialTonePrefs.address, dialTonePrefs.address);

  l+=StrPrintF(buf+l, "Sound freq/dur/amp: %d %d %d\n",
               dialTonePrefs.freq,
               dialTonePrefs.dur,
               dialTonePrefs.amp);
  
  l+=StrPrintF(buf+l, "Pos x,y: %d,%d\n",
               dialTonePrefs.x,
               dialTonePrefs.y);
  
  l+=StrPrintF(buf+l, "Char: %c\n",c);

  buf[l]=0;

  FrmCustomAlert(alertInfo, buf, "", "");
}

/* Ascii hexadecimal string to long. This one gives you enough rope to hang
 * yourself with, so be careful. */
static long h2l(unsigned char *s)
{
    int i, c;
    long l = 0;
 
    if (NULL == s)
        return 0;
    for (i = 0; '\0' != s[i]; i++) {
        c = s[i];
        if (c > 'F')    /* Ensure uppercase */
            c -= 32;
        if (c > '9')    /* Ensure continous range over '0'-'F' */
            c -= 7;
        c -= '0';       /* Value of hex digit */
        l = (l << 4) | (c & 0x0F);
    }
    return l;
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
    static struct prefstate_s state;

    
    frm = FrmGetActiveForm();
    switch (e->eType) {
        case frmOpenEvent:
            FrmDrawForm(frm);

            i = (dialTonePrefs.state.sound);
            state = dialTonePrefs.state;  /* read state */

            //i = state.enable_edit;
            //PrefFormSetValue(frm, chkMemEdit, i);

            //i = state.enable_stupid;
            //PrefFormSetValue(frm, chkAllowStupid, i);

            i = state.debug;
            PrefFormSetValue(frm, chkAllowDebug, i);

            handled = true;
            break;

        case menuEvent:
            MenuEraseStatus(NULL);
            handled = true;
            break;

        case ctlSelectEvent:
            switch(e->data.ctlSelect.controlID) {
                case btnOk:
                    // set things
                    dialTonePrefs.state = state;  /* save state */
                    /* tell main form to update itself. */
                    FrmUpdateForm(MainForm, UPDATE_LISTING);
                    /* FALLTHROUGH */
                case btnCancel:
                    FrmReturnToForm(MainForm);
                    handled = true;
                    break;
                case btnSoundLow:
                    dialTonePrefs.amp=2;
                    break;
                case btnSound1:
                    dialTonePrefs.amp=5;
                    break;
                case btnSound2:
                    dialTonePrefs.amp=10;
                    break;
                case btnSound3:
                    dialTonePrefs.amp=30;
                    break;
                case btnSoundHigh:
                    dialTonePrefs.amp=50;
                    break;
                case btnSysCallNum:
                    break;
                case btnSysCallName:
                    break;
	        case fieldPiezoHyst:
		    // TODO
	            break;
		    //case chkMemEdit:
                    //state.enable_edit = e->data.ctlSelect.on;
                    //break;
		    //case chkAllowStupid:
                    //state.enable_stupid = e->data.ctlSelect.on;
                    //break;
                case chkAllowDebug:
                    state.debug = e->data.ctlSelect.on;
                    break;
            }
            break;

        default:
            break;
    }
    
    return handled;
}

static void displaySeekretDialog(void)
{
#ifdef dialTone_FUN
  {
    FrmCustomAlert(alertInfo, 
                   "This is a dangerous seekret thing.\n"
                   "Doesn't do anything yet.\n",
                   "", "");
  }
#endif
}

static void doSeekretAction(char c)
{
#ifdef dialTone_FUN
   debugDump(c);
   switch(c) {
   case 'g':
    //void WinDrawBitmap (BitmapPtr bitmapP, SUInt16 x, Sword y) 
      break;
   case 'm':
   {
   }
   break;
   }
#endif
}

static void doPenAction(dialToneGameType g, int e, int x, int y, int endx, int endy)
{
   static int shape;

   dialTonePrefs.x = x;
   dialTonePrefs.y = y;

   switch(g){
   case dialToneGame:
      switch(e){
      case penDownEvent:
         break;

      case penUpEvent:

         // can get unhandled penUp just after starting

         // it should go quiet itself
         // in play dialTone game we don't finish sound until next key down
         //    in case key down&up too fast

         // unflash here to keep more user interactivity feeling
         //flashShape(shape,&WinDrawLineF);
         break;
         
      }
      break;

   case musicGame:
      switch(e){
      case penDownEvent:
      case penMoveEvent:
         playMusicGame(x,y);
         break;

      case penUpEvent:
         stopMusicGame(x,y);
         break;

      }
      break;
   }

}

//static long last_address = 0;
//static int first_time = 1;
//long last_address = 0;
//int first_time = 1;

static Boolean MainFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    FieldPtr fld;
    char *s;
    static long last_address = 0;
    static int first_time = 1;
    static eventsEnum lastEType;
    static char lastkey = 'A';
    static int lasttone = 0;

    frm = FrmGetActiveForm();
    fld = NULL;

    switch (e->eType) {
        case frmOpenEvent:
            DEBUGBOX("frmOpenEvent","");
            FrmDrawForm(frm);
            dialTonePrefs.state.game = dialToneGame;

            //DEBUGBOX("frmOpenEvent","b4 draw screen");
            drawdialToneScreen();
            //startdialToneGame();
            //DEBUGBOX("frmOpenEvent","afterstart");

            if (first_time) {
	        char *s; // THIS causes a CRASH!!!
	        void *foo;

                //DEBUGBOX("frmOpenEvent","firsttime");
                //first_time = 0;   // CRASH RIGHT HERE !?  ACCESSING STATIC VAR
                //DEBUGBOX("frmOpenEvent","firsttime");

                /* Set up things, and update control */
                // setup gone
                foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodList));
                //DEBUGBOX("frmOpenEvent","firsttime");
                LstSetSelection(foo, dialTonePrefs.state.sound);
                //DEBUGBOX("frmOpenEvent","firsttime");
                s = LstGetSelectionText(foo, dialTonePrefs.state.sound);
                //DEBUGBOX("frmOpenEvent","firsttime");
                if (NULL != s) {
		  //DEBUGBOX("frmOpenEvent","firsttime");
                    foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodTrigger));
		    //DEBUGBOX("frmOpenEvent","firsttime");
                    CtlSetLabel(foo, s);
                }

                /* Set detail, and update checkbox */
                // setup gone

                /* Set other configs */
                // gone

                /* Set address, and update field and listing. */
                DEBUGBOX("frmOpenEvent","firsttime b4curent_address = ");
                current_address = (long)dialTonePrefs.address;
                DEBUGBOX("frmOpenEvent","firsttime");
            }
	    DEBUGBOX("frmOpenEvent","after firsttime");
            handled = true;
            break;

        case frmUpdateEvent:
            switch(e->data.frmUpdate.updateCode) {
                case UPDATE_LISTING:
                    last_address = 0; //do_everything();
                    handled = true;
                    break;
            }
            break;

        case menuEvent:
            switch(e->data.menu.itemID) {
                case itemPlaydialTone:
                   dialTonePrefs.state.game = dialToneGame;
                   drawdialToneScreen();
                   //startdialToneGame();
                   break;
                case itemPlayMusic:
                   dialTonePrefs.state.game = musicGame;
                   drawMusicScreen();
                   break;
                case itemClearScreen:
                   clearScreen();
                   break;
                case itemEditUndo:
                    if (fld)
                        FldUndo(fld);
                    break;
                case itemEditCut:
                    if (fld)
                        FldCut(fld);
                    break;
                case itemEditCopy:
                    if (fld)
                        FldCopy(fld);
                    break;
                case itemEditPaste:
                    if (fld)
                        FldPaste(fld);
                    break;
                case itemEditSelectAll:
                    if (fld)
                        FldSetSelection(fld, 0, FldGetTextLength(fld));
                    break;
                case itemEditKbd:
                    SysKeyboardDialog(kbdDefault);
                    break;
                case itemEditGraf:
                    SysGraffitiReferenceDialog(referenceDefault);
                    break;
                case itemOptPrefs:
                    FrmPopupForm(PrefForm);
                    break;
                case itemOptHelp:
                    FrmHelp(hlpHelp);
                    break;
                case itemOptDbgDump:
                    debugDump(e->eType);
                    break;
                case itemOptCopying:
                    FrmHelp(hlpCopy);
                    break;
                case itemOptAbout:
                    FrmCustomAlert(alertInfo, "dialTone v" VERSION " Beta. "
                    "Built " __DATE__ ", " __TIME__ ". "
                    "programming James Coleman http://www.dspsrv.com/~jamesc "
                    "copyleft me, distribute with source code please.", "", "");
                    break;
            }

            MenuEraseStatus(NULL);
            handled = true;
            break;
        
        case popSelectEvent:
            if (MethodList == e->data.popSelect.listID) {
                dialTonePrefs.state.sound = e->data.popSelect.selection;
                last_address = 0;//dosomething
                /* Must be false, otherwise the popupfield won't change. */
                handled = false;
            }
            break;

        case penDownEvent:
        case penMoveEvent:
	   // should start sound on pen down, then fin on pen up .... duration TBD
           /* The next test is neccessary in order to filter out pen events from other forms. */
           //if (!(penDownEvent == lastEType || penMoveEvent == lastEType))
           //   break;
           if (e->screenY > 10) {
              doPenAction( dialTonePrefs.state.game, e->eType, e->screenX, e->screenY, 0, 0); 
           }
           break;


        case penUpEvent:
           if (e->data.penUp.start.y > 10) {
              doPenAction( dialTonePrefs.state.game,
                           penUpEvent, e->data.penUp.start.x, e->data.penUp.start.y, 
                           e->data.penUp.end.x, e->data.penUp.end.y);
           }
           break;

        case ctlSelectEvent:
            switch(e->data.ctlSelect.controlID) {
               //case chkFull:
               //     break;
            }
            break;

            //case ctlRepeatEvent:
            //break;

        case keyDownEvent:
            switch(e->data.keyDown.chr) {
                case pageUpChr:
                case pageDownChr:
                    if (pageUpChr == e->data.keyDown.chr)
                        current_address -= (unsigned long)last_address -
                            (unsigned long)current_address + 2;
                    else
                        current_address = last_address;
                    handled = true;
                    break;
                    /* events that may cause us to leave the field */
                case prevFieldChr:
                case nextFieldChr:
                case '\n':
                    /* Leave field, start disassembly */
                    s = FldGetTextPtr(fld);
                    if (NULL != s) {
                        current_address = (h2l(s)& 0xfffffffe); /* force even */
                    }
                    handled = true;
                    break;
                /* hexadecimal chars are ok */
                case '0' ... '9':
                case 'a' ... 'd':
                case 'A' ... 'D':
                case '*':
                case '#':

		    //DEBUGBOX("displayDTMFToneInfoDialog","");
		    //displayDTMFToneInfoDialog(e->data.keyDown.chr);

 		    // TODO: config duration
		    DEBUGBOX("DTMFTone","");
		    playDTMFTone(e->data.keyDown.chr,5000);
		    DEBUGBOX("DTMFTone","");
		    // this (assignment to static) could cause things to explode
		    //lastkey = e->data.keyDown.chr;
		    //DEBUGBOX("DTMFTone","");
                    handled = true;
                    break;

                case 'E' ... 'M':
                case 'e' ... 'm':

		    {
  		        int n=0;
			int lk;

			DEBUGBOX("TelTone","");

                        // setting lastkey causes problems :(
                        // not without -mown-gp ??
			lastkey = e->data.keyDown.chr;
			lk = e->data.keyDown.chr;
			if (lk>='E' && lk <='M') n = lk - 'E';
			if (lk>='e' && lk <='m') n = lk - 'e';

			DEBUGBOX("TelTone","");
			// TODO: config duration (from struct)
			playTelephoneTone(n, 5000);

			//DEBUGBOX("TelTone","");
			// this (assignment to static) could cause things to explode
			//lasttone = n;

			DEBUGBOX("TelTone","");

			//void playTwoFrequencies(int f1, int f2, int durationms)

		    }

                    handled = true;
                    break;

                case 's':
                case 'S':

		    DEBUGBOX("displayDTMFToneInfoDialog","");
		    displayDTMFToneInfoDialog(lastkey);
		    DEBUGBOX("displayDTMFToneInfoDialog","");
                    handled = true;
                    break;

                case 't':
                case 'T':

		    DEBUGBOX("displayTelToneInfoDialog","");
		    displayTelephoneToneInfoDialog(lasttone%9);
		    DEBUGBOX("displayTelToneInfoDialog","");
                    handled = true;
                    break;

                case 'v': // james special
                    displaySeekretDialog();
                    doSeekretAction(e->data.keyDown.chr);
                    handled = true;
                    break;

                /* anything non-control-char-ish is ignored. */

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

    // DO NOT PUT DEBUG BOX HERE DEBUGBOX("set lastEType","");
    lastEType = e->eType;

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
    UInt16 prefsize;
    int i;
    
    /* Fetch application preferences */
    DEBUGBOX("b4 fetch prefs","");
    prefsize = sizeof(dialTonePreferenceType); /* Added by Nick Spence */

    i = PrefGetAppPreferences(APPID, 0, &dialTonePrefs, &prefsize, true);

    /* If no prefs were found, reset all values. */
    if (noPreferenceFound == i) {
        DEBUGBOX("no prefs","");
        dialTonePrefs.address = NULL;
        dialTonePrefs.state.game = 1;
        dialTonePrefs.state.enable_edit = 0;
        dialTonePrefs.state.enable_stupid = 0;
        dialTonePrefs.state.debug = 1;

        dialTonePrefs.state.sound = 1;
	dialTonePrefs.amp=5;

        /* not used yet dialTonePrefs.freq = 0;
        dialTonePrefs.dur = 0;
	dialTonePrefs.x = 0;
	dialTonePrefs.y = 0; */

    }

    dbs_buf = MemPtrNew(100);
    ErrFatalDisplayIf(dbs_buf == NULL, "no mem");

#ifdef TRYINITGLOBDTMFSTUFF
    DEBUGBOX("init dial tone DTMF globals","");
    initDialToneDTMF();
    DEBUGBOX("after init dial tone DTMF globals","");
#endif

    FrmGotoForm(MainForm);

    return 0;
}

/* Save preferences, close forms, close app database */
static void StopApplication(void)
{
    PrefSetAppPreferences(APPID, 0, dialTonePrefVersionNum,
            &dialTonePrefs, sizeof(dialTonePreferenceType), true);
    DEBUGBOX("after prefs set","");

    if (dbs_buf)
        MemPtrFree(dbs_buf);
    dbs_buf = NULL;

    DEBUGBOX("after MemPtrFree","");

    FrmSaveAllForms();
    DEBUGBOX("after save forms","");
    FrmCloseAllForms();    
    DEBUGBOX("after close forms","");
}

/* The main event loop */
static void EventLoop(void)
{
    UInt16 err;
    EventType e;

    do {
        EvtGetEvent(&e, evtWaitForever);

	// not good to put this debug here 
        // educational ... but not good 
        // (hijacks all events including exit/end/stop/...)
        // dialToneDEBUG("james testing - got event\n", &e);

        if (! SysHandleEvent (&e))
            if (! MenuHandleEvent (NULL, &e, &err))
                if (! ApplicationHandleEvent (&e))
                    FrmDispatchEvent (&e);
    } while (e.eType != appStopEvent);
}

/* Main entry point; it is unlikely you will need to change this except to
   handle other launch command codes */
UInt32  PilotMain(UInt16 cmd, void *cmdPBP, UInt16 launchFlags)
// older sdk DUInt16 PilotMain(UInt16 cmd, Ptr cmdPBP, UInt16 launchFlags)
{
    UInt16 err;

    if (cmd == sysAppLaunchCmdNormalLaunch) {

        err = StartApplication();
        if (err) return err;

        EventLoop();
	//dialToneDEBUG("james testing - after EventLoop\n",NULL);
        StopApplication();

    } else {
        return sysErrParamErr;
    }

    return 0;
}
