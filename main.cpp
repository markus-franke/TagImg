#include <QtGui/QGuiApplication>
#include <QQmlApplicationEngine>

#include <QThread>
#include <QQmlContext>
#include <QQuickWindow>

#include "applogic.h"
#include "datamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // get reference to datamodel
    DataModel& dm = DataModel::instance();

    // create application logic
    AppLogic appLogic;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("AppLogic", &appLogic);
    engine.rootContext()->setContextProperty("DataModel", &dm);
    engine.load(QUrl("qrc:///main.qml"));

    QQuickWindow* window = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
    window->setTitle("TagImg");
    window->setIcon(QIcon("qrc:///icons/Watermark.png"));
    window->show();

    // start new thread for application logic
    QThread appLogicThread;
    appLogic.moveToThread(&appLogicThread);
    appLogicThread.start();

    // connect signals App -> GUI
    QObject::connect(&appLogic, SIGNAL(watermarkDone(int)), window, SIGNAL(watermarkDone(int)));
    QObject::connect(&appLogic, SIGNAL(setProgressValue(int)), window, SIGNAL(setProgressValue(int)));

    // connect signals DataModel -> GUI
    QObject::connect(&dm, SIGNAL(targetObjectChanged(QString)), window, SIGNAL(targetObjectChanged(QString)));
    QObject::connect(&dm, SIGNAL(watermarkChanged(QString)), window, SIGNAL(watermarkChanged(QString)));
    QObject::connect(&dm, SIGNAL(imageScaleChanged(int)), window, SIGNAL(imageScaleChanged(int)));
    QObject::connect(&dm, SIGNAL(watermarkSizeChanged(int,int)), window, SIGNAL(watermarkSizeChanged(int,int)));

    // some sample work items for testing
    //appLogic.setWorklist("file:///home/user/Desktop/qt-logo.jpg");
    //appLogic.setWorklist("file:///home/user/Desktop/pics");

    // kick-off the app
    int ret = app.exec();

    // wait for application logic thread to quit properly
    appLogicThread.exit();
    appLogicThread.wait();

    return ret;
}
