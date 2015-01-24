#include "qtrenderarea.h"
#include "qtwindow.h"

#include <QtWidgets>

#include <math.h>

class QPushButtonPaint:QPushButton
{
public:
  QPushButtonPaint(QObject *parent = 0){}
  //QPushButtonPaint(QObject *parent = 0,QString s){}
  void paintEvent ( QPaintEvent * );
};

void QPushButtonPaint::paintEvent(QPaintEvent* Paint)
{
  Paint->rect();
}

const float Pi = 3.14159f;

Window::Window()
{
    QPainterPath rectPath;
    rectPath.moveTo(20.0, 30.0);
    rectPath.lineTo(80.0, 30.0);
    rectPath.lineTo(80.0, 70.0);
    rectPath.lineTo(20.0, 70.0);
    rectPath.closeSubpath();

    QPainterPath roundRectPath;
    roundRectPath.moveTo(80.0, 35.0);
    roundRectPath.arcTo(70.0, 30.0, 10.0, 10.0, 0.0, 90.0);
    roundRectPath.lineTo(25.0, 30.0);
    roundRectPath.arcTo(20.0, 30.0, 10.0, 10.0, 90.0, 90.0);
    roundRectPath.lineTo(20.0, 65.0);
    roundRectPath.arcTo(20.0, 60.0, 10.0, 10.0, 180.0, 90.0);
    roundRectPath.lineTo(75.0, 70.0);
    roundRectPath.arcTo(70.0, 60.0, 10.0, 10.0, 270.0, 90.0);
    roundRectPath.closeSubpath();

    QPainterPath ellipsePath;
    ellipsePath.moveTo(80.0, 50.0);
    ellipsePath.arcTo(20.0, 30.0, 60.0, 40.0, 0.0, 360.0);

    QPainterPath piePath;
    piePath.moveTo(50.0, 50.0);
    piePath.arcTo(20.0, 30.0, 60.0, 40.0, 60.0, 240.0);
    piePath.closeSubpath();

    QPainterPath polygonPath;
    polygonPath.moveTo(10.0, 80.0);
    polygonPath.lineTo(20.0, 10.0);
    polygonPath.lineTo(80.0, 30.0);
    polygonPath.lineTo(90.0, 70.0);
    polygonPath.closeSubpath();

    QPainterPath groupPath;
    groupPath.moveTo(60.0, 40.0);
    groupPath.arcTo(20.0, 20.0, 40.0, 40.0, 0.0, 360.0);
    groupPath.moveTo(40.0, 40.0);
    groupPath.lineTo(40.0, 80.0);
    groupPath.lineTo(80.0, 80.0);
    groupPath.lineTo(80.0, 40.0);
    groupPath.closeSubpath();

    QPainterPath textPath;
    QFont timesFont("Times", 50);
    timesFont.setStyleStrategy(QFont::ForceOutline);
    textPath.addText(10, 70, timesFont, tr("Qt"));

    QPainterPath textPath1;
    textPath1.addText(10, 70, timesFont, tr("1"));

    QPainterPath textPath2;
    textPath2.addText(10, 70, timesFont, tr("2"));

    QPainterPath textPath3;
    textPath3.addText(10, 70, timesFont, tr("s u d o k u"));

    QPainterPath bezierPath;
    bezierPath.moveTo(20, 30);
    bezierPath.cubicTo(80, 0, 50, 50, 80, 80);

    QPainterPath starPath;
    starPath.moveTo(90, 50);
    for (int i = 1; i < 5; ++i) {
        starPath.lineTo(50 + 40 * cos(0.8 * i * Pi),
                        50 + 40 * sin(0.8 * i * Pi));
    }
    starPath.closeSubpath();

    int jNCount = 0;

    QPainterPath starsPath[20];
        int j=0;

        // pentagon 108 (= 54 + 54) + 72 degrees, 36 + 36 + 36 + 36 + 36 = 180 degrees pentagram
        // what is 0.8 * Pi ?? 4 5ths of Pi. ??
        // Pi * 1 radian = 180 degrees

        /*
         * 0.8 * Pi = 144 degrees (= 36 * 4)
         *
        i=0 ang=0                     x=90       ,y=50
        i=1 ang=144.000000=144.000000 x=17.639368,y=73.511476
        i=2 ang=288.000000=288.000000 x=62.360525,y=11.957689
        i=3 ang=432.000000=72.000000 x=62.360911,y=88.042185
        i=4 ang=576.000000=216.000000 x=17.639129,y=26.488852

        i to 5 and 0.8 pi   4 5ths
        i to 7 and ?        6 7ths?
          */
        // 5 is pretty, 7 is pretty, 9 is wonky? what is the sequence?
        int points = 5;

        for (j=5;j<20;j++) {

            float angle = (float(points - 1)/float(points)) * Pi;
            //i = 0;
            starsPath[j].moveTo(90, 50);
            for (int i = 1; i < points; ++i) {
                qreal xb,yb;
                starsPath[j].lineTo(xb = 50 + 40 * cos(i * angle),
                                yb = 50 + 40 * sin(i * angle));
                printf("j=%d i=%d ang=%f=%f x=%f,y=%f \n",j,i,0.8*i*180,fmod(0.8*i*180,360),xb,yb);
            }
            starsPath[j].closeSubpath();
            renderAreas.push_back(new RenderArea(starsPath[j]));
            jNCount++;

            points ++;
        }

    // TODO: draw a cog object to act as settings button
    // TODO: maybe better using arcs simpler, . . .
    QPainterPath cogPath;
    cogPath.moveTo(90, 50);
    qreal xo = 90;
    qreal yo = 50;
    for (int i = 1; i < 5; ++i) {
        qreal x = 50 + 40 * cos(0.8 * i * Pi);
        qreal y = 50 + 40 * sin(0.8 * i * Pi);
        //cogPath.cubicTo(x,y,x+20,y+20,x-20,y-20);

        // bockety star :)
        //cogPath.cubicTo(x+20,y+20,x-20,y-20,x,y);

        // boring normal star
        /*qreal x1 = xo + (x - xo)/2.0;
        qreal y1 = yo + (y - yo)/2.0;
        qreal x2 = xo + (x - xo)/2.0;
        qreal y2 = yo + (y - yo)/2.0;
        */

        // also bockety
        /*x1 = 50 + xo + (x - xo)/2.0;
        y1 = 50 + yo + (y - yo)/2.0;
        x2 = -10 + xo + (x - xo)/2.0;
        y2 = -10 + yo + (y - yo)/2.0;
        */

        /*
         *         *xh,yh
         *          *
         *         | *              *x,y
         *         |  *         *   *
         *         |   *   *        *
         *         +----*x2,y2      *
         *         *                *
         *     *                    *
         * *                        *
      xo,yo**************************
         * */

        // it is kindof working. TODO: debug by drawing lines and printf

        qreal x1,y1,x2,y2;
        qreal hh,aa,oo;
        qreal h1,xh1,yh1,xhh1,yhh1;
        qreal h2,xh2,yh2,xhh2,yhh2;
        qreal line_fraction = 2.0;

        // height for bezier points
        h1 = 40.0;
        h2 = -10.0;

        // half way point (or third or . . . depending on line_fraction )
        x2 = xo + (x - xo)/line_fraction;
        y2 = yo + (y - yo)/line_fraction;

        // h = height perpinducular over line xo,yo x,y to xh,yh
        // xh = x2 - xhh; // distance from + to x2
        // yh = y2 + yhh; // distance from + to y2

        // xhh and yhh are opposite and adjacent of triangle similar to main triangle
        // h is hypotenuse of this small tri

        // hh = hypotenuse of main tri
        // aa = adjacent
        // oo = opposite
        aa = y - yo; oo = x - xo;
        hh = sqrt(oo * oo + aa * aa);

        printf("i=%d x=%f,y=%f xo=%f,yo=%f 1/%f way x2=%f,y2=%f\n",
               i,x,y,xo,yo,line_fraction,x2,y2);
        printf("aa=%f oo=%f hh=%f\n",
               aa,oo,hh);

        // aa/hh == yhh/h; oo/hh == xhh/h; =>
        yhh1 = (h1 * aa) / hh;
        xhh1 = (h1 * oo) / hh;
        xh1 = x2 - xhh1;
        yh1 = y2 + yhh1;

        printf("h1=%f xh1=%f,yh1=%f xhh1=%f,yhh1=%f\n",
               h1,xh1,yh1,xhh1,yhh1);

        yhh2 = (h2 * aa) / hh;
        xhh2 = (h2 * oo) / hh;
        xh2 = x2 - xhh2;
        yh2 = y2 + yhh2;

        printf("h2=%f xh2=%f,yh2=%f xhh2=%f,yhh2=%f\n",
               h2,xh2,yh2,xhh2,yhh2);

        cogPath.cubicTo(xh1,yh1,xh2,yh2,x,y);

        // NEXT!
        xo = x; yo = y;
    }
    cogPath.closeSubpath();

    renderAreas.push_back(new RenderArea(rectPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(roundRectPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(ellipsePath));
    jNCount++;
    renderAreas.push_back(new RenderArea(piePath));
    jNCount++;
    renderAreas.push_back(new RenderArea(polygonPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(groupPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(textPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(textPath1));
    jNCount++;
    renderAreas.push_back(new RenderArea(textPath2));
    jNCount++;
    renderAreas.push_back(new RenderArea(textPath3));
    jNCount++;
    renderAreas.push_back(new RenderArea(bezierPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(starPath));
    jNCount++;
    renderAreas.push_back(new RenderArea(cogPath));
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
     * */

     #include <string>
     using namespace std;
     //#include <string.h>

    /* in 3 columns add all the funny shapes in one layout*/
    QGridLayout *topLayout = new QGridLayout;
    int iNCount=0;
    for(QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); it++, iNCount++)
        topLayout->addWidget(*it, iNCount / 9, iNCount % 9);

    QGridLayout *mainLayout = new QGridLayout;

    mainLayout->addLayout(topLayout, 0, 0, 1, 4);

    //mainLayout->addWidget(*table, 0, 0, 1, 4);

    mainLayout->addWidget(fillRuleLabel, 1, 0);
    mainLayout->addWidget(fillRuleComboBox, 1/*fromrow*/, 1/*fromcol*/, 1/*rowspan*/, 3/*colspan*/);
    mainLayout->addWidget(fillGradientLabel, 2, 0);
    mainLayout->addWidget(fillColor1ComboBox, 2, 1);
    mainLayout->addWidget(fillToLabel, 2, 2);
    mainLayout->addWidget(fillColor2ComboBox, 2, 3);
    mainLayout->addWidget(penWidthLabel, 3, 0);
    mainLayout->addWidget(penWidthSpinBox, 3, 1, 1, 3);
    mainLayout->addWidget(penColorLabel, 4, 0);
    mainLayout->addWidget(penColorComboBox, 4, 1, 1, 3);
    mainLayout->addWidget(rotationAngleLabel, 5, 0);
    mainLayout->addWidget(rotationAngleSpinBox, 5, 1, 1, 3);

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

    mPushButton1->setDefault(true);
    mPushButton1->setCheckable(true);
    mPushButton1->setChecked(true);
    mainLayout->addWidget(mPushButton1);
    //mainLayout->addWidget(mPushButton2);

    setLayout(mainLayout);

    fillRuleChanged();
    fillGradientChanged();
    penColorChanged();
    penWidthSpinBox->setValue(2);

    setWindowTitle(tr("SudokuIkku"));
}

void Window::fillRuleChanged()
{
    Qt::FillRule rule = (Qt::FillRule)currentItemData(fillRuleComboBox).toInt();

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setFillRule(rule);
}

void Window::fillGradientChanged()
{
    QColor color1 = qvariant_cast<QColor>(currentItemData(fillColor1ComboBox));
    QColor color2 = qvariant_cast<QColor>(currentItemData(fillColor2ComboBox));

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setFillGradient(color1, color2);
}

void Window::penColorChanged()
{
    QColor color = qvariant_cast<QColor>(currentItemData(penColorComboBox));

    for (QList<RenderArea*>::iterator it = renderAreas.begin(); it != renderAreas.end(); ++it)
        (*it)->setPenColor(color);
}

void Window::populateWithColors(QComboBox *comboBox)
{
    QStringList colorNames = QColor::colorNames();
    foreach (QString name, colorNames)
        comboBox->addItem(name, QColor(name));
}

QVariant Window::currentItemData(QComboBox *comboBox)
{
    return comboBox->itemData(comboBox->currentIndex());
}

#include "SudokuMainPocketC.h"
void Window::pushButton1()
{
    sudokumain(1,NULL);
}

