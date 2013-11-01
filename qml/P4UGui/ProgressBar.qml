import QtQuick 2.0

Item {
    id: progressbar

    property int minimum: 0
    property int maximum: 100
    property int value: 0
    property color color: "#77B753"

    width: 250; height: 23
    clip: true

    Rectangle {
        id: border
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: parent.color
        radius: 5
    }

    Rectangle {
        id: highlight
        property int widthDest: ( ( progressbar.width * ( value - minimum ) ) / ( maximum - minimum ) - anchors.leftMargin - anchors.rightMargin )
        width: highlight.widthDest
        radius: border.radius

        Behavior on width {
            SmoothedAnimation {
                velocity: 1200
            }
        }

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 2
        }
        color: parent.color
    }
}
