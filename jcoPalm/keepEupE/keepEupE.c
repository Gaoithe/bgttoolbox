/* Main code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#define KEEPEUPE_DEBUG
#define KEEPEUPE_FUN

#include "keepEupERsc.h"
#include "keepEupE.h"

#include <PalmOS.h>

keepEupEPreferenceType keepEupEPrefs;

/* Version number of preference-structure. Change when changing
 * keepEupEPreferenceType. */
#define keepEupEPrefVersionNum 2

//static char *dbs_buf = NULL;
static long current_address;

static void doPenAction(keepEupEGameType g, int e, int x, int y, int endx, int endy);
extern void playMusicGame(int x, int y);
extern void stopMusicGame(int x, int y);
extern void drawMusicScreen(void);



#if 0
	    FrmCustomAlert(alertInfo, "james testing - " __func__ __file__ __line__ "\n", "", "");
	    FrmCustomAlert(alertInfo, "james testing - we don't get here\n", "", "");

#endif

void debugDump(char c)
{
  char buf[1000];
  int l=0;

  l+=StrPrintF(buf+l, "State sound/game/enableEdit/enableStupid/debug: %d/%d/%d/%d/%d\n",
               keepEupEPrefs.state.sound,
               keepEupEPrefs.state.game,
               keepEupEPrefs.state.enable_edit,
               keepEupEPrefs.state.enable_stupid,
               keepEupEPrefs.state.debug);

  l+=StrPrintF(buf+l, "Address: %ld %lx\n",
               keepEupEPrefs.address, keepEupEPrefs.address);

  l+=StrPrintF(buf+l, "Sound freq/dur/amp: %d %d %d\n",
               keepEupEPrefs.freq,
               keepEupEPrefs.dur,
               keepEupEPrefs.amp);
  
  l+=StrPrintF(buf+l, "Pos x,y: %d,%d\n",
               keepEupEPrefs.x,
               keepEupEPrefs.y);
  
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

            i = (keepEupEPrefs.state.sound);
            state = keepEupEPrefs.state;  /* read state */

            i = state.enable_edit;
            PrefFormSetValue(frm, chkMemEdit, i);

            i = state.enable_stupid;
            PrefFormSetValue(frm, chkAllowStupid, i);

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
                    keepEupEPrefs.state = state;  /* save state */
                    /* tell main form to update itself. */
                    FrmUpdateForm(MainForm, UPDATE_LISTING);
                    /* FALLTHROUGH */
                case btnCancel:
                    FrmReturnToForm(MainForm);
                    handled = true;
                    break;
                case btnSoundLow:
                    keepEupEPrefs.amp=2;
                    break;
                case btnSound1:
                    keepEupEPrefs.amp=5;
                    break;
                case btnSound2:
                    keepEupEPrefs.amp=10;
                    break;
                case btnSound3:
                    keepEupEPrefs.amp=30;
                    break;
                case btnSoundHigh:
                    keepEupEPrefs.amp=50;
                    break;
                case btnSysCallNum:
                    break;
                case btnSysCallName:
                    break;
                case chkMemEdit:
                    state.enable_edit = e->data.ctlSelect.on;
                    break;
                case chkAllowStupid:
                    state.enable_stupid = e->data.ctlSelect.on;
                    break;
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
#ifdef KEEPEUPE_FUN
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
#ifdef KEEPEUPE_FUN
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

static void doPenAction(keepEupEGameType g, int e, int x, int y, int endx, int endy)
{
   static int shape;

   keepEupEPrefs.x = x;
   keepEupEPrefs.y = y;

   switch(g){
   case keepEupEGame:
      switch(e){
      case penDownEvent:
         shape = (y/80)*2 + (x/80); // 0 1 2 3

         // check shape, check shape must flash and unflash shape
         checkKeepEupEGame(shape);
         break;

      case penUpEvent:

         // can get unhandled penUp just after starting

         // it should go quiet itself
         // in play keepEupE game we don't finish sound until next key down
         //    in case key down&up too fast

         // unflash here to keep more user interactivity feeling
         flashShape(shape,&WinDrawLineF);
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
   case ifsFern:
      break;
   case ifsTri:
      break;
   }

}

static Boolean MainFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    FieldPtr fld;
    char *s;
    static long last_address = 0;
    static int first_time = 1;
    static eventsEnum lastEType;

    frm = FrmGetActiveForm();
    fld = NULL;

    //DEBUGBOX("",""); dialog boxes cause infinate loops in event handlers
    switch (e->eType) {
        case frmOpenEvent:
            DEBUGBOX("frmOpenEvent","");
            FrmDrawForm(frm);
            keepEupEPrefs.state.game = keepEupEGame;

            DEBUGBOX("frmOpenEvent","b4drawKeepEupEScreen");
            // problem is here .... call to function outside this module (file)
            // I think linker thing
            // symbols left unresolved?

            // NO you dilly ! DEBUGBOX within that func works okay
            drawKeepEupEScreen();
            DEBUGBOX("frmOpenEvent","b4startKeepEupEGame");
            startKeepEupEGame();
            DEBUGBOX("frmOpenEvent","afterstart");

            if (first_time) {
                char *s;
                void *foo;

                first_time = 0;

                /* Set up things, and update control */
                // setup gone
                DEBUGBOX("frmOpenEvent","firsttime b4GEtObjPtr");
                foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodList));
                LstSetSelection(foo, keepEupEPrefs.state.sound);
                DEBUGBOX("frmOpenEvent","firsttime b4LStGetSel");
                s = LstGetSelectionText(foo, keepEupEPrefs.state.sound);
                DEBUGBOX("frmOpenEvent","firsttime after");
                if (NULL != s) {
                    DEBUGBOX("frmOpenEvent","firsttime b4GEtObjPtr");
                    foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodTrigger));
                    DEBUGBOX("frmOpenEvent","firsttime b4CtlSetLabel");
                    CtlSetLabel(foo, s);
                }

                /* Set detail, and update checkbox */
                // setup gone

                /* Set other configs */
                // gone

                DEBUGBOX("frmOpenEvent","firsttime b4curent_address = ");
                /* Set address, and update field and listing. */
                current_address = (long)keepEupEPrefs.address;
            }
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
                case itemPlayKeepEUpE:
                   keepEupEPrefs.state.game = keepEupEGame;
                   drawKeepEupEScreen();
                   startKeepEupEGame();
                   break;
                case itemPlayMusic:
                   keepEupEPrefs.state.game = musicGame;
                   drawMusicScreen();
                   break;
                case itemDrawIFSFern:
                   keepEupEPrefs.state.game = ifsFern;
                   drawFern(1250);
                   break;
                case itemDrawIFSTri:
                   keepEupEPrefs.state.game = ifsTri;
                   drawSierpenski(2500);
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
                    FrmCustomAlert(alertInfo, "keepEupE v" VERSION " Beta. "
                    "Built " __DATE__ ", " __TIME__ ". "
                    "James Coleman http://www.dspsrv.com/~jamesc "
                    "copyleft me, distribute with source code please.", "", "");
                    break;
            }

            MenuEraseStatus(NULL);
            handled = true;
            break;
        
        case popSelectEvent:
            if (MethodList == e->data.popSelect.listID) {
                keepEupEPrefs.state.sound = e->data.popSelect.selection;
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
              doPenAction( keepEupEPrefs.state.game, e->eType, e->screenX, e->screenY, 0, 0); 
           }
           break;


        case penUpEvent:
           if (e->data.penUp.start.y > 10) {
              doPenAction( keepEupEPrefs.state.game,
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
                case 'A' ... 'F':
                case 'a' ... 'f':
                    break;
                /* anything non-control-char-ish is ignored. */

                case 'g' ... 'v': // james special
                    displaySeekretDialog();
                    doSeekretAction(e->data.keyDown.chr);
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

    lastEType = e->eType;

    return handled;
}

static Boolean ApplicationHandleEvent(EventPtr e)
{
    FormPtr frm;
    UInt16    formId;
    Boolean handled = false;

    //DEBUGBOX("",""); dialog boxes cause infinate loops in event handlers

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
    
    DEBUGBOX("b4 fetch prefs","");
    /* Fetch application preferences */
    prefsize = sizeof(keepEupEPreferenceType); /* Added by Nick Spence */
    i = PrefGetAppPreferences('kEuE', 0, &keepEupEPrefs, &prefsize, true);


{
  char buf[1000];
  StrPrintF(buf, "i is %d, noPrefFound is %d\n",
               i, noPreferenceFound );
  DEBUGBOX("afterfps",buf);
  StrPrintF(buf, "prefsize is %d, prefptr is %lx\n",
               prefsize, keepEupEPrefs );
  DEBUGBOX("afterfps",buf);
}
    /* If no prefs were found, reset all values. */
    if (noPreferenceFound == i) {
        DEBUGBOX("no prefs","");
        keepEupEPrefs.address = NULL;
        keepEupEPrefs.state.game = 1;
        keepEupEPrefs.state.enable_edit = 0;
        keepEupEPrefs.state.enable_stupid = 0;
        keepEupEPrefs.state.debug = 1;

        keepEupEPrefs.state.sound = 1;
	keepEupEPrefs.amp=5;

        /* not used yet keepEupEPrefs.freq = 0;
        keepEupEPrefs.dur = 0;
	keepEupEPrefs.x = 0;
	keepEupEPrefs.y = 0; */

    }

    //dbs_buf = MemPtrNew(100);
    //ErrFatalDisplayIf(dbs_buf == NULL, "no mem");

    FrmGotoForm(MainForm);

    return 0;
}

/* Save preferences, close forms, close app database */
static void StopApplication(void)
{
    keepEupEPrefs.address = (void *)current_address;

    DEBUGBOX("","");
    PrefSetAppPreferences('kEuE', 0, keepEupEPrefVersionNum,
            &keepEupEPrefs, sizeof(keepEupEPreferenceType), true);

    DEBUGBOX("after prefs set","");

    //if (dbs_buf)
    //    MemPtrFree(dbs_buf);
    //dbs_buf = NULL;

    FrmSaveAllForms();
    DEBUGBOX("","");
    FrmCloseAllForms();    
    DEBUGBOX("","");
}

/* The main event loop */
static void EventLoop(void)
{
    UInt16 err;
    EventType e;

    //DEBUGBOX("","");

    do {
        EvtGetEvent(&e, evtWaitForever);
        if (! SysHandleEvent (&e))
            if (! MenuHandleEvent (NULL, &e, &err))
                if (! ApplicationHandleEvent (&e))
                    FrmDispatchEvent (&e);
    } while (e.eType != appStopEvent);
    //DEBUGBOX("","");


}

/* Main entry point; it is unlikely you will need to change this except to
   handle other launch command codes */
UInt32  PilotMain(UInt16 cmd, void *cmdPBP, UInt16 launchFlags)
// older sdk DUInt16 PilotMain(UInt16 cmd, Ptr cmdPBP, UInt16 launchFlags)
{
    UInt16 err;

    if (cmd == sysAppLaunchCmdNormalLaunch) {

      DEBUGBOX("test","");
      //FrmCustomAlert(alertInfo, "james testing - \n", __FUNCTION__ , __FILE__);//__LINE__);

        err = StartApplication();
        if (err) return err;

        EventLoop();
        StopApplication();

    } else {
        return sysErrParamErr;
    }

    return 0;
}
