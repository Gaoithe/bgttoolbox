/* dialTone DTMF and tewlephone tone code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#include "dialToneRsc.h"
#include "dialTone.h"

// the way I compile global vars, static vars don't get init
// old compiler problem or me problem ?
// OR maybe it is because [][2] size unspecified?

int DTMFFrequencies[16][2] = { // 0 1 .. 9 A B C D * #
  //int DTMFFrequencies[][2] = { // 0 1 .. 9 A B C D * #
   { 941, 1336 },
   { 697, 1209 },
   { 697, 1336 },
   { 697, 1477 },
   { 770, 1209 },
   { 770, 1336 },
   { 770, 1477 },
   { 852, 1209 },
   { 852, 1366 },
   { 852, 1477 },
   { 697, 1633 },
   { 770, 1633 },
   { 852, 1633 },
   { 941, 1633 },
   { 941, 1209 },
   { 941, 1477 }
};


typedef struct
{
  char name[20];
  int tones[2];
  int mson; int msoff;
} TelephoneTone;

TelephoneTone toneArray[9] = {
  //TelephoneTone toneArray[] = {
  { "Dial Tone        ",  {  350, 440 },    500,  0 },
  { "Busy Signal      ",  {  480, 620 },    500,  500 },
  { "Toll Congestion  ",  {  480, 620 },    200,  300 },
  { "Ringback (Normal)",  {  440, 480 },    2000, 4000 },
  { "Ringback (PBX)   ",  {  440, 480 },    1500, 4500 },
  { "Reorder (Local)  ",  {  480, 620 },    3000, 2000 },
  { "Invalid Number   ",  {  200, 400 },    500,  0 },
  { "Hang Up Warning  ",  { 1400, 2060 },   100,  100 },
  { "Hang Up          ",  { 2450, 2600 },   500,  0 }
};

int hashToneToArrayOffset(char whichTone)
{
   if (whichTone>='0' && whichTone <='9') return (whichTone - '0');
   if (whichTone>='A' && whichTone <='D') return (whichTone + 10 - 'A');
   if (whichTone>='a' && whichTone <='d') return (whichTone + 10 - 'a');
   if (whichTone=='*') return 14;
   if (whichTone=='#') return 15;
   //return -1;
   return 0;
}

#define HTTAO(n) hashToneToArrayOffset(n)

void displayDTMFToneInfoDialog(char whichTone)
{
  char buf[1000];
  int l=0;
  int n = HTTAO(whichTone);

  l+=StrPrintF(buf+l, "playDTMFTone %c %d %dHz+%dHz.\n",
               whichTone, n, DTMFFrequencies[n][0], DTMFFrequencies[n][1]);  
  buf[l]=0;

  FrmCustomAlert(alertInfo, "DTMF Tone Info", "", buf);
}

void displayTelephoneToneInfoDialog(int n)
{
  char buf[1000];
  int l=0;

  l+=StrPrintF(buf+l, "playDTMFTone %i %s %dHz+%dHz %dms on, %dms off.\n",
          n,
          toneArray[n].name,
          toneArray[n].tones[0],
          toneArray[n].tones[1],
          toneArray[n].mson,
          toneArray[n].msoff);
  buf[l]=0;

  FrmCustomAlert(alertInfo, "Telephone Tone Info", "", buf);
}

void playDTMFTone(char whichTone, int durationms)
{
   int n;
   n = HTTAO(whichTone);
   //n = hashToneToArrayOffset(whichTone);
   if (n>=0){
      displayDTMFToneInfoDialog(whichTone);
      playTwoFrequencies(DTMFFrequencies[n][0], DTMFFrequencies[n][1], durationms);
   }
}

void playTelephoneTone(int n, int durationms)
{
   int t;
   displayTelephoneToneInfoDialog(n);
   for(t=0;t<durationms;t+=(toneArray[n].mson+toneArray[n].msoff)){
      playTwoFrequencies(toneArray[n].tones[0],
                         toneArray[n].tones[1],
                         toneArray[n].mson);
      pausems(toneArray[n].msoff);
   }
}

void playTwoFrequencies(int f1, int f2, int durationms)
{
   SndCommandType soundCmdf1, soundCmdf2;
   int t;
  
   if (dialTonePrefs.state.sound != 0){
      // non-blocking!  better to use this and key press start sound, key up ends it.
      //soundCmdf1.cmd = soundCmdf2.cmd = sndCmdFreqDurationAmp;; // blocking
      soundCmdf1.cmd = soundCmdf2.cmd = sndCmdFrqOn;
      soundCmdf1.param1 = f1; /*freq in hz */
      soundCmdf2.param1 = f2; /*freq in hz */
      soundCmdf1.param2 = soundCmdf2.param2 = 2; /*max dur in ms */
      soundCmdf1.param3 = soundCmdf2.param3 = dialTonePrefs.amp; /*amp 0 - sndMaxAmp */
      for(t=0;t<durationms;t+=32){   // TBD: allow this to break on event if blocking
         SndDoCmd(NULL, &soundCmdf1, 0/*nowait*/);
	 pausems(16); // 2-8 not enough for piezo
         SndDoCmd(NULL, &soundCmdf2, 0/*nowait*/);
	 pausems(16);
      }
   } else {
      // if sound off delay?
      //if (cmd == sndCmdFreqDurationAmp) // force delay
      pausems(durationms);
   }

   //soundCmd.cmd=sndCmdQuiet;
   //SndDoCmd(NULL, &soundCmd, 0/*nowait*/);

}

void pausems(int time)
{
   SysTaskDelay((time * SysTicksPerSecond())/1000);
}

void shutup(void)
{
   SndCommandType soundCmd;
   soundCmd.cmd=sndCmdQuiet;
   SndDoCmd(NULL, &soundCmd, 0/*nowait*/);
}

