/* dialTone drawing code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#include "dialToneRsc.h"
#include "dialTone.h"

static RectangleType dis_area = { {0, 10+2}, {160, 160} }; //x,y x,y

void clearScreen(void)
{
   WinEraseRectangle(&dis_area, 0);
}

unsigned long ulsqrt(unsigned long xx)
{
   unsigned long tx,txtx; //dc -e "16 o 16 i FFFFFFFF p v p d * p 10000 d * p"
   for(tx=0;tx<=0xffff;tx++) // 0xffff * 0xffff = 0xfffe0001 0x10000*0x10000 = 0x100000000
   {
      txtx = tx * tx;
      if (txtx == xx) return tx;
      if (txtx > xx) return tx-1;
   }
   return tx-1; // overflow, no match
   
}

#define NX 160
#define NY 160

#define min(a,b) (a<b)?a:b;

/*(ahhh .. not implemented)*/
void WinDrawArc(void)
SYS_TRAP(sysTrapWinDrawArc);

