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
        anchors.margins: 10

        Image {
            id: sourceImage
            height: parent.height * 0.6
            fillMode: Image.PreserveAspectFit
            anchors { horizontalCenter: parent.horizontalCenter; }

            DropArea {
                anchors.fill: parent
            }

            Image {
                id: watermarkImage
                x: AppLogic.getWatermarkPosX(parent.width - width)
                y: AppLogic.getWatermarkPosY(parent.height - height)
                width: AppLogic.getWatermarkSize(parent.width);

    //            property bool bResizeWatermarkVert : false
    //            property bool bResizeWatermarkHoriz: false
    //            property int oldMousePos;

                fillMode: Image.PreserveAspectFit
                opacity: AppLogic.getWatermarkOpacity() / 100.0

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

        GridLayout {
            rows: 2
            columns: 2
            width: parent.width

            Text {
                text: "Opacity"
                color: "white"
                font.bold: true
            }

            P4U_Slider {
                id: sliderOpacity
                Layout.fillWidth: true
                value: AppLogic.getWatermarkOpacity();
                onValueChanged: {
                    AppLogic.setWatermarkOpacity(value)
                    watermarkImage.opacity=AppLogic.getWatermarkOpacity() / 100;
                }
            }

            Text {
                text: "Scale"
                color: "white"
                font.bold: true
            }

            P4U_Slider {
                id: sliderScale
                Layout.fillWidth: true
                value: AppLogic.getWatermarkSizePct();
                onValueChanged: {
                    AppLogic.setWatermarkSize(value, value)
                    if(sourceImage.paintedWidth != 0)
                        watermarkImage.width=AppLogic.getWatermarkSize(sourceImage.paintedWidth);
                }
            }
        }

        P4U_Button {
            id: okButton
            text: "Ok"
            onClicked: {
                //console.log("x: ", watermarkImage.x, ", y: ", watermarkImage.y)
                var setX = Math.round(watermarkImage.x * 100 / (sourceImage.width - watermarkImage.width))
                var setY = Math.round(watermarkImage.y * 100 / (sourceImage.height - watermarkImage.height))
                //console.log("setX: ", setX, ", setY: ", setY)
                AppLogic.setWatermarkPos(setX, setY)
                pageStack.pop()
            }
            anchors { horizontalCenter: parent.horizontalCenter }
        }
    }

    Component.onCompleted: console.log('source image is: ', sourceImage.source)

    function watermarkSizeChanged(scaleXPct, scaleYPct) {

    }
}
