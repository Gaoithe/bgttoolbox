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

struct fontstate_s {
    unsigned h,w,th,tw;
};

typedef struct {
    UInt32 timestamp;
    UInt32 tik_timestamp;
    int vol;
    int sound;
    int visual;
    int disableAutoOff;
    int showTicks;
    struct fontstate_s fontstate;
} stopWatchPreferenceType;
#define stopWatchPrefVersionNum 4
// any change of struct requires change of version

static Boolean ApplicationHandleEvent(EventPtr e);
