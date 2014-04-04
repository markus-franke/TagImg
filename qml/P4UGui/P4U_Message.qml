import QtQuick 2.2
import QtQuick.Layouts 1.1

Rectangle {
    id: messageBox

    property alias message: messageText.text

    anchors.centerIn: parent
    color: "lightblue"
    radius: 5
    border.width: 2
    visible: false
    width: parent.width * 0.75
    height: parent.height * 0.5

    ColumnLayout {

        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        P4U_Label {
            id: messageText
            font { pixelSize: height / 4 }
            color: "black"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        P4U_Button {
            id: okButton
            text: "Ok"
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.preferredWidth: width
            Layout.preferredHeight: height
            onClicked: closeAnimation.start()
        }
    }

    ParallelAnimation {
        id: openAnimation

        PropertyAnimation {
            id: widthAnimation;
            target: messageBox;
            property: "width";
            from: 0;
            to: parent.width * 0.8;
            duration: 200;
            easing.type: Easing.OutQuad
        }

        PropertyAnimation {
            id: heightAnimation;
            target: messageBox;
            property: "height";
            from: 0;
            to: 150
            duration: 200;
            easing.type: Easing.OutQuad
        }
    }

    PropertyAnimation {
        id: closeAnimation
        target: messageBox;
        property: "opacity"
        from: 1.0
        to: 0.0
        duration: 300
    }

    onVisibleChanged: {
        if(visible) {
            messageBox.opacity = 1.0
            openAnimation.start()
        }
    }

    onOpacityChanged: {
        if(opacity == 0)
            messageBox.visible = false
    }
}
