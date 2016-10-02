/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef SUDOKUQTWINDOW_H
#define SUDOKUQTWINDOW_H

#include <QWidget>
#include <QtWidgets>
#include <string>
using namespace std;
#include "lightwidget.h"

QPainterPath qpp_sudokuPath(void);

QT_BEGIN_NAMESPACE
class QComboBox;
class QLabel;
class QSpinBox;
class QErrorMessage;
QT_END_NAMESPACE
class RenderArea;

class SudokuQtWindow : public QWidget
{
    Q_OBJECT

public:
    SudokuQtWindow();
    int alertMessage(string m, int next=1);

protected:
    void keyPressEvent(QKeyEvent *event) Q_DECL_OVERRIDE;

public slots:
    void handleKey(int n, int x, int y);

private slots:
    void fillRuleChanged();
    void fillGradientChanged();
    void penColorChanged();
    void vvalidateSudoku();
    void pushButtonMode();
    void pushButton1();
    void pushButton2();
    void ssolveW();
    void ssolveX();
    void ssolveY();
    void shint();
    void sload0();
    void sload1();
    void sload2();
    void sload3();
    void sload4();
    void clearBox();
    void setBoxes();
    void fillBox();

private:
    int mode=0;

    void populateWithColors(QComboBox *comboBox);
    QVariant currentItemData(QComboBox *comboBox);

    QList<RenderArea*> renderAreas;
    QLabel *fillRuleLabel;
    QLabel *fillGradientLabel;
    QLabel *fillToLabel;
    QLabel *penWidthLabel;
    QLabel *penColorLabel;
    QLabel *rotationAngleLabel;
    QComboBox *fillRuleComboBox;
    QComboBox *fillColor1ComboBox;
    QComboBox *fillColor2ComboBox;
    QSpinBox *penWidthSpinBox;
    QComboBox *penColorComboBox;
    QSpinBox *rotationAngleSpinBox;
    QSpinBox *numberSizeSpinBox;
    QLabel *numberSizeLabel;

    //QErrorMessage *alertMessageDialog;
    QGridLayout *topLayout;
    QGridLayout *mainLayout;
    QGridLayout *botGameLayout;
    QGridLayout *botAppearanceLayout;
    QWidget *botGameFrame;
    QWidget *botAppearanceFrame;

    LightWidget *mLight;

};


#endif // SUDOKUQTWINDOW_H
