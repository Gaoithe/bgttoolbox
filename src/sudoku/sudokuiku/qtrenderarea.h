
#ifndef RENDERAREA_H
#define RENDERAREA_H

#include <QPainterPath>
#include <QWidget>

/* *
 * a RenderArea widget is a base class for Number and other widgets
 * SudokuQtWindow arranges all the widgets and hooks up actions
 * */

class RenderArea : public QWidget
{
    Q_OBJECT

public:
    explicit RenderArea(const QPainterPath &path, QWidget *parent = 0, char *text = NULL, int xx=0, int yy=0);
    QSize minimumSizeHint() const;
    QSize sizeHint() const;
    void setXY(int xx,int yy);

signals:
    void redirectKey(int num, int x, int y);

public slots:
    void setFillRule(Qt::FillRule rule);
    void setFillGradient(const QColor &color1, const QColor &color2);
    void setPenWidth(int width);
    void setPenColor(const QColor &color);
    void setNumberSize(int h);
    void setRotationAngle(int degrees);
    void setText(int n, char *t=NULL);
    char getText();
    void sendKey(){emit redirectKey(num,x,y);}

protected:
    void paintEvent(QPaintEvent *event);
    void keyPressEvent(QKeyEvent *e);

private:
    QPainterPath path;
    QColor fillColor1;
    QColor fillColor2;
    int penWidth;
    QColor penColor;
    int numberSize;
    int rotationAngle;

    char *text=NULL;
    int num;
    int x,y;
    QFont timesFont;

};


#endif // RENDERAREA_H
