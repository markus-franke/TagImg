#include <QtGui/QGuiApplication>
#include <QQmlApplicationEngine>

#include <applogic.h>

#include <QThread>
#include <QDebug>
#include <QQmlContext>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    AppLogic appLogic;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("AppLogic", &appLogic);
    engine.load(QUrl("qrc:///main.qml"));

    QQuickWindow* window = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
    window->setTitle("P4U Gui");
    window->setIcon(QIcon("qrc:///icons/Watermark.png"));
    window->show();

    // start new thread for application logic
    QThread appLogicThread;
    appLogic.moveToThread(&appLogicThread);
    appLogicThread.start();

    // connect signals between GUI and application
    // GUI -> App
    QObject::connect(window, SIGNAL(applyWatermark()), &appLogic, SLOT(applyWatermark()));

    // App -> GUI
    QObject::connect(&appLogic, SIGNAL(watermarkDone(int)), window, SIGNAL(watermarkDone(int)));
    QObject::connect(&appLogic, SIGNAL(targetObjectChanged(QString)), window, SIGNAL(targetObjectChanged(QString)));
    QObject::connect(&appLogic, SIGNAL(watermarkChanged(QString)), window, SIGNAL(watermarkChanged(QString)));
    QObject::connect(&appLogic, SIGNAL(setProgressValue(int)), window, SIGNAL(setProgressValue(int)));
    QObject::connect(&appLogic, SIGNAL(imageScaleChanged(int)), window, SIGNAL(imageScaleChanged(int)));
    QObject::connect(&appLogic, SIGNAL(dependencyError(QString)), window, SIGNAL(dependencyError(QString)));

    // read default settings
    appLogic.readDefaultSettings();

    // check dependencies
    appLogic.checkDeps();

    int ret = app.exec();

    appLogicThread.exit();
    appLogicThread.wait();

    return ret;
}
