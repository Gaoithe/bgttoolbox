
#ifndef POCKETC_H
#define POCKETC_H

#include <string>
using namespace std;
#include <string.h>
#include <stdio.h>
#include <unistd.h> // sleep

#include "SudokuQtWindow.h"

class SudokuQtWindow *W=NULL;
void pocketcRegisterWindow(SudokuQtWindow *w)
{
    W = w;
}

int alert(string s, int cancel=0, int next=1)
{
    if (!cancel) {
        printf("alert: %s",s.c_str());
        return W->alertMessage(s,next);
    }
    return cancel;
}

void mmclose(void){
  printf("mmclose\n");
}

int mmfind(string file) {
  printf("mmfind\n");
}

int mmnew(void)
{
  printf("mmnew\n");
}

void mmputs(string s)
{
  printf("mmputs: %s",s.c_str());
}

void mmputc(char c)
{
  char s[20];
  sprintf(s,"%c",c);
  mmputs(s);
}

void text(int x, int y, string s)
{
  printf("%s",s.c_str());
}

void ntext(int x, int y, int n)
{
  char num[20];
  sprintf(num,"%d",n);
  text(x,y,num);
}

void textattr(int font, int f1, int f2)
{
  printf("textattr\n");
}

void tone(int t1, int t2)
{
  printf("tone\n");
}

int event(int e)
{
  printf("event\n");
  sleep(1);
}


void frame(int a, int x1, int y1, int x2, int y2, int f)
{
  printf("frame\n");
}

void graph_on(void)
{
  printf("graph\n");
}

int key(void)
{
  printf("key\n");
}

void line(int x1, int y1, int x2, int y2, int j)
{
  printf("line\n");
}

int penx(void)
{
  printf("penx\n");
}

int peny(void)
{
  printf("peny\n");
}

void rect(int a, int x1, int y1, int x2, int y2, int f)
{
  printf("rect\n");
}

void title(string s)
{
  printf("title: %s\n",s.c_str());
}

/*

event
frame
graph_on
key
line
mmclose
mmfind
mmnew
mmputs
penx
peny
rect
substr
text
textattr
title
tone


FONC=$(gcc SudokuMainPocketC.cpp 2>&1  |grep "was not declare" |sed "s/.*error://;s/.*-F¡//;s/¢.*!!!!!!//" |sort |uniq)-A

jamesc@james-laptop:~/src/bgttoolbox/src/sudoku/sudokuiku$ for f in $FONC; do grep "$f *(" *.cpp |head -n 1; done
SudokuMainPocketC.cpp:   } while (event(1)==4);
SudokuMainPocketC.cpp:  frame(1,18,18,130,130,0); 
SudokuMainPocketC.cpp:   graph_on();
SudokuMainPocketC.cpp:      if (e==1) { c=key();
SudokuMainPocketC.cpp:    line(1, 20+i*12, 20, 20+i*12, 128);
SudokuMainPocketC.cpp:   x = penx();   y = peny();
SudokuMainPocketC.cpp:   x = penx();   y = peny();
SudokuMainPocketC.cpp:  rect(0,18,18,130,130,0); 
SudokuMainPocketC.cpp:  text(1,140,"sudoku");
SudokuMainPocketC.cpp:   title("Sudoku");

*/

#endif
