#include <QtGui/QGuiApplication>
#include <QQmlApplicationEngine>

#include "qtquick2applicationviewer.h"

#include <applogic.h>

#include <QQuickItem>
#include <QThread>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    //QQmlApplicationEngine engine(QStringLiteral("qml/P4UGui/main.qml"));

    QtQuick2ApplicationViewer viewer;
    viewer.setSource(QStringLiteral("qrc:///main.qml"));
    viewer.setTitle("P4U Gui");
    viewer.setIcon(QIcon("qrc:///icons/Watermark.png"));
    viewer.showExpanded();

    AppLogic appLogic;

    // start new thread for application logic
    QThread appLogicThread;
    appLogic.moveToThread(&appLogicThread);
    appLogicThread.start();

    // connect signals between GUI and application
    // GUI -> App
    QObject::connect(viewer.rootObject(), SIGNAL(applyWatermark()), &appLogic, SLOT(applyWatermark()));
    QObject::connect(viewer.rootObject(), SIGNAL(setTargetObject(QString)), &appLogic, SLOT(setTargetObject(QString)));
    QObject::connect(viewer.rootObject(), SIGNAL(setWorklist(QVariant)), &appLogic, SLOT(setWorklist(QVariant)));
    QObject::connect(viewer.rootObject(), SIGNAL(setImageScale(int)), &appLogic, SLOT(setImageScale(int)));
    QObject::connect(viewer.rootObject(), SIGNAL(setWatermark(QString)), &appLogic, SLOT(setWatermark(QString)));
    // App -> GUI
    QObject::connect(&appLogic, SIGNAL(watermarkDone(int)), viewer.rootObject(), SIGNAL(watermarkDone(int)));
    QObject::connect(&appLogic, SIGNAL(targetObjectChanged(QString)), viewer.rootObject(), SIGNAL(targetObjectChanged(QString)));
    QObject::connect(&appLogic, SIGNAL(watermarkChanged(QString)), viewer.rootObject(), SIGNAL(watermarkChanged(QString)));
    QObject::connect(&appLogic, SIGNAL(setProgressValue(int)), viewer.rootObject(), SIGNAL(setProgressValue(int)));
    QObject::connect(&appLogic, SIGNAL(imageScaleChanged(int)), viewer.rootObject(), SIGNAL(imageScaleChanged(int)));
    QObject::connect(&appLogic, SIGNAL(dependencyError(QString)), viewer.rootObject(), SIGNAL(dependencyError(QString)));

    // read default settings
    appLogic.readDefaultSettings();

    // check dependencies
    appLogic.checkDeps();

    int ret = app.exec();

    appLogicThread.exit();
    appLogicThread.wait();

    return ret;
}
