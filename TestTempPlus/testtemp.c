/* Main code for Test Template */

#include <PalmOS.h>

#include "testtempRsc.h"

/*
#define alertInfo               2601

void DEBUGBOX(char *ARGSTR1, char *ARGSTR2) {
  char buf[1000];
  int l=0;
  l+=StrPrintF(buf+l, "debugbox - %s %s:%d\n", 
     __FUNCTION__, __FILE__, __LINE__);
  FrmCustomAlert(alertInfo, buf, ARGSTR1, ARGSTR2);
}

static void doPenAction(int e, int x, int y, int endx, int endy)
{
   char buf[1000];
   int l=0;

   l+=StrPrintF(buf+l, "event: %d x,y %d,%d end x,y %d,%d\n",
		e, x, y, endx, endy);
   buf[l]=0;

   DEBUGBOX("doPenAction",buf);

   switch(e){
   case penDownEvent:
     break;

   case penUpEvent:
     break;
         
   }
}
*/

static Boolean MainFormHandleEvent (EventPtr e)
{
    Boolean handled = false;
    FormPtr frm;
    
    switch (e->eType) {
    case frmOpenEvent:
	frm = FrmGetActiveForm();
	FrmDrawForm(frm);
	handled = true;
	break;

    case menuEvent:
	MenuEraseStatus(NULL);

	switch(e->data.menu.itemID) {
	}

	//DEBUGBOX("menuEvent","");

    	handled = true;
	break;

    case ctlSelectEvent:
	switch(e->data.ctlSelect.controlID) {
	}
	break;

    //case ctlRepeatEvent:
    //break;

    case penDownEvent:
    case penMoveEvent:
      //doPenAction( e->eType, e->screenX, e->screenY, 0, 0); 
      break;

    case penUpEvent:
      //doPenAction( penUpEvent, 
      //	   e->data.penUp.start.x, e->data.penUp.start.y, 
      //	   e->data.penUp.end.x, e->data.penUp.end.y);
      break;

    case keyDownEvent:

      /*{
      char buf[1000];
      int l=0;
      l+=StrPrintF(buf+l, "Char: %c\n",e->data.keyDown.chr);
      buf[l]=0;
      DEBUGBOX("keyDownEvent",buf);
      }*/

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
