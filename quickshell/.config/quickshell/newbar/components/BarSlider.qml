import QtQuick
import "../theme"

Item {
    id: slider

    property real value: 0.5            // 0.0 to 1.0
    property real minimumValue: 0.0
    property real maximumValue: 1.0
    property color activeColor: Theme.yellow
    property color trackColor: Theme.bgLight
    property int trackHeight: 6
    property bool pressed: sliderMouse.pressed

    signal moved(real val)

    implicitHeight: 24
    implicitWidth: 160

    Rectangle {
        id: track
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: slider.trackHeight
        radius: height / 2
        color: slider.trackColor

        Rectangle {
            id: fill
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: Math.max(0, Math.min(track.width, ((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)) * track.width))
            radius: height / 2
            color: slider.activeColor
        }
    }

    Rectangle {
        id: handle
        x: fill.width - width / 2
        anchors.verticalCenter: track.verticalCenter
        width: sliderMouse.pressed ? 16 : (sliderMouse.containsMouse ? 14 : 12)
        height: width
        radius: width / 2
        color: Theme.fgBright
        border {
            width: 1
            color: Theme.accent
        }

        Behavior on width {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        id: sliderMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateValue(mouseX) {
            var ratio = Math.max(0, Math.min(1, mouseX / width));
            var newVal = slider.minimumValue + ratio * (slider.maximumValue - slider.minimumValue);
            slider.value = newVal;
            slider.moved(newVal);
        }

        onPositionChanged: function(mouse) {
            if (pressed) {
                updateValue(mouse.x);
            }
        }

        onPressed: function(mouse) {
            updateValue(mouse.x);
        }
    }
}
