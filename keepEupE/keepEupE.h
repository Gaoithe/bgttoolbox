#include <PalmOS.h>

#define VERSION "0.1"

/* update codes for mainform. */
#define UPDATE_LISTING  0xc001

typedef enum keepEupEGameType {
   keepEupEGame,
   musicGame,
   ifsFern,
   ifsTri
} keepEupEGameType;

struct prefstate_s {
    unsigned sound:             1;      /* DISP_KEEPEUPE or DISP_HEX */
    keepEupEGameType game:      3;      /* with hexcodes in keepEupE */
    unsigned enable_edit:       1;      /* allow memory edit or not */
    unsigned enable_stupid:     1;      /* allow user to do stupid things */
    unsigned debug:             1;      /* allow debug messages/resets */
};

typedef struct {
   void                *address;               /* Position on exit */
   int freq,dur,amp,x,y;
   struct prefstate_s    state;
} keepEupEPreferenceType;

extern keepEupEPreferenceType keepEupEPrefs;

extern RectangleType dis_area;

// keepEupE functions are categorised into different c files
// keepEupE.c - user interface (forms/event handling), preferences
// keepEupEDraw.c - graphics drawing
// keepEupEGame.c - run the keepEupE game 
// keepEupESound.c - play sounds/music

// keepEupEDraw
extern void clearScreen(void);
extern void WinDrawLineF(Coord x1, Coord y1, Coord x2, Coord y2);
extern void WinEraseLineF(Coord x1, Coord y1, Coord x2, Coord y2);
//void WinDrawLine (Coord x1, Coord y1, Coord x2, Coord y2) // and WinEraseLine
typedef void (*WinDrawLine_fn)(Coord x1, Coord y1, Coord x2, Coord y2);

extern unsigned long ulsqrt(unsigned long xx);
extern void drawCircle(int cx, int cy, int w, WinDrawLine_fn WinDrawLine); // centre x,y  width
extern void drawDiamond(int sx, int sy, int diw, WinDrawLine_fn WinDrawLine); // x,y,width
extern void drawTriangle(int sx, int sy, int triw, WinDrawLine_fn WinDrawLine); // x,y,width
extern void drawRectangle(int sx, int sy, int w, int h, WinDrawLine_fn WinDrawLine); // x,y,width,height
extern void drawRectangleSafe(int sx, int sy, int w, int h); // x,y,width,height

extern void drawFern(int n); // n = steps
extern void drawSierpenski(int n);


// keepEupEGame.c 
// TBD: split keepEupEgame to different c file
extern void checkKeepEupEGame(int shape); // called on every user beep
extern void startKeepEupEGame(void);
extern void drawKeepEupEScreen(void);
extern void flashShape(int shape, WinDrawLine_fn WinDrawLine);

// keepEupESound.c
extern void playFreq(SndCmdIDType cmd, int freq, int time);
extern void playMusicGame(int x, int y);
extern void stopMusicGame(int x, int y);
extern void drawMusicScreen(void);




#define DEBUGBOXD(ARGSTR1,ARGSTR2) {\
  char buf[1000];\
  int l=0;\
  l+=StrPrintF(buf+l, "debugbox - %s %s:%d\n", \
     __FUNCTION__, __FILE__, __LINE__);\
  FrmCustomAlert(alertInfo, buf, ARGSTR1, ARGSTR2);\
}


#define DEBUGBOX(ARGSTR1,ARGSTR2)


