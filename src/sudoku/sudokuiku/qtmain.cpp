
//#include "qtwindow.h"
#include "SudokuQtWindow.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    //Window window;
    SudokuQtWindow window;
    window.show();
    return app.exec();
}
