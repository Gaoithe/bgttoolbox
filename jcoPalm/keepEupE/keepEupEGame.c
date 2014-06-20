/* keepEupE game code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#include "keepEupERsc.h"
#include "keepEupE.h"

// TBD: shapes in enum
#define MAXKEEPEUPESHAPES 4

#define MAXKEEPEUPES 100
static int keepEupEShapeList[MAXKEEPEUPES];
static int keepEupEShapeListLast;
static int keepEupEShapeListUserIndex;

static int keepEupENotes[] = { 262, 330, 392, 524 }; // chromatic, root, 3rd, 5th and hi root 
// chromatic scale
// middle C 262 277 294 311 330 349 370 392 415 440 466 494 524
//          C   C#  D   D#  E   F   F#  G   G#  A   A#  B   C

static void displayWinDialog(void)
{
  FrmCustomAlert(alertInfo, 
                   "You win!\n"
                   "Congratulations!\n",
                   "", "");
}

static void displayLoseDialog(int usershape)
{
  char buf[1000];
  int l=0; int i;

  l+=StrPrintF(buf+l, "Shape number: %d\n", keepEupEShapeListLast);
  
  l+=StrPrintF(buf+l, "Shapes: ");
  for(i=0;i<keepEupEShapeListLast;i++)
     l+=StrPrintF(buf+l, "%d,", keepEupEShapeList[i]);
  l+=StrPrintF(buf+l, "\n");
  
  buf[l]=0;

  FrmCustomAlert(alertInfo, 
                   "You lose!\n"
                   "Bummer!\n",
                   buf, "");
}

static void playLoseTone()
{
int i;

for(i=256;i>0;i--) // i++ produces great rocket noise!
   playFreq(sndCmdFrqOn, i, 10 /*sec*/);
}


// will be called with next end as the last begin
// match == on begin only, otherwise get double markings
void drawKeepEupEScreen(void)
{
   DEBUGBOX("drawKeepEupEScreen","");
   clearScreen();
   drawRectangleSafe(14,24,50,50);
   DEBUGBOX("drawKeepEupEScreen","b4rect");
   // messes up &WinDrawLineF ptr setup somewhere here
   drawRectangle(14,24,50,50,&WinDrawLineF);

   DEBUGBOX("drawKeepEupEScreen","");
   drawTriangle(90,34,70,&WinDrawLineF);
   DEBUGBOX("drawKeepEupEScreen","");
   drawDiamond(14,90,60,&WinDrawLineF);
   DEBUGBOX("drawKeepEupEScreen","");
   drawCircle(90+27,90+27,27+27,&WinDrawLineF);
   DEBUGBOX("drawKeepEupEScreen","");
}

void drawKeepEupEScreenTest(void)
{
   drawRectangle(14,24,50,50,&WinDrawLineF);
}

void flashShape(int shape, WinDrawLine_fn WinDrawLine)
{
   switch(shape){
   case 0:
      drawRectangle(14+5,24+5,50-10,50-10,WinDrawLine);
      break;
   case 1:
      drawTriangle(90+5+5,34+5,70-10-10,WinDrawLine);
      break;
   case 2:
      drawDiamond(14+5,90+5,60-10, WinDrawLine);
      break;
   case 3:
      drawCircle(90+27,90+27,27+27-10,WinDrawLine);
      break;
   }
}




static void playKeepEupEGame(void)
{
   // add new shape
   keepEupEShapeList[keepEupEShapeListLast] = SysRandom(0) % MAXKEEPEUPESHAPES;
   keepEupEShapeListLast++;

   // check for win
   if (keepEupEShapeListLast>=MAXKEEPEUPES){
      displayWinDialog();
      startKeepEupEGame();
   }
   else{
      int s;
      // play sounds + flash shapes (with delay)
      for(s=0;s<keepEupEShapeListLast;s++){
         flashShape(keepEupEShapeList[s],&WinEraseLineF);
         playFreq(sndCmdFreqDurationAmp/*sndCmdFrqOn*/, // I don't think it does block?, ohhh .. obviously not if sound off!
            keepEupENotes[keepEupEShapeList[s]],300); // TBD: make 300 decrease to go faster

         flashShape(keepEupEShapeList[s],&WinDrawLineF);
         // pause to break each shape apart (in case same shape important)
         SysTaskDelay((200 * SysTicksPerSecond())/1000);

      }
      // put user back to zero
      keepEupEShapeListUserIndex=0;
   }
}

void checkKeepEupEGame(int shape) // called on every user beep
{
   // flash shape
   flashShape(shape,&WinEraseLineF);
   playFreq(sndCmdFrqOn,keepEupENotes[shape],500); // freq,maxdur

   if (shape == keepEupEShapeList[keepEupEShapeListUserIndex])
      keepEupEShapeListUserIndex++;
   else {
      // TBD: play bad tone
      playLoseTone();
      displayLoseDialog(shape);
      // unflash shape
      flashShape(shape,&WinDrawLineF);
      startKeepEupEGame();
   }
   if (keepEupEShapeListUserIndex >= keepEupEShapeListLast){
      // unflash
      SysTaskDelay((200 * SysTicksPerSecond())/1000);
      flashShape(shape,&WinDrawLineF);
      // pause to break user play from playback
      SysTaskDelay((500 * SysTicksPerSecond())/1000);
      // TBD maybe beep indicating end of playback, start of another
      playKeepEupEGame();
      // add new shape etc...
   }
}

void startKeepEupEGame(void)
{
   keepEupEShapeListLast = 0;
   keepEupEShapeListUserIndex = 0;
   playKeepEupEGame();
}


