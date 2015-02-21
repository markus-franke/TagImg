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

        DropArea {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "lightgreen"
                opacity: 0.5
                visible: parent.containsDrag
            }

            onDropped: {
                if(drop.urls.length > 0)
                {
                    var targetObject = drop.urls
                    console.log("Dropped ", targetObject)
                    AppLogic.setWorklist(targetObject)
                }
            }
        }
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

    onWatermarkSizeChanged: {
        mainWindow.watermarkSizeChanged(scaleXPct, scaleYPct)
    }

    function showMessage(message) {
        var component = Qt.createComponent("qrc:///P4U_Message.qml")
        if (component.status === Component.Ready) {
            var mBox = component.createObject(rootWindow);
            mBox.message = message
            mBox.visible = true
        }
    }

    // incoming
    signal watermarkDone(int exitCode)
    signal targetObjectChanged(string name)
    signal watermarkChanged(string watermark)
    signal setProgressValue(int value)
    signal imageScaleChanged(int percent)
    signal dependencyError(string dependencies)
    signal watermarkSizeChanged(int scaleXPct, int scaleYPct)
}
