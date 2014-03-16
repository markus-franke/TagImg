import QtQuick 2.0

Item {
    id: sliderComponent
    width: 150
    height: 20

    property alias color: valueText.color
    property alias font: valueText.font
    property int currentValue : 50

    Row {
        Rectangle {
            id: slider
            width: sliderComponent.width - valueItem.width - valueItem.anchors.leftMargin
            height: sliderComponent.height
            color: "transparent"
            focus: true

            Rectangle {
                id: scale
                height: 2
                width: parent.width - sliderHandle.width / 2
                color: "white"
                anchors.centerIn: parent
            }

            Image {
                id: sliderHandle
                source: "qrc:///icons/SliderHandle.png"
                fillMode: Image.PreserveAspectFit
                height: parent.height
                x: Math.max(0, (parent.width * currentValue / 100 - width/2))

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: "OutExpo"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onMouseXChanged: valueChanged(mouseX / width * 100)
            }

            Keys.onRightPressed: { console.log("right"); valueChanged(currentValue + 1) }
            Keys.onLeftPressed: valueChanged(currentValue - 1)
        }

        Item {
            id: valueItem
            width: 50
            height: slider.height
            Text {
                id: valueText
                anchors.fill: parent
                horizontalAlignment: Qt.AlignRight
                text: currentValue + "%"
            }
        }
    }
    signal valueChanged(int value)
}
