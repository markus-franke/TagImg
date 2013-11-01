import QtQuick 2.0

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    anchors.fill: parent

    Image {
        id: sourceImage
        width: parent.width
        fillMode: Image.PreserveAspectFit
        anchors { top: parent.top; topMargin: 5 }

        Image {
            id: watermarkImage

            property bool bMoveWatermark : false

            height: parent.paintedHeight / 2
            fillMode: Image.PreserveAspectFit
            opacity: 0.5

            MouseArea {
                id: watermarkArea
                anchors.fill: parent

                onPositionChanged: {
                    if(mouse.y <= sourceImage.height)
                    {
                        if(parent.bMoveWatermark) {
                            parent.x = mouse.x
                            parent.y = mouse.y
                        }
                        else {
                            cursorShape = Qt.SizeBDiagCursor
                            parent.height = mouse.y
                        }
                    }
                }

                onPressAndHold: {
                    cursorShape = Qt.SizeAllCursor
                    parent.bMoveWatermark = true
                }

                onReleased: {
                    cursorShape = Qt.ArrowCursor
                    parent.bMoveWatermark = false
                }
            }
        }
    }

    P4U_Slider {
        width: parent.width
        anchors { bottom: okButton.top; bottomMargin: 10 }
        currentValue: watermarkImage.opacity * 100
        onValueChanged: {
            watermarkImage.opacity = value/100.0
        }
    }

    P4U_Button {
        id: okButton
        text: "Ok"
        onClicked: hide()
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }
    }
}
