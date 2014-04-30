import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

Item {
    id: rootItem
    property alias value : sliderComponent.value
    property alias maximumValue: sliderComponent.maximumValue
    property int fontPixelSize

    RowLayout {
        spacing: 10
        anchors.left: parent.left
        anchors.right: parent.right

        Slider {
            id: sliderComponent
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            Layout.fillWidth: true
            focus: true

            style: SliderStyle {
                handle: Image {
                    id: sliderHandle
                    source: "qrc:///icons/SliderHandle.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        P4U_Label {
            id: valueText
            Layout.minimumWidth: 40
            text: {
                var val = sliderComponent.value
                if(val < 10) val = ' ' + val
                if(val < 100) val = ' ' + val
                val = val + '%'
                return val
            }
            font.pixelSize: rootItem.fontPixelSize
        }
    }
}
