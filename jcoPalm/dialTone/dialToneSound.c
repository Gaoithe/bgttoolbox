/* dialTone sound code 
 * by James Coleman <jamesc@dspsrv.com>
 */

//#include "dialToneRsc.h"

#include "dialTone.h"

void playFreq(SndCmdIDType cmd, int freq, int time)
{
   SndCommandType soundCmd;
  
   if (dialTonePrefs.state.sound != 0){
      //soundCmd.cmd=sndCmdFreqDurationAmp; // blocking
      // non-blocking!  better to use this and key press start sound, key up ends it.
      soundCmd.cmd=cmd; // sndCmdFrqOn; 

      dialTonePrefs.freq = soundCmd.param1 = freq; /*freq in hz */
      dialTonePrefs.dur = soundCmd.param2 = time; /*max dur in ms */
      soundCmd.param3 = dialTonePrefs.amp; /*amp 0 - sndMaxAmp */

      SndDoCmd(NULL, &soundCmd, 0/*nowait*/);
   } else {
      // if sound off delay useful for playback
      if (cmd == sndCmdFreqDurationAmp) // force delay
         SysTaskDelay((time * SysTicksPerSecond())/1000);
   }
}

static void drawMusicShape(int x, int y)
{
  //   drawDiamond(x-3,y-3,6, &WinDrawLineF);
}

static void drawMusicShapeS(int x, int y, int time)
{
   int ty;
   for(ty=y+3;ty<y+time;ty++)
      drawMusicShape(x,ty);
}

static void playNoteAsIfUser(int x, int y, int t)
{
   playMusicGame(x, y);
   SysTaskDelay((t * SysTicksPerSecond())/1000);
   stopMusicGame(x, y);
}

void drawMusicScreen(void)
{
   clearScreen();
   // draw something nice, draw freq lines/piano
   // play nice chime

   // middle C 262 277 294 311 330 349 370 392 415 440 466 494 524
   //          C   C#  D   D#  E   F   F#  G   G#  A   A#  B   C
   playNoteAsIfUser(262/10, 50, 300); 
   playNoteAsIfUser(330/10, 50, 300); 
   playNoteAsIfUser(262/10, 50, 300); 
   playNoteAsIfUser(131/10, 50, 300); 
   playNoteAsIfUser(131/2 + 131/10, 50, 900); 
// close encounters C E C C G(5th = half freq harmony)
// i.e. big C = middle C + middle C
//      middle C + (middleC/2) = G
}

void playMusicGame(int x, int y)
{
   // TBD: (stop)/start timer
   // play sound and draw note shape
   drawMusicShape(x,y);
   // Middle C is 262Hz
   playFreq(sndCmdFrqOn,x*10,2000); // freq,maxdur
}

void stopMusicGame(int x, int y)
{
   SndCommandType soundCmd;   // TBD: pass quiet to playFreq
   // TBD: end timer
   drawMusicShapeS(x,y,0); // TBD: calc down time
   soundCmd.cmd=sndCmdQuiet;
   SndDoCmd(NULL, &soundCmd, 0/*nowait*/);
}

