/* dialTone game code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#include "dialToneRsc.h"
#include "dialTone.h"

// TBD: shapes in enum
#define MAXdialToneSHAPES 4

#define MAXdialToneS 100
static int dialToneShapeList[MAXdialToneS];
static int dialToneShapeListLast;
static int dialToneShapeListUserIndex;

static int dialToneNotes[] = { 262, 330, 392, 524 }; // chromatic, root, 3rd, 5th and hi root 
// chromatic scale
// middle C 262 277 294 311 330 349 370 392 415 440 466 494 524
//          C   C#  D   D#  E   F   F#  G   G#  A   A#  B   C

static void playLoseTone()
{
int i;

for(i=256;i>0;i--) // i++ produces great rocket noise!
   playFreq(sndCmdFrqOn, i, 10 /*sec*/);
}


// will be called with next end as the last begin
// match == on begin only, otherwise get double markings
void drawdialToneScreen(void)
{
   clearScreen();
}

static void playdialToneGame(void)
{
      int s;
      // play sounds + flash shapes (with delay)
      for(s=0;s<dialToneShapeListLast;s++){
         playFreq(sndCmdFreqDurationAmp/*sndCmdFrqOn*/, // I don't think it does block?, ohhh .. obviously not if sound off!
            dialToneNotes[dialToneShapeList[s]],300); // TBD: make 300 decrease to go faster

         // pause to break each shape apart (in case same shape important)
         SysTaskDelay((200 * SysTicksPerSecond())/1000);

      }
}

void checkdialToneGame(int shape) // called on every user beep
{
   playFreq(sndCmdFrqOn,dialToneNotes[shape],500); // freq,maxdur

   playLoseTone();

   SysTaskDelay((200 * SysTicksPerSecond())/1000);
   // pause to break user play from playback
   SysTaskDelay((500 * SysTicksPerSecond())/1000);
   // TBD maybe beep indicating end of playback, start of another
}

void startdialToneGame(void)
{
   playdialToneGame();
}


