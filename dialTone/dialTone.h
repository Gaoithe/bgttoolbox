#include <PalmOS.h>

#define VERSION "0.1"

/* update codes for mainform. */
#define UPDATE_LISTING  0xc001

typedef enum dialToneGameType {
   dialToneGame,
   musicGame,
   ifsFern,
   ifsTri
} dialToneGameType;

struct prefstate_s {
    unsigned sound:             1;      /* DISP_dialTone or DISP_HEX */
    dialToneGameType game:      3;      /* with hexcodes in dialTone */
    unsigned enable_edit:       1;      /* allow memory edit or not */
    unsigned enable_stupid:     1;      /* allow user to do stupid things */
    unsigned debug:             1;      /* allow debug messages/resets */
};

typedef struct {
   void                *address;               /* Position on exit */
   int freq,dur,amp,x,y;
   struct prefstate_s    state;
} dialTonePreferenceType;

extern dialTonePreferenceType dialTonePrefs;

extern RectangleType dis_area;

// dialTone functions are categorised into different c files
// dialTone.c - user interface (forms/event handling), preferences
// dialToneDraw.c - graphics drawing
// dialToneGame.c - run the dialTone game 
// dialToneSound.c - play sounds/music

// dialToneDraw
extern void clearScreen(void);
extern void WinDrawLineF(Coord x1, Coord y1, Coord x2, Coord y2);
extern void WinEraseLineF(Coord x1, Coord y1, Coord x2, Coord y2);

extern unsigned long ulsqrt(unsigned long xx);

extern void drawFern(int n); // n = steps
extern void drawSierpenski(int n);


// dialToneGame.c 
// TBD: split dialTonegame to different c file
extern void checkdialToneGame(int shape); // called on every user beep
extern void startdialToneGame(void);
extern void drawdialToneScreen(void);

// dialToneSound.c
extern void playFreq(SndCmdIDType cmd, int freq, int time);
extern void playMusicGame(int x, int y);
extern void stopMusicGame(int x, int y);
extern void drawMusicScreen(void);

// dialToneDTMF.c
int hashToneToArrayOffset(char whichTone);
void playTwoFrequencies(int f1, int f2, int durationms);
void playDTMFTone(char whichTone, int durationms);
void playTelephoneTone(int whichTone, int durationms);
void pausems(int time);
void shutup(void);

void displayDTMFToneInfoDialog(char whichTone);
void displayTelephoneToneInfoDialog(int n);



// debug on or off

#define DEBUGBOXOFF(ARGSTR1,ARGSTR2)

#define DEBUGBOX(ARGSTR1,ARGSTR2) {\
  char buf[1000];\
  int l=0;\
  l+=StrPrintF(buf+l, "debugbox - %s %s:%d\n", \
     __FUNCTION__, __FILE__, __LINE__);\
  FrmCustomAlert(alertInfo, buf, ARGSTR1, ARGSTR2);\
}


