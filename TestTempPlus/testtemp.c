/* Main code for Test Template */

#include <PalmOS.h>

#include "testtempRsc.h"

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

    	handled = true;
	break;

    case ctlSelectEvent:
	switch(e->data.ctlSelect.controlID) {
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
