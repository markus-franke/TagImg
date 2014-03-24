import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    Column {
        anchors.fill: parent
        spacing: 10

        Image {
            id: sourceImage
            width: parent.width * 0.8
            fillMode: Image.PreserveAspectFit
            anchors { horizontalCenter: parent.horizontalCenter }

            DropArea {
                anchors.fill: parent
            }

            Image {
                id: watermarkImage

    //            property bool bResizeWatermarkVert : false
    //            property bool bResizeWatermarkHoriz: false
    //            property int oldMousePos;

                height: parent.paintedHeight / 3
                fillMode: Image.PreserveAspectFit
                opacity: 0.5

                Drag.active: watermarkArea.drag.active

                MouseArea {
                    id: watermarkArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true

                    drag.target: parent
                    drag.minimumY: 0
                    drag.maximumY: sourceImage.height - parent.height
                    drag.minimumX: 0
                    drag.maximumX: sourceImage.width - parent.width

    //                onPositionChanged: {
    //                    //console.log("pos: ", mouse.x, " ", mouse.y)

    //                    // set mouse cursors
    //                    if(mouse.buttons == 0)
    //                    {
    //                        if(mouse.y <= 5 || mouse.y > parent.height - 5) {
    //                            cursorShape = Qt.SizeVerCursor
    //                            watermarkImage.bResizeWatermarkVert = true
    //                            watermarkImage.oldMousePos = mouse.y
    //                        }
    //                        else if(mouse.x <= 5 || mouse.x > parent.width - 5) {
    //                            cursorShape = Qt.SizeHorCursor
    //                            watermarkImage.bResizeWatermarkHoriz = true
    //                            watermarkImage.oldMousePos = mouse.x
    //                        }
    //                        else {
    //                            cursorShape = Qt.SizeAllCursor
    //                            watermarkImage.bResizeWatermarkHoriz = false
    //                            watermarkImage.bResizeWatermarkVert = false
    //                        }
    //                    }
    //                    else if(pressed && watermarkImage.bResizeWatermarkVert)
    //                    {
    //                        var resize = mouse.y - watermarkImage.oldMousePos

    //                        if(resize && mouse.y <= sourceImage.height)
    //                        {
    //                            parent.height += mouse.y - watermarkImage.oldMousePos
    //                            console.log("resize", mouse.y - watermarkImage.oldMousePos)
    //                            watermarkImage.oldMousePos = mouse.y
    //                        }
    //                    }
    //                    else if(pressed && watermarkImage.bResizeWatermarkHoriz)
    //                    {
    //                        var resize = mouse.x - watermarkImage.oldMousePos

    //                        if(resize && mouse.x <= sourceImage.width)
    //                        {
    //                            parent.width += mouse.x - watermarkImage.oldMousePos
    //                            console.log("resize", mouse.x - watermarkImage.oldMousePos)
    //                            watermarkImage.oldMousePos = mouse.x
    //                        }
    //                    }
    //                }
                }
            }
        }

        RowLayout {
            width: parent.width
            spacing: 5

            Text {
                text: "Opacity"
            }

            Slider {
                id: sliderOpacity
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                minimumValue: 0
                maximumValue: 100
                value: watermarkImage.opacity * 100
                onValueChanged: {
                    watermarkImage.opacity = value/100.0
                }
            }
        }

        RowLayout {
            width: parent.width
            spacing: 5

            Text {
                text: "Scale"
            }

            Slider {
                id: sliderScale
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                minimumValue: 0
                maximumValue: 100
                value: watermarkImage.opacity * 100
                onValueChanged: {
                    watermarkImage.opacity = value/100.0
                }
            }
        }

        P4U_Button {
            id: okButton
            text: "Ok"
            onClicked: pageStack.pop()
            anchors { horizontalCenter: parent.horizontalCenter }
        }
    }
}
