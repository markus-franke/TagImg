import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Window 2.1

P4U_Page {
    id: mainWindow

    Grid {
        id: buttonGrid
        anchors { left: parent.left; top: parent.top; margins: 15; }
        width: parent.width
        spacing: 20

        columns: 2

        P4U_Button {
            id: chooseFileFolderButton
            width: buttonGrid.width/buttonGrid.columns - buttonGrid.anchors.margins - buttonGrid.spacing/2
            height: mainWindow.height / 5.5
            text: "Choose File/Folder"
            onClicked: fileBrowser.show()
        }

        Text {
            id: workloadList

            property string fullObjectName/* : "file:///home/user/Desktop/india_orig.jpg"*/;

            text: "  "
            color: "white"
            font { bold: true; pointSize: 12 }
            wrapMode: Text.Wrap
            width: buttonGrid.width / buttonGrid.columns - buttonGrid.spacing
            height: chooseFileFolderButton.height
            verticalAlignment: Text.AlignVCenter

            function setObject(name) {
                fullObjectName = name
                text = name.substring(name.lastIndexOf("/") + 1, name.length)
            }
        }

        P4U_Button {
            id: chooseWatermarkButton
            width: chooseFileFolderButton.width
            height: chooseFileFolderButton.height
            text: "Choose Watermark"

            onClicked: fileBrowerWatermark.show()
        }

        Image {
            id: currentWatermark
            height: chooseWatermarkButton.height
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    viewWatermark.watermark = currentWatermark.source
                    viewWatermark.source = workloadList.fullObjectName
                    viewWatermark.show()
                }
                onPressAndHold: console.debug("pressnhold")
            }
        }

        Text {
            id: textScaleOfImage
            width: chooseWatermarkButton.width
            text: "Scale image(s) to %"
            color: "white"
            font.bold: true
            //font.pixelSize: chooseWatermarkButton.fontPixelSize
        }

        P4U_Slider {
            id: sliderScaleOfImage
            color: textScaleOfImage.color
            font: textScaleOfImage.font
            width: workloadList.width
            height: textScaleOfImage.height
            focus: true

            onValueChanged: setImageScale(value)
        }
    }

    P4U_ProgressBar {
            id: progressBar
            anchors { top: buttonGrid.bottom; left: parent.left; topMargin: 20; right: parent.right; leftMargin: buttonGrid.anchors.leftMargin; rightMargin: buttonGrid.anchors.rightMargin }
            width: parent.width
            height: 12
            value: 0
            opacity: 0.0
    }

    Row {
        anchors { left: parent.left; leftMargin: buttonGrid.anchors.leftMargin; bottom: parent.bottom; bottomMargin: 10 }
        spacing: 20

        P4U_Button {
            id: applyWatermarkButton
            width: chooseWatermarkButton.width
            height: chooseWatermarkButton.height
            text: "Apply Watermark"

            onClicked: {
                if(workloadList.text == "  ")
                    showMessage("Please choose any file or folder!")
                else
                    applyWatermark()
            }
        }

        P4U_Button {
            id: exitButton
            width: applyWatermarkButton.width
            height: applyWatermarkButton.height
            text: "Exit"
            //iconSource: "qrc:///icons/Exit.png"
            onClicked: {
                Qt.quit()
            }
        }
    }


    FileBrowser {
        id: fileBrowser
        focus: true
        bMultiSelect: true

        onProcessWorklist: {
            hide()
            setWorklist(worklist)
        }
    }

    FileBrowser {
        id: fileBrowerWatermark
        bChooseFolder: false

        onProcessWorklist: {
            hide()
            setWatermark(worklist.toString());
        }
    }

    ViewWatermark {
        id: viewWatermark
    }

    onWatermarkDone: {
        if(exitCode == 0)
            showMessage("Watermark successfully applied!")
        else
            showMessage("Error " + exitCode + " while applying watermark!")

        progressBar.opacity = 0.0
    }

    onTargetObjectChanged: workloadList.setObject(name)

    onWatermarkChanged: { currentWatermark.source = watermark }

    onSetProgressValue: {
        progressBar.value = value
        if(progressBar.opacity == 0)
            progressBar.opacity = 1.0
        console.debug(value)
    }

    onImageScaleChanged: sliderScaleOfImage.currentValue = percent

    onDependencyError: {
        showMessage("Unable to find one or more dependencies (" + dependencies + ") of P4UGui. They are either not installed or not in the PATH.")
        applyWatermarkButton.enabled = false;
    }

    function showMessage(message) {
        messageBox.message = message
        messageBox.visible = true
    }

    P4U_Message {
        id: messageBox
        visible: false
    }

    Component.onCompleted: show()

    onVisibleChanged: console.debug("main.qml is ", visible ? "visible": "invisible")

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
