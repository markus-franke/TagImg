import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    ColumnLayout {
        spacing: 20
        anchors { margins: 10; left: parent.left; right: parent.right }

        Item {
            Layout.fillWidth: true
            //height: 100

            Image {
                id: sourceImage
                fillMode: Image.PreserveAspectFit
                anchors { horizontalCenter: parent.horizontalCenter; fill: parent }

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

            P4U_Label {
                text: "Opacity"
                font.pixelSize: okButton.fontPixelSize
            }

            P4U_Slider {
                id: sliderOpacity
                Layout.fillWidth: true
                value: AppLogic.getWatermarkOpacity();
                fontPixelSize: okButton.fontPixelSize
                onValueChanged: {
                    AppLogic.setWatermarkOpacity(value)
                    watermarkImage.opacity=AppLogic.getWatermarkOpacity() / 100;
                }
            }

            P4U_Label {
                text: "Scale"
                font.pixelSize: okButton.fontPixelSize
            }

            P4U_Slider {
                id: sliderScale
                Layout.fillWidth: true
                value: AppLogic.getWatermarkSizePct();
                fontPixelSize: okButton.fontPixelSize
                onValueChanged: {
                    AppLogic.setWatermarkSize(value, value)
                    if(sourceImage.paintedWidth != 0)
                        watermarkImage.width=AppLogic.getWatermarkSize(sourceImage.paintedWidth);
                }
            }
        }

        P4U_Button {
            id: okButton
            Layout.preferredWidth: width
            Layout.preferredHeight: height
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
