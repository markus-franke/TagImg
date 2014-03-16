import QtQuick 2.0

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
            onClicked: pageStack.push({item: "qrc:/FileBrowser.qml", properties: {bMultiSelect: true}})
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

            onClicked: pageStack.push({item: "qrc:/FileBrowser.qml", properties: {bMultiSelect: false}})
        }

        Image {
            id: currentWatermark
            height: chooseWatermarkButton.height
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                onClicked: pageStack.push({item: "qrc:/ViewWatermark.qml", properties: {watermark: currentWatermark.source, source: workloadList.fullObjectName}})
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
}
