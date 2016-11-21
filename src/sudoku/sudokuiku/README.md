Sudoku linux/android/... Qt App
================================================================================

Sudoku solver.

This was a PalmOS PocketC app. Hence the terribly weird arrangement of files/functions.
PalmOS Memo docs had a smallish size limit.
PocketC could handle one C file (but you could include as many files as you wanted).
So you had one PocketC main c file which included all other files.
Hence all the functions and code which would normally be in .c files in the .h files.

PocketC engine

 * SudokuEng.h
 void updOne(int un, int ki, int maskin, int maskout)
 void updMaybeNope(int i, int j, int v, int un)
 void setBox(int i, int j, char v)
 Global arrays in SudokuMain:
  char sudoku[81];
  int maybe[81];
  int nope[81];

 * SudokuHint.h
 Hints and help and lots of TODOs void sudokuHint(void)

 * SudokuInit.h
  void init(void)
  Could be in SudokuEng:dumpgrp() initgrps()
    updGrp(int un, int ki, int maskin, int maskout)
  Could be in pocketc.h
    ctext(int x, int y, string s, string c)
    nctext(int x, int y, char c, string s)
  Global arrays in SudokuMain:
   int grpfin[27];
   int grp[243]; //[3][9][9]; //idx of grp member

 * SudokuLoad.h
  loadit() writeit() load1() load2() . . .
  load1 load2 load hardcoded sudokus for testing

 * SudokuSolve.h Solving Engine. Different algorithms.
   solveW() solveX() solveY()
   int bits(int mask)
   validateSudoku()

 * SudokuMainPocketC.cpp main #included all the other .h files and rain main loop
    main loop: user input key(palmOS script and touchscreen events)
    sudokumain is now redundant in Qt app

 * pocketc.h itoa.h atoi.h itoa.cpp : pocketC API layer

Qt window, renderArea widget interface

 * SudokuQtWindow arranges all the widgets and hooks up actions
   QList<RenderArea*> renderAreas containing all the widgets
   Labels and controls are contained in this widnow class AND
   QGridLayouts containing sudoku square, game controls, settings controls

 * qtrenderarea RenderArea class widget is a base class for Number and other widgets

 * qtwindow.c/h . . . I think qtwindow is redundant, SudokuQtWindow now does the job

 * qtlightwidget LightWidget class :- traffic lights

