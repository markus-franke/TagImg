import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0

Button {
    id: button
    width: 160
    height: 60
    antialiasing: true

    property int fontPixelSize : height / 4

    scale : hovered ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { easing.type: Easing.OutCubic ; duration: 120} }

    style: ButtonStyle {
        background: Rectangle {
            border.width: 2
            radius: 5
            color: "darkblue"
        }

        label: Text {
            id: button_text
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: enabled ? "white" : "gray"
            font.pixelSize: fontPixelSize
            font.bold: true
            wrapMode: Text.WordWrap
            text: button.text
        }
    }
}
