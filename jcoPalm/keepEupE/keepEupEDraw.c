/* keepEupE drawing code 
 * by James Coleman <jamesc@dspsrv.com>
 */

#include "keepEupERsc.h"
#include "keepEupE.h"

static RectangleType dis_area = { {0, 10+2}, {160, 160} }; //x,y x,y

void clearScreen(void)
{
   WinEraseRectangle(&dis_area, 0);
}

void WinDrawLineF(Coord x1, Coord y1, Coord x2, Coord y2)
{
   WinDrawLine(x1,y1,x2,y2);
}

void WinEraseLineF(Coord x1, Coord y1, Coord x2, Coord y2)
{
   WinEraseLine(x1,y1,x2,y2);
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

void drawCircle(int cx, int cy, int w, WinDrawLine_fn WinDrawLine) // centre x,y  width
{
   int y,xx,x,py,pxl,pxr;
   int lpxl=cx,lpxr=cy;
   int r,rr;
   r = w/2;
   rr = w * w / 4; // r * r;
   for(y=r;y>=-r;y--)
   {
      xx = rr - (y * y) ;
      x = ulsqrt(xx);
      py = cy + y;
      pxl = cx - x;
      pxr = cx + x;
      WinDrawLine(pxl,py,pxr,py);
      //WinDrawLine(pxl,py,lpxl,py);  WinDrawLine(lpxr,py,pxr,py); // nice effect? not filled? 
      lpxl=pxl; lpxr = pxr;
   }
}

void drawDiamond(int sx, int sy, int diw, WinDrawLine_fn WinDrawLine) // x,y,width
{
   int y,xl,xr;
   for(y=sy,xl=xr=sx+(diw/2);xr-xl<diw;y++,xl--,xr++)
      WinDrawLine(xl,y,xr,y);
   for(;xr>xl;y++,xl++,xr--)
      WinDrawLine(xl,y,xr,y);
}

void drawTriangle(int sx, int sy, int triw, WinDrawLine_fn WinDrawLine) // x,y,width
// only one way ... like this xxxxxx
//                                     xxxx
//                                      xx
{
   int y,xl,xr;
   for(y=sy,xl=sx,xr=xl+triw;xr>xl;y++,xl++,xr--)
      WinDrawLine(xl,y,xr,y);
}

void drawRectangle(int sx, int sy, int w, int h, WinDrawLine_fn WinDrawLine) // x,y,width,height
{
   int y,x;
{
  char buf[1000];
  StrPrintF(buf, "WinDrawLine ptr is %lx\n",
               &WinDrawLine );
  DEBUGBOX("drawRect",buf);
}
   for(y=sy,x=sx;y<sy+h;y++)
      WinDrawLine(x,y,x+h,y);
   //RectangleType r; // = { {0, l, {160, 12} };
   //RctSetRectangle(&r, sx, sy, w, h); // x,y,width,height
   //WinDrawRectangleFrame(dialogFrame, &r); // sdk/include/Core/System/Window.h
}

void drawRectangleSafe(int sx, int sy, int w, int h) // x,y,width,height
{
   int y,x;
   DEBUGBOX("drawRect","");
   for(y=sy,x=sx;y<sy+h;y++)
      WinDrawLine(x,y,x+h,y);
   //RectangleType r; // = { {0, l, {160, 12} };
   //RctSetRectangle(&r, sx, sy, w, h); // x,y,width,height
   //WinDrawRectangleFrame(dialogFrame, &r); // sdk/include/Core/System/Window.h
}

#define NX 160
#define NY 160

#define min(a,b) (a<b)?a:b;

int getRandomK(void)
{
int r,k;

   r = SysRandom(0) % 100;
   if (r < 10)
      k = 0;           // 10% = .1
   else if (r < 18)
      k = 1;           // 8% = .08
   else if (r < 26)
      k = 2;           // 8% = .08
   else
      k = 3;           // 74% 

   return k;
}

void nextIFS(double *x, double *y)
{
   static double a[4] = {0.0,0.2,-0.15,0.75};
   static double b[4] = {0.0,-0.26,0.28,0.04};
   static double c[4] = {0.0,0.23,0.26,-0.04};
   static double d[4] = {0.16,0.22,0.24,0.85};
   static double e[4] = {0.0,0.0,0.0,0.0};
   static double f[4] = {0.0,1.6,0.44,1.6};

   static double xlast=0,ylast=0;
   int k;

   k = getRandomK();
   *x = a[k] * xlast + b[k] * ylast + e[k];
   *y = c[k] * xlast + d[k] * ylast + f[k];
   xlast = *x;
   ylast = *y;
}

void debugDumpFern(double scale, 
   double xmin, double xmax, double dx, double xmid,
   double ymin, double ymax, double dy, double ymid,
   double xminy, double xmaxy, double yminx, double ymaxx
   )
{
  char buf[1000];
  int l=0;

  l+=StrPrintF(buf+l, "IFS Fern Info\n");
  l+=StrPrintF(buf+l, "Scale: %g\n", scale );
  l+=StrPrintF(buf+l, "X min max dx mid: %ld %ld %ld %ld\n", xmin, xmax, dx, xmid );
  l+=StrPrintF(buf+l, "Y min max dy mid: %lx %lx %lx %lx\n", ymin, ymax, dy, ymid );

  l+=StrPrintF(buf+l, "x max.min points %f,%f %f,%f\n", xmax, xmaxy, xmin, xminy );
  l+=StrPrintF(buf+l, "y max.min points %f,%f %f,%f\n", ymax, ymaxx, ymin, yminx );
  
  buf[l]=0;

  FrmCustomAlert(alertInfo, buf, "", "");
}

void drawFern(int n) // n = steps
// ifs pretty and test floating point numbers
{
   int i;
   int ix,iy;
   double x,y,dx,dy,dxborder,dyborder;
   static double xmin=1e32,xmax=-1e32,ymin=1e32,ymax=-1e32,scale,xmid,ymid;
   double xmaxy=0, xminy=0, ymaxx=0, yminx=0; 

//void WinPaintPixel (Coord x, Coord y) Coord = Int16
//void WinDrawPixel (Coord x, Coord y)
// MIN -> min, rand() -> SysRandom(0) 
//Int16         SysRandom(Int32 newSeed)

   if (xmin == 1e32) {
      for (i=0;i<200;i++) {
         nextIFS(&x,&y);
 
         if (x < xmin) { xmin = x; xminy = y; }
         if (y < ymin) { ymin = y; yminx = x; }
         if (x > xmax) { xmax = x; xmaxy = y; }
         if (y > ymax) { ymax = y; ymaxx = x; }
      }

      dx = xmax - xmin; dxborder = dx*0.1; xmin-=dxborder; xmax+=dxborder;
      dy = ymax - ymin; dyborder = dy*0.2; ymin-=dyborder; ymax+=dyborder;

      scale = min( NX/dx, NY/dy );
      xmid = (xmin + xmax) / 2;
      ymid = (ymin + ymax) / 2;
   }

   for (i=0;i<n;i++) {
      nextIFS(&x,&y);

      ix = NX / 2 + (x - xmid) * scale;
      iy = NY / 2 + (ymid - y) * scale;
      WinDrawPixel(ix,iy);
   }

   debugDumpFern(scale, 
      xmin, xmax, dx, xmid,
      ymin, ymax, dy, ymid,
      xminy, xmaxy, yminx, ymaxx );

}

void drawSierpenski(int n)
{
   int x=0;
   int y=0;
   int tx[3],ty[3];
   int i,r;

   tx[1]=3;ty[1]=3; //init apex
   tx[2]=3;ty[2]=NY-3;
   tx[0]=NX-3;ty[0]=NY-3;

   x=tx[1]; y=ty[1];
   for(i=0;i<n;i++){
      WinDrawPixel(x,y);
      r=SysRandom(0) % 3;
      x=x+(tx[r]-x)/2;  // midpoint
      y=y+(ty[r]-y)/2;
   }
 }


/*(ahhh .. not implemented)*/
void WinDrawArc(void)
SYS_TRAP(sysTrapWinDrawArc);

