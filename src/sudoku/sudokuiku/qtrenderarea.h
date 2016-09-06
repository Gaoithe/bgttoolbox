
#ifndef RENDERAREA_H
#define RENDERAREA_H

#include <QPainterPath>
#include <QWidget>


class RenderArea : public QWidget
{
    Q_OBJECT

public:
    explicit RenderArea(const QPainterPath &path, QWidget *parent = 0, char *text = NULL);

    QSize minimumSizeHint() const;
    QSize sizeHint() const;

public slots:
    void setFillRule(Qt::FillRule rule);
    void setFillGradient(const QColor &color1, const QColor &color2);
    void setPenWidth(int width);
    void setPenColor(const QColor &color);
    void setRotationAngle(int degrees);
    void setText(int n, char *t=NULL);
    char getText();

protected:
    void paintEvent(QPaintEvent *event);

private:
    QPainterPath path;
    QColor fillColor1;
    QColor fillColor2;
    int penWidth;
    QColor penColor;
    int rotationAngle;

    char *text=NULL;
    int num;
    QFont timesFont;

};


#endif // RENDERAREA_H
