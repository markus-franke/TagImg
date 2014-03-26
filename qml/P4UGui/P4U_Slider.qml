import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Slider {
    id: sliderComponent
    minimumValue: 0
    maximumValue: 100
    stepSize: 1
    focus: true

    style: SliderStyle {
        handle: Image {
            id: sliderHandle
            source: "qrc:///icons/SliderHandle.png"
            fillMode: Image.PreserveAspectFit
        }
    }
}
