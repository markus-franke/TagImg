import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

P4U_Page {
    id: mainWindow
    focus: true

    Grid {
        id: buttonGrid
        anchors { left: parent.left; top: parent.top; margins: 15; }
        width: parent.width
        spacing: 20
        focus: true

        columns: 2

        P4U_Button {
            id: chooseFileFolderButton
            width: buttonGrid.width/buttonGrid.columns - buttonGrid.anchors.margins - buttonGrid.spacing/2
            height: mainWindow.height / 5.5
            text: "Choose File/Folder"
            onClicked: pageStack.push(chooseFileFolderBrowser)
        }

        Text {
            id: workloadList

            property string fullObjectName;

            text: ""
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

            onClicked: pageStack.push(chooseWatermarkBrowser)
        }

        Image {
            id: currentWatermark
            height: chooseWatermarkButton.height
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(workloadList.fullObjectName == "")
                        showMessage("Please choose any file or folder!")
                    else
                        pageStack.push({item: "qrc:/ViewWatermark.qml", properties: {watermark: currentWatermark.source, source: AppLogic.getFirstTargetObject()}})
                }
            }
        }

        Text {
            id: textScaleOfImage
            width: chooseWatermarkButton.width
            text: "Scale image(s) to"
            color: "white"
            font.bold: true
            font.pixelSize: chooseWatermarkButton.fontPixelSize
        }

        P4U_Slider {
            id: sliderScaleOfImage
            width: workloadList.width
            height: textScaleOfImage.height

            onValueChanged: AppLogic.setImageScale(value)
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
                if(workloadList.text == "")
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

    Component {
        id: chooseFileFolderBrowser

        FileBrowser {
            bMultiSelect: true
            onProcessWorklist: AppLogic.setWorklist(worklist)
        }
    }

    Component {
        id: chooseWatermarkBrowser

        FileBrowser {
            bMultiSelect: false
            onProcessWorklist: AppLogic.setWatermark(worklist)
        }
    }

    function watermarkChanged(watermark) {
        currentWatermark.source = watermark
    }

    function targetObjectChanged(name) {
        workloadList.setObject(name)
    }

    function dependencyError() {
        applyWatermarkButton.enabled = false;
    }

    function imageScaleChanged(percent) {
        sliderScaleOfImage.value = percent
    }

    function setProgressValue(value) {
        progressBar.value = value
        if(progressBar.opacity == 0)
            progressBar.opacity = 1.0
    }

    function watermarkDone() {
        progressBar.opacity = 0.0
    }

    function watermarkSizeChanged(scaleXPct, scaleYPct) {

    }

    signal applyWatermark()
}
