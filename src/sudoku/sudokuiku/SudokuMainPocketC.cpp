// Sudoku
// for PalmIII & PocketC - James.

#include "pocketc.h"

#include <string>
using namespace std;
#include <string.h>

#include "atoi.h"
int x,y,i,j,idx,v; //used so often, not static
int oldi,oldj; //static
// maxx is 160, maxy is 160
char sudoku[81];
int maybe[81];
int nope[81];

int getEngine(int i, int j){
    return (int)sudoku[j*9+i];
}

void dumpEngine(){
    char line[20];
    printf("SUDOKU:\n");
    //for(i=0;i<9;i++) {
    //    snprintf(line,9,sudoku+i*9);
    //    printf(" : %s : \n",line);
    //}
    for(i=0;i<9;i++) {
        printf(" : ");
        for(j=0;j<9;j++) {
            printf("%x ",sudoku[i+j*9]);
        }
        printf(": \n");
    }
    printf("MAYBE:\n");
    for(i=0;i<9;i++) {
        printf(" : ");
        for(j=0;j<9;j++) {
            printf("%03x ",maybe[j*9+i]);
        }
        printf(": \n");
    }
    printf("NOPE:\n");
    for(i=0;i<9;i++) {
        printf(" : ");
        for(j=0;j<9;j++) {
            printf("%03x ",nope[j*9+i]);
        }
        printf(": \n");
    }
}


// maybe|nope[(i+j*9)] & (2<<num)
int valid(int i, int j){
  return (i>=0 && i<=8 &&
 j>=0 && j<=8 );
}

int font;
int grpfin[27];
int grp[243]; //[3][9][9]; //idx of grp member
#include "SudokuInit.h"
#include "SudokuEng.h"
#include "SudokuHint.h"

void drawSudokuBackground() {
  string s; char v;
  //draw markings, grid
  text(1,140,"sudoku");
  rect(0,18,18,130,130,0); 
  frame(1,18,18,130,130,0); 
  for(i=0;i<10;i++) {
    line(1, 20+i*12, 20, 20+i*12, 128);
    line(1, 20, 20+i*12, 128, 20+i*12);
  }
  for(i=3;i<7;i=i+3) {
    line(1, 21+i*12, 20, 21+i*12, 128);
    line(1, 20, 21+i*12, 128, 21+i*12);
  }
  for(i=0;i<9;i++) {
  for(j=0;j<9;j++) {
    v=sudoku[i+j*9];
    //puts(i+","+j+"/"+v);
    if(v) {
     setBox(i,j,v);
    }
  }}
  // menu
  text(131, 56, "clear");
  text(131, 68, "hint");
  text(131, 80, "solveWXYZ");
  text(131, 92, "valid");
  text(131, 104, "load");
  text(131, 116, "write");
  // TODO save
}

void setStatus(string st){
  text(131, 128, st);
} 
void setInfo(string st){
  text(131, 142, st);
}

void setFocusOnBox(int c, int i, int j) {
  if(valid(i,j)) line(c, 22+i*12, 30+j*12, 30+i*12, 30+j*12);
}

void setFocus(int ii, int jj) {
  if (valid(ii,jj)){
      setFocusOnBox(0,oldi,oldj);
      oldi = i = ii;
      oldj = j = jj; idx=i+j*9;
      setFocusOnBox(1,i,j);
      ntext(100,140,i);
      ntext(110,140,j);
      nctext(131, 20, '0'+sudoku[idx], "0");
      //ctext(131, 32, hexmask(maybe[idx],16,3), "00000");
      //ctext(131, 44, hexmask(nope[idx],16,3), "00000");
   }
}

void setFocusxy() {
   int e; int ii,jj;
   // Get initial position
   x = penx();   y = peny();
   // Draw lines until we stop receiving penMoves
   do {  ii = (x-20)/12;
      jj = (y-20)/12;
      setFocus(ii,jj);
      x=penx(); y=peny();
      //frame(1,x-2,y-2,x+2,y+2,0); 
      ntext(50,140,x);
      ntext(75,140,y); 
   } while (event(1)==4);
}

#include "SudokuSolve.h"
#include "SudokuLoad.h"

int sudokumain(int argc, char *argv[]) {
   int e;   char c;
   init(); initgrps(); 
   helpstatus=0; font=0;
   graph_on();
   title("Sudoku");
   drawSudokuBackground();
   // scribble on the plot
   while (1) {
      e = event(1);
      if (e==2) setFocusxy();
      if (e==1) { c=key();
        if (c>='0' && c<='9') 
          setBox(i,j,c-'0');
        setStatus("busy");
        if (c=='c') {
          init();
          drawSudokuBackground();
        }
        if (c=='h') sudokuHint();
        if (c=='W') solveW();
        if (c=='X') solveX();
        if (c=='Y') solveY();
        //if (c=='Z') solveZ();
        if (c=='v') ;//validate();
        if (c=='l') load();
        if (c=='m') load1();
        if (c=='n') load2();
        if (c=='o') load3();
        if (c=='p') load4();
        if (c=='w') writeit("sudokutest");
//|| c==3 happens pgup/dn release
//|| c==0x2d happens pgup/dn press
        if (c==0x1c || c=='<' || c=='{') setFocus(i-1,j);   
        if (c==0x1d || c=='>' || c=='_') setFocus(i+1,j);
        if (e==5 || c==0xc || c=='|') setFocus(i,j-1);
        if (e==6  || c==':' || c=='i') setFocus(i,j+1);
        setStatus("ready");
        setInfo(":"+solveCtr);
      }
      if (e==5) setFocus(i,j-1);
      if (e==6) setFocus(i,j+1);
   }
}
