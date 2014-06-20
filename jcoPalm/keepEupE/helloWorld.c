/* Main code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#define KEEPEUPE_DEBUG
#define KEEPEUPE_FUN

#include "keepEupERsc.h"

#include "keepEupE.h"

keepEupEPreferenceType keepEupEPrefs;

#define keepEupEPrefVersionNum 1

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

    switch (e->eType) {
        case frmOpenEvent:
            FrmDrawForm(frm);
            if (first_time) {
                char *s;
                void *foo;

                first_time = 0;

                /* Set up things, and update control */
                // setup gone
                foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodList));
                LstSetSelection(foo, 0);
                s = LstGetSelectionText(foo, 0);
                if (NULL != s) {
                    foo = FrmGetObjectPtr(frm, FrmGetObjectIndex(frm, MethodTrigger));
                    CtlSetLabel(foo, s);
                }

                /* Set detail, and update checkbox */
                // setup gone

                /* Set other configs */
                // gone

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
                   break;
                case itemPlayMusic:
                   break;
                case itemDrawIFSFern:
                   break;
                case itemDrawIFSTri:
                   break;
                case itemClearScreen:
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
                    break;
                case itemOptHelp:
                    FrmHelp(hlpHelp);
                    break;
                case itemOptDbgDump:
                    break;
                case itemOptCopying:
                    FrmHelp(hlpCopy);
                    break;
                case itemOptAbout:
                    FrmCustomAlert(alertInfo, "keep v" VERSION " Beta. "
                    "Built " __DATE__ ", " __TIME__ ". "
                    "programming James Coleman jamesc@dspsrv.com. "
                    "\251 me, distribute with source code please.", "", "");
                    break;
            }

            MenuEraseStatus(NULL);
            handled = true;
            break;
        
        case popSelectEvent:
            if (MethodList == e->data.popSelect.listID) {
                /* Must be false, otherwise the popupfield won't change. */
                handled = false;
            }
            break;

        case penDownEvent:
        case penMoveEvent:
           if (e->screenY > 10) {
	     // later: doPenAction( keepEupEPrefs.state.game, e->eType, e->screenX, e->screenY, 0, 0); 
           }
           break;


        case penUpEvent:
           if (e->data.penUp.start.y > 10) {
	     // later doPenAction( keepEupEPrefs.state.game,
	     //                           penUpEvent, e->data.penUp.start.x, e->data.penUp.start.y, 
	     //            e->data.penUp.end.x, e->data.penUp.end.y);
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
                    handled = true;
                    break;
                    /* events that may cause us to leave the field */
                case prevFieldChr:
                case nextFieldChr:
                case '\n':
                    /* Leave field, start disassembly */
                    s = FldGetTextPtr(fld);
                    handled = true;
                    break;
                /* hexadecimal chars are ok */
                case '0' ... '9':
                case 'A' ... 'F':
                case 'a' ... 'f':
                    break;
                /* anything non-control-char-ish is ignored. */

                case 'g' ... 'v': // james special
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

    if (e->eType == frmLoadEvent) {
        formId = e->data.frmLoad.formID;
        frm = FrmInitForm(formId);
        FrmSetActiveForm(frm);

        switch(formId) {
            case MainForm:
                FrmSetEventHandler(frm, MainFormHandleEvent);
                break;
            case PrefForm:
	      //FrmSetEventHandler(frm, PrefFormHandleEvent);
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
    prefsize = sizeof(keepEupEPreferenceType); /* Added by Nick Spence */
    i = PrefGetAppPreferences('kEuE', 0, &keepEupEPrefs, &prefsize, true);

    /* If no prefs were found, reset all values. */
    if (noPreferenceFound == i) {
        keepEupEPrefs.address = NULL;
    }

    FrmGotoForm(MainForm);
    return 0;
}

/* Save preferences, close forms, close app database */
static void StopApplication(void)
{
    PrefSetAppPreferences('DiAs', 0, keepEupEPrefVersionNum,
            &keepEupEPrefs, sizeof(keepEupEPreferenceType), true);

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
UInt32  PilotMain(UInt16 cmd, void *cmdPBP, UInt16 launchFlags)
// older sdk DUInt16 PilotMain(UInt16 cmd, Ptr cmdPBP, UInt16 launchFlags)
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

