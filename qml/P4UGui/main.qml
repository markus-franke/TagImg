import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.1

ApplicationWindow {

    id: rootWindow

    width: 370
    height: 330

    StackView {
        id: pageStack
        initialItem: mainWindow
    }

    MainWindow {
        id: mainWindow
    }

    onWatermarkChanged: mainWindow.watermarkChanged(watermark)
    onTargetObjectChanged: mainWindow.targetObjectChanged(name)
    onImageScaleChanged: mainWindow.imageScaleChanged(percent)
    onSetProgressValue: mainWindow.setProgressValue(value)

    onDependencyError: {
        showMessage("Unable to find one or more dependencies (" + dependencies + ") of P4UGui. They are either not installed or not in the PATH.")
        mainWindow.dependencyError()
    }

    onWatermarkDone: {
        if(exitCode == 0)
            showMessage("Watermark successfully applied!")
        else
            showMessage("Error " + exitCode + " while applying watermark!")

        mainWindow.watermarkDone()
    }

    function showMessage(message) {
        var component = Qt.createComponent("qrc:///P4U_Message.qml")
        if (component.status === Component.Ready) {
            var mBox = component.createObject(rootWindow);
            mBox.message = message
            mBox.visible = true
        }
    }

    // outgoing
    signal applyWatermark()
    signal setTargetObject(string name)
    signal setWorklist(var worklist)
    signal setImageScale(int percent)
    signal setWatermark(string name)

    // incoming
    signal watermarkDone(int exitCode)
    signal targetObjectChanged(string name)
    signal watermarkChanged(string watermark)
    signal setProgressValue(int value)
    signal imageScaleChanged(int percent)
    signal dependencyError(string dependencies);
}
