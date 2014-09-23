QT += widgets

HEADERS       = qtrenderarea.h \
                qtwindow.h \
    atoi.h \
    pocketc.h \
    SudokuEng.h \
    SudokuHint.h \
    SudokuInit.h \
    SudokuLoad.h \
    SudokuSolve.h \
    SudokuMainPocketC.h
SOURCES       = qtmain.cpp \
                qtrenderarea.cpp \
                qtwindow.cpp \
    SudokuMainPocketC.cpp
unix:!mac:!vxworks:!integrity:LIBS += -lm

# install
target.path = sudokuikku
INSTALLS += target