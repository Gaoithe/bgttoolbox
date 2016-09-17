
#include "qtrenderarea.h"
#include "itoa.h"
#include "qtwindow.h"

#include <QPainter>
#include <QtWidgets>

RenderArea::RenderArea(const QPainterPath &path, QWidget *parent, char *text)
    : QWidget(parent), path(path)
{
    penWidth = 1;
    numberSize = 30;
    rotationAngle = 0;
    setBackgroundRole(QPalette::Base);

    this->timesFont = QFont("Times", numberSize); // point size: originally 50, now 30 . .
    this->timesFont.setStyleStrategy(QFont::ForceOutline);

    if (text) {
        setText(text[0] - '0',text);
    }
}

QSize RenderArea::minimumSizeHint() const
{
    return QSize(20, 20);
}

QSize RenderArea::sizeHint() const
{
    return QSize(80, 80);
}

void RenderArea::setFillRule(Qt::FillRule rule)
{
    path.setFillRule(rule);
    update();
}

void RenderArea::setFillGradient(const QColor &color1, const QColor &color2)
{
    fillColor1 = color1;
    fillColor2 = color2;
    update();
}

void RenderArea::setPenWidth(int width)
{
    penWidth = width;
    update();
}

void RenderArea::setNumberSize(int h)
{
    numberSize = h;
    this->timesFont = QFont("Times", numberSize);
    update();
}

void RenderArea::setPenColor(const QColor &color)
{
    penColor = color;
    update();
}

void RenderArea::setRotationAngle(int degrees)
{
    rotationAngle = degrees;
    update();
}

void RenderArea::paintEvent(QPaintEvent *)
{
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);

    painter.scale(width() / 100.0, height() / 100.0);
    painter.translate(50.0, 50.0);
    painter.rotate(-rotationAngle);
    painter.translate(-50.0, -50.0);

    painter.setPen(QPen(penColor, penWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    QLinearGradient gradient(0, 0, 0, 100);
    gradient.setColorAt(0.0, fillColor1);
    gradient.setColorAt(1.0, fillColor2);
    painter.setBrush(gradient);
    painter.drawPath(path);
}

void RenderArea::setText(int n, char *t)
{
    this->num = n;
    if (t) this->text = t;
    else if (n == 0) this->text = " ";
    else this->text = itoa(n);
    // do nothing . . unless it is a
    //QPainterPath sudokuPath = qpp_sudokuPath("0");
    //QPainterPath pp(this);

    // clear this path.
    this->path = QPainterPath();
    // add new value/text
    this->path.addText(10, 70, timesFont, Window::tr(text));
    update();
}

char RenderArea::getText()
{
    if (this->text) return this->text[0];
    else return '0';
}
