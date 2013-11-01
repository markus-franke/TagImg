import QtQuick 2.0

Rectangle {
    id: messageBox

    property alias message: messageText.text

    width: 0
    height: 0
    anchors.centerIn: parent
    color: "lightblue"
    radius: 5
    border.width: 2

    Text {
        id: messageText
        font { bold: true; pixelSize: 15 }
        color: "black"
        width: parent.width
        anchors { top: parent.top; left: parent.left; margins: 5 }
        wrapMode: Text.Wrap
    }

    P4U_Button {
        id: okButton
        text: "Ok"
        onClicked: closeAnimation.start()
        anchors { bottom: parent.bottom; bottomMargin: 10; horizontalCenter: parent.horizontalCenter }
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
