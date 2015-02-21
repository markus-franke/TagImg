import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

P4U_Page {
    id: viewWatermark
    property alias watermark: watermarkImage.source
    property alias source: sourceImage.source

    ColumnLayout {
        id: layout
        spacing: 20
        anchors { margins: 10; fill: parent }

        Item {
            id: container
            Layout.fillWidth: true
            Layout.fillHeight: true

            Image {
                id: sourceImage
                fillMode: Image.PreserveAspectFit
                anchors { horizontalCenter: parent.horizontalCenter }
                width: {
                    if(sourceImage.sourceSize.width > sourceImage.sourceSize.height)
                        return parent.width
                }
                height: {
                    if(sourceImage.sourceSize.width <= sourceImage.sourceSize.height)
                        return parent.height

                }
                Image {
                    id: watermarkImage
                    x: DataModel.getWatermarkPosX(parent.width - width)
                    y: DataModel.getWatermarkPosY(parent.height - height)
                    width: DataModel.getWatermarkSize(parent.width);
                    fillMode: Image.PreserveAspectFit
                    opacity: DataModel.getWatermarkOpacity() / 100.0

                    Drag.active: watermarkArea.drag.active

                    MouseArea {
                        id: watermarkArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: true

                        drag.target: parent
                        drag.minimumY: 0
                        drag.maximumY: sourceImage.paintedHeight - parent.paintedHeight
                        drag.minimumX: 0
                        drag.maximumX: sourceImage.paintedWidth - parent.paintedWidth
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
                value: DataModel.getWatermarkOpacity();
                fontPixelSize: okButton.fontPixelSize
                onValueChanged: {
                    DataModel.setWatermarkOpacity(value)
                    watermarkImage.opacity=DataModel.getWatermarkOpacity() / 100;
                }
            }

            P4U_Label {
                text: "Scale"
                font.pixelSize: okButton.fontPixelSize
            }

            P4U_Slider {
                id: sliderScale
                Layout.fillWidth: true
                value: DataModel.getWatermarkSizePct();
                //maximumValue: Math.min(sourceImage.sourceSize.width * 100 / watermarkImage.sourceSize.width, sourceImage.sourceSize.height * 100 / watermarkImage.sourceSize.height)
                fontPixelSize: okButton.fontPixelSize

                onValueChanged: {
//                    console.log(sourceImage.sourceSize.width * 100 / watermarkImage.sourceSize.width)
//                    console.log(sourceImage.sourceSize.height * 100 / watermarkImage.sourceSize.height)
                    DataModel.setWatermarkSize(value, value)
                    if(sourceImage.paintedWidth != 0)
                        watermarkImage.width=DataModel.getWatermarkSize(sourceImage.paintedWidth);
                }
            }
        }

        P4U_Button {
            id: okButton
            Layout.preferredWidth: width
            Layout.preferredHeight: height
            text: "Ok"
            onClicked: {parent
                //console.log("x: ", watermarkImage.x, ", y: ", watermarkImage.y)
                var setX = Math.round(watermarkImage.x * 100 / (sourceImage.width - watermarkImage.width))
                var setY = Math.round(watermarkImage.y * 100 / (sourceImage.height - watermarkImage.height))
                //console.log("setX: ", setX, ", setY: ", setY)
                DataModel.setWatermarkPos(setX, setY)
                pageStack.pop()
            }
            anchors { horizontalCenter: parent.horizontalCenter }
        }
    }

}
