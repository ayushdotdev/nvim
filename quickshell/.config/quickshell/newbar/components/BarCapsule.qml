import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: capsule

    default property alias content: contentContainer.data
    property alias contentLayout: contentContainer

    property bool clickable: false
    property bool hoverEnabled: true
    property bool active: false
    property color customBg: "transparent"
    property color customBorder: "transparent"
    property int customRadius: Theme.radiusPill
    property string tooltipText: ""

    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal scrolled(int angleDelta)

    implicitHeight: Theme.capsuleHeight
    implicitWidth: contentContainer.implicitWidth + 16

    radius: customRadius

    color: {
        if (customBg !== "transparent") return customBg;
        if (active) return Theme.bgLighter;
        if (clickable && mouseArea.containsMouse) return Theme.bgLight;
        return Theme.bgAlt;
    }

    border {
        width: 1
        color: {
            if (customBorder !== "transparent") return customBorder;
            if (active) return Theme.borderFocus;
            if (clickable && mouseArea.containsMouse) return Theme.borderHover;
            return Theme.border;
        }
    }

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    RowLayout {
        id: contentContainer
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: capsule.hoverEnabled
        cursorShape: capsule.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                capsule.clicked(mouse);
            } else if (mouse.button === Qt.RightButton) {
                capsule.rightClicked(mouse);
            }
        }

        onWheel: function(wheel) {
            capsule.scrolled(wheel.angleDelta.y);
        }
    }
}
