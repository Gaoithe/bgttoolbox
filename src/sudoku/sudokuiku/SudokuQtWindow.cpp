#include "qtrenderarea.h"
#include "SudokuQtWindow.h"
#include "itoa.h"
#include "qtwindow.h"
#include <QtWidgets>
#include "SudokuMainPocketC.h"

// SudokuQtSudokuQtWindow.cpp // qtSudokuQtWindow.cpp provide SudokuQtWindow class/object

class QPushButtonPaint:QPushButton
{
public:
  QPushButtonPaint(QObject *parent = 0){}
  //QPushButtonPaint(QObject *parent = 0,QString s){}
  void paintEvent ( QPaintEvent * );
};

const float Pi = 3.14159f;

QPainterPath qpp_sudokuPath(char *number)
{
    /*
     * QPainterPath rectPath;
    rectPath.moveTo(20.0, 30.0);
    rectPath.lineTo(40.0, 30.0);
    rectPath.lineTo(40.0, 50.0);
    rectPath.lineTo(20.0, 50.0);
    rectPath.closeSubpath();
    return rectPath;
    */

    //QPainterPath textPath[9*9];
    QPainterPath textPath;
    QFont timesFont("Times", 50);
    timesFont.setStyleStrategy(QFont::ForceOutline);
    textPath.addText(10, 70, timesFont, Window::tr(number));
    return textPath;
}

SudokuQtWindow::SudokuQtWindow()
{
    init(); initgrps();

    QPainterPath sudokuPath = qpp_sudokuPath("0");

    QPainterPath rectPath = qpp_rectPath();

    QPainterPath roundRectPath = qpp_roundRectPath();

    QPainterPath starPath = qpp_starPath();

    /*************************************************/
    /* start count of widgets
     * and start pushing them into renderArea
     *
     * */
    int jNCount = 0;

    QPainterPath starsPath[20];
    for (int j=5;j<20;j++) {
        starsPath[j] = qpp_starsPath(j);
        renderAreas.push_back(new RenderArea(starsPath[j]));
        jNCount++;
    }

    // TODO: draw a cog object to act as settings button
    // TODO: maybe better using arcs simpler, . . .
    QPainterPath cogPath[2];
    cogPath[0] = qpp_cogPath();
    cogPath[1] = qpp_cogPath();

    renderAreas.push_back(new RenderArea(QPainterPath(),NULL,"RA"));
    jNCount++;
    renderAreas.push_back(new RenderArea(sudokuPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(rectPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(roundRectPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(starPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(cogPath[0]));
    jNCount++;
    renderAreas.push_back(new RenderArea(cogPath[1]));
    jNCount++;

    /*
    int jj;
    QPainterPath textPathNums[9*9];
    for (jj=jNCount;jj<9*9;jj++) {
        char s[20];
        sprintf(s,"%d",jj%9);
        textPathNums[jj].addText(10, 70, timesFont, tr(s));
        renderAreas.push_back(new RenderArea(textPathNums[jj]));
    }*/

    while(jNCount<81) {
        // add widget
        QPainterPath sudokuPathNUM = qpp_sudokuPath(itoa(jNCount%10));
        RenderArea* it = new RenderArea(sudokuPathNUM);
        renderAreas.push_back(new RenderArea(sudokuPathNUM));
        jNCount++;
    }

    fillRuleComboBox = new QComboBox;
    fillRuleComboBox->addItem(tr("Odd Even"), Qt::OddEvenFill);
    fillRuleComboBox->addItem(tr("Winding"), Qt::WindingFill);

    fillRuleLabel = new QLabel(tr("Fill &Rule:"));
    fillRuleLabel->setBuddy(fillRuleComboBox);

    fillColor1ComboBox = new QComboBox;
    populateWithColors(fillColor1ComboBox);
    fillColor1ComboBox->setCurrentIndex(fillColor1ComboBox->findText("mediumslateblue"));

    fillColor2ComboBox = new QComboBox;
    populateWithColors(fillColor2ComboBox);
    fillColor2ComboBox->setCurrentIndex(fillColor2ComboBox->findText("cornsilk"));

    fillGradientLabel = new QLabel(tr("&Fill Gradient:"));
    fillGradientLabel->setBuddy(fillColor1ComboBox);

    fillToLabel = new QLabel(tr("to"));
    fillToLabel->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);

    penWidthSpinBox = new QSpinBox;
    penWidthSpinBox->setRange(0, 20);

    penWidthLabel = new QLabel(tr("&Pen Width:"));
    penWidthLabel->setBuddy(penWidthSpinBox);

    penColorComboBox = new QComboBox;
    populateWithColors(penColorComboBox);
    penColorComboBox->setCurrentIndex(penColorComboBox->findText("darkslateblue"));

    penColorLabel = new QLabel(tr("Pen &Color:"));
    penColorLabel->setBuddy(penColorComboBox);

    rotationAngleSpinBox = new QSpinBox;
    rotationAngleSpinBox->setRange(0, 359);
    rotationAngleSpinBox->setWrapping(true);
    rotationAngleSpinBox->setSuffix(QLatin1String("\xB0"));

    rotationAngleLabel = new QLabel(tr("&Rotation Angle:"));
    rotationAngleLabel->setBuddy(rotationAngleSpinBox);

    connect(fillRuleComboBox, SIGNAL(activated(int)), this, SLOT(fillRuleChanged()));
    connect(fillColor1ComboBox, SIGNAL(activated(int)), this, SLOT(fillGradientChanged()));
    connect(fillColor2ComboBox, SIGNAL(activated(int)), this, SLOT(fillGradientChanged()));
    connect(penColorComboBox, SIGNAL(activated(int)), this, SLOT(penColorChanged()));

    for(QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); it++) {
        connect(penWidthSpinBox, SIGNAL(valueChanged(int)), *it, SLOT(setPenWidth(int)));
        connect(rotationAngleSpinBox, SIGNAL(valueChanged(int)), *it, SLOT(setRotationAngle(int)));
    }

    /*
     *   0  1  2  3  4  5  6  7  8  9
     * 0 x  x  x     Calendar Calendar
     * 0 x  x  x     Calendar Calendar
     * 0 x  x  x     Calendar Calendar
     * 0 x  x  x     Calendar Calendar
     * 0 x  x  x     Calendar Calendar
     * 0 x  x  x     Calendar Calendar
     * 1 f  fffffff
     * 2 g  c  t c
     * 3 p  pwsbpws
     * 4 pc pccbpcc
     * 5 r  rasbras
     * 6
     * 7
     * 8
     * 9
     *
     * 15 starsPath
     * rect rect ellipse circ-arc poly circ+sq
     * Qt 1 2 s u curve star wonkystar
     *
     *
     * */

    #include <string>
    using namespace std;
    //#include <string.h>

    QFrame* hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);

    /* in 3^H9 columns add all the funny shapes in one layout*/
    QGridLayout *topLayout = new QGridLayout;
    int iNCount=0;
    for(QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); it++, iNCount++) {
        //topLayout->addWidget(*it, iNCount / 9, iNCount % 9);
        // add separating line
        if(iNCount % 9 == 0) {
            hlineFrame = new QFrame();
            hlineFrame->setFrameShape(QFrame::HLine);
            if ((iNCount/9)%3==0) hlineFrame->setLineWidth(3);
            topLayout->addWidget(hlineFrame, (iNCount/9)*2, 0, 1, 10);
        }
        // add widget
        topLayout->addWidget(*it, (iNCount/9)*2 + 1, iNCount % 9);
        setBox(iNCount%9,iNCount/9,(*it)->getText());
    }

    hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);
    //hlineFrame->setFrameStyle(QFrame::Box | QFrame::Plain);
    hlineFrame->setLineWidth(3);
    //hlineFrame->setContentsMargins(0, 0, 2, 2);
    topLayout->addWidget(hlineFrame, (iNCount/9)*2+2, 0, 1, 10);

    // add vertical seperators
    for(int jColCount=0;jColCount<=9;jColCount++) {
        QFrame* vlineFrame = new QFrame();
        vlineFrame->setFrameShape(QFrame::VLine);
        if (jColCount%3==0) vlineFrame->setLineWidth(3);
        topLayout->addWidget(vlineFrame, 0, jColCount, (iNCount/9)*2+3, 1);
    }


    QGridLayout *mainLayout = new QGridLayout;

    int imainrow = 0;
    mainLayout->addLayout(topLayout, imainrow++, 0, 1, 4);

    //mainLayout->addWidget(*table, 0, 0, 1, 4);

    mainLayout->addWidget(fillRuleLabel, imainrow, 0);
    mainLayout->addWidget(fillRuleComboBox, imainrow++/*fromrow*/, 1/*fromcol*/, 1/*rowspan*/, 3/*colspan*/);

    // test: separating line
    hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);
    mainLayout->addWidget(hlineFrame, imainrow++, 0, 1, 4);

    mainLayout->addWidget(fillGradientLabel, imainrow, 0);
    mainLayout->addWidget(fillColor1ComboBox, imainrow, 1);
    mainLayout->addWidget(fillToLabel, imainrow, 2);
    mainLayout->addWidget(fillColor2ComboBox, imainrow++, 3);

    // test: separating line
    hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);
    mainLayout->addWidget(hlineFrame, imainrow++, 0, 1, 4);

    mainLayout->addWidget(penWidthLabel, imainrow, 0);
    mainLayout->addWidget(penWidthSpinBox, imainrow++, 1, 1, 3);

    // test: separating line
    hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);
    mainLayout->addWidget(hlineFrame, imainrow++, 0, 1, 4);

    mainLayout->addWidget(penColorLabel, imainrow, 0);
    mainLayout->addWidget(penColorComboBox, imainrow++, 1, 1, 3);

    // test: separating line
    hlineFrame = new QFrame();
    hlineFrame->setFrameShape(QFrame::HLine);
    mainLayout->addWidget(hlineFrame, imainrow++, 0, 1, 4);

    mainLayout->addWidget(rotationAngleLabel, imainrow, 0);
    mainLayout->addWidget(rotationAngleSpinBox, imainrow++, 1, 1, 3);

    int debug = 0;
    if (debug == 1) {
        QPushButton *mPB = new QPushButton(tr("0014"));
        mainLayout->addWidget(mPB, 0, 0, 1, 4);
    }

    QPushButton *mPushButton1;
    mPushButton1 = new QPushButton(tr("SuDoKu iKKu 1"));
    //mPushButton = new QPushButton(textPath);
    QPixmap pixmap(100,100);
    pixmap.fill(QColor("transparent"));
    QPainter painter(&pixmap);
    painter.setBrush(QBrush(Qt::black));
    painter.drawRect(10, 10, 100, 100);
    connect(mPushButton1, SIGNAL(clicked()), this, SLOT(pushButton1()));

    QPushButton *mPushButton2;
    mPushButton2 = new QPushButton(tr("Rotate NUMs"));
    connect(mPushButton2, SIGNAL(clicked()), this, SLOT(pushButton2()));

    QPushButton *mPushButtonLoad0;
    mPushButtonLoad0 = new QPushButton(tr("Load0"));
    connect(mPushButtonLoad0, SIGNAL(clicked()), this, SLOT(load0()));

    QPushButton *mPushButtonLoad1;
    mPushButtonLoad1 = new QPushButton(tr("Load1"));
    connect(mPushButtonLoad1, SIGNAL(clicked()), this, SLOT(load1()));

    QPushButton *mPushButtonLoad2;
    mPushButtonLoad2 = new QPushButton(tr("Load2"));
    connect(mPushButtonLoad2, SIGNAL(clicked()), this, SLOT(load2()));

    QPushButton *mPushButtonLoad3;
    mPushButtonLoad3 = new QPushButton(tr("Load3"));
    connect(mPushButtonLoad3, SIGNAL(clicked()), this, SLOT(load3()));

    QPushButton *mPushButtonLoad4;
    mPushButtonLoad4 = new QPushButton(tr("Load4"));
    connect(mPushButtonLoad4, SIGNAL(clicked()), this, SLOT(load4()));

    /*
    QPushButtonPaint *mPushButton2;
    mPushButton2 = new QPushButtonPaint(tr("SuDoKu"));
    //mPushButton = new QPushButton(textPath);
    QPixmap pixmap2(100,100);
    pixmap2.fill(QColor("transparent"));
    QPainter sudokuPainter(&pixmap2);
    sudokuPainter.setBrush(QBrush(Qt::black));
    sudokuPainter.drawRect(10, 10, 100, 100);
    //mPushButton->setPixmap(pixmap2);

    QPainterPath sudokuPath;
    QFont timesFont2("Times", 50);
    timesFont2.setStyleStrategy(QFont::ForceOutline);
    sudokuPath.addText(10, 70, timesFont2, tr("SuDoKu"));
*/

    QPushButton *mPushButton3;
    mPushButton3 = new QPushButton(tr("Clear"));
    connect(mPushButton3, SIGNAL(clicked()), this, SLOT(clearBox()));

    QPushButton *mPushButton4;
    mPushButton4 = new QPushButton(tr("Fill"));
    connect(mPushButton4, SIGNAL(clicked()), this, SLOT(fillBox()));

    mPushButton1->setDefault(true);
    mPushButton1->setCheckable(true);
    mPushButton1->setChecked(true);
    mainLayout->addWidget(mPushButton1);
    mainLayout->addWidget(mPushButton2);
    mainLayout->addWidget(mPushButton3);
    mainLayout->addWidget(mPushButton4);
    mainLayout->addWidget(mPushButtonLoad0);
    mainLayout->addWidget(mPushButtonLoad1);
    mainLayout->addWidget(mPushButtonLoad2);
    mainLayout->addWidget(mPushButtonLoad3);
    mainLayout->addWidget(mPushButtonLoad4);

    setLayout(mainLayout);

    fillRuleChanged();
    fillGradientChanged();
    penColorChanged();
    penWidthSpinBox->setValue(2);

    setWindowTitle(tr("SudokuIkku"));
}

void SudokuQtWindow::fillRuleChanged()
{
    Qt::FillRule rule = (Qt::FillRule)currentItemData(fillRuleComboBox).toInt();

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setFillRule(rule);
}

void SudokuQtWindow::fillGradientChanged()
{
    QColor color1 = qvariant_cast<QColor>(currentItemData(fillColor1ComboBox));
    QColor color2 = qvariant_cast<QColor>(currentItemData(fillColor2ComboBox));

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setFillGradient(color1, color2);
}

void SudokuQtWindow::penColorChanged()
{
    QColor color = qvariant_cast<QColor>(currentItemData(penColorComboBox));

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setPenColor(color);
}

void SudokuQtWindow::populateWithColors(QComboBox *comboBox)
{
    QStringList colorNames = QColor::colorNames();
    foreach (QString name, colorNames)
        comboBox->addItem(name, QColor(name));
}

QVariant SudokuQtWindow::currentItemData(QComboBox *comboBox)
{
    return comboBox->itemData(comboBox->currentIndex());
}

void SudokuQtWindow::pushButton1()
{
    sudokumain(1,NULL);
}

int buttonX=0,buttonY=0,buttonNumber=0;
void SudokuQtWindow::pushButton2()
{
    buttonNumber++;
    buttonX++;
    if (buttonX>=9) buttonX=0,buttonY++;
    if (buttonY>=9) buttonX=0,buttonY=0;
    RenderArea *ra = renderAreas.value(buttonX+buttonY*9);
    ra->setText(buttonNumber%10);
    setBox(buttonX,buttonY,'0'+buttonNumber);
}

void SudokuQtWindow::load0()
{
    this->clearBox();
    load();
    this->setBoxes();
}

void SudokuQtWindow::load1()
{
    this->clearBox();
    load1();
    this->setBoxes();
}

void SudokuQtWindow::load2()
{
    this->clearBox();
    load2();
    this->setBoxes();
}

void SudokuQtWindow::load3()
{
    this->clearBox();
    load3();
    this->setBoxes();
}

void SudokuQtWindow::load4()
{
    this->clearBox();
    load4();
    this->setBoxes();
}

void SudokuQtWindow::setBoxes()
{
    for(int j=0;j<9;j++) {
        int j10=j*10;
        for(int i=0;i<9;i++) {
            //c=it.substr(i+j10,1);
            char c=it[i+j10];
            int s=c-'0';
            RenderArea *ra = renderAreas.value(j+i*9);
            ra->setText(s);
        }
    }
}

void SudokuQtWindow::clearBox()
{
    int n=0;
    for(QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); it++) {
        // remove from renderAreas and delete
        //delete *it;
        (*it)->setText(0," ");
        setBox(n%9,n/9,'0');
        n++;
    }
    //renderAreas.clear();
    init(); initgrps();
}

void SudokuQtWindow::fillBox()
{
    QPainterPath rectPath = qpp_rectPath();
    renderAreas.push_back(new RenderArea(rectPath));

    // TODO: keep layouts as class vars.
    // manipulate them

    //for(QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); it++) {
    //    connect(penWidthSpinBox, SIGNAL(valueChanged(int)), *it, SLOT(setPenWidth(int)));
    //    connect(rotationAngleSpinBox, SIGNAL(valueChanged(int)), *it, SLOT(setRotationAngle(int)));
    //}

}
