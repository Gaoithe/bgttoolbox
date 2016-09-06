#ifndef SUDOKUMAINPOCKETC_H
#define SUDOKUMAINPOCKETC_H

extern char *it;

int sudokumain(int argc, char *argv[]);

// SudokuEng
void updOne(int un, int ki, int maskin, int maskout);
void updMaybeNope(int i, int j, int v, int un);
void setBox(int i, int j, char v);

// SudokuHint
void sudokuHint(void);

#include <string>
using namespace std;
//#include <string.h>
//#include <stdio.h>
//#include <unistd.h> // sleep

// SudokuInit
void init(void);
void dumpgrp(void);
void initgrps(void);
void updGrp(int un, int ki, int maskin, int maskout);
void ctext(int x, int y, string s, string c);
void nctext(int x, int y, char c, string s);

// SudokuLoad
void writeit(string file);
void loadit(string it);
void load();
void load1();
void load2();
void load3();
void load4();

// SudokuSolve
void solveW();
void solveX();
void solveY();

#endif // SUDOKUMAINPOCKETC_H
