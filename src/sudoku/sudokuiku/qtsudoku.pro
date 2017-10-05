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
    SudokuMainPocketC.h \
    SudokuQtWindow.h \
    itoa.h \
    lightwidget.h
SOURCES       = qtmain.cpp \
                qtrenderarea.cpp \
                qtwindow.cpp \
    SudokuMainPocketC.cpp \
    SudokuQtWindow.cpp \
    itoa.cpp \
    lightwidget.cpp
unix:!mac:!vxworks:!integrity:LIBS += -lm

# install
target.path = sudokuikku
INSTALLS += target

NOT_USED = \
    spreadsheet.h \
    spreadsheet.cpp \

OTHER_FILES += \
    README.md
