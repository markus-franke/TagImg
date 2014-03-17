import QtQuick 2.0

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    Image {
        id: sourceImage
        width: parent.width
        fillMode: Image.PreserveAspectFit
        anchors { top: parent.top; topMargin: 5 }

        DropArea {
            anchors.fill: parent

            onPositionChanged: {
                //if(drag.y < sourceImage.y)
                //console.log(drag.y)
            }
            onDropped: {
                console.log("dropped")
            }
        }

        Image {
            id: watermarkImage

            property bool bResizeWatermark : false

            height: parent.paintedHeight / 2
            fillMode: Image.PreserveAspectFit
            opacity: 0.5

            Drag.active: watermarkArea.drag.active

            MouseArea {
                id: watermarkArea
                anchors.fill: parent
                drag.target: parent
                drag.minimumY: 0
                drag.maximumY: sourceImage.height - parent.height
                drag.minimumX: 0
                drag.maximumX: sourceImage.width - parent.width
            }
        }


//        MouseArea {
//            id: sourceArea
//            anchors.fill: parent
//            hoverEnabled: true
//            acceptedButtons: Qt.LeftButton
//            property int oldMouseY;
//
//            onPositionChanged: {
//                console.log("pos: ", mouse.x, " ", mouse.y)
//                if(mouse.buttons == 0)
//                {
//                    if(mouse.y <= 5 || mouse.y > parent.height - 5) {
//                        cursorShape = Qt.SizeVerCursor
//                        watermarkImage.bResizeWatermark = true
//                        watermarkImage.oldMouseY = mouse.y
//                    }
//                    else if(mouse.x <= 5 || mouse.x > parent.width - 5) {
//                        cursorShape = Qt.SizeHorCursor
//                        watermarkImage.bResizeWatermark = true
//                    }
//                    else {
//                        cursorShape = Qt.SizeAllCursor
//                        watermarkImage.bResizeWatermark = false
//                    }
//                }
//                else if(pressed && watermarkImage.bResizeWatermark)
//                {
//                    if(mouse.y <= sourceImage.height)
//                    {
//                        parent.height += mouse.y - watermarkImage.oldMouseY
//                        console.log("resize", mouse.y - watermarkImage.oldMouseY)
//                        watermarkImage.oldMouseY = mouse.y
//                    }
//                }
//            }
//        }
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
        onClicked: pageStack.pop()
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }
    }
}
