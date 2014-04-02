import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    Column {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 10

        Item {
            width: parent.width
            height: parent.height * 0.55

            Image {
                id: sourceImage
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
                    }
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

    function watermarkSizeChanged(scaleXPct, scaleYPct) {

    }
}
