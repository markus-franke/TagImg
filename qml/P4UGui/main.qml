import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Window 2.1

ApplicationWindow {

    width: 370
    height: 330

    StackView {
        id: pageStack
        initialItem: Qt.resolvedUrl("qrc:/MainWindow.qml")
    }


//    FileBrowser {
//        id: fileBrowser
//        focus: true
//        bMultiSelect: true

//        onProcessWorklist: {
//            hide()
//            setWorklist(worklist)
//        }
//    }

//    FileBrowser {
//        id: fileBrowerWatermark
//        bChooseFolder: false

//        onProcessWorklist: {
//            hide()
//            setWatermark(worklist.toString());
//        }
//    }

//    ViewWatermark {
//        id: viewWatermark
//    }

//    onWatermarkDone: {
//        if(exitCode == 0)
//            showMessage("Watermark successfully applied!")
//        else
//            showMessage("Error " + exitCode + " while applying watermark!")

//        progressBar.opacity = 0.0
//    }

//    onTargetObjectChanged: workloadList.setObject(name)

//    onWatermarkChanged: { currentWatermark.source = watermark }

//    onSetProgressValue: {
//        progressBar.value = value
//        if(progressBar.opacity == 0)
//            progressBar.opacity = 1.0
//        console.debug(value)
//    }

//    onImageScaleChanged: sliderScaleOfImage.currentValue = percent

//    onDependencyError: {
//        showMessage("Unable to find one or more dependencies (" + dependencies + ") of P4UGui. They are either not installed or not in the PATH.")
//        applyWatermarkButton.enabled = false;
//    }

//    function showMessage(message) {
//        messageBox.message = message
//        messageBox.visible = true
//    }

//    P4U_Message {
//        id: messageBox
//        visible: false
//    }

//    Component.onCompleted: show()

//    onVisibleChanged: console.debug("main.qml is ", visible ? "visible": "invisible")

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
