import QtQuick 2.0

Rectangle {
    id: page
    visible: false

    NumberAnimation on opacity {
        id: showAnimation
        from: 0
        to: 1
        duration: 250
        running: false
    }

    NumberAnimation on opacity {
        id: hideAnimation
        from: 1
        to: 0
        duration: 250
        running: false
    }

    NumberAnimation on x {
        id: showAnimation2
        from: width
        to: 0
        duration: 1500
        easing.type: Easing.OutBounce
        running: false
    }

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: "darkblue"
        }
        GradientStop {
            position: 1.0;
            color: "lightblue"
        }
    }

    function show() {
        showAnimation.start()
    }

    function hide() {
        hideAnimation.start()
    }

    onOpacityChanged: visible = opacity > 0 ? true : false
}
