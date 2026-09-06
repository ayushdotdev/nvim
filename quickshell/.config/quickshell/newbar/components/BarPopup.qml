import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

PopupWindow {
    id: popup

    default property alias content: popupContent.data
    property alias contentLayout: popupContent

    property int popupWidth: 320
    property int popupHeight: 380

    implicitWidth: popupWidth
    implicitHeight: popupHeight

    color: "transparent"
    visible: false
    grabFocus: true

    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: Theme.radiusPopup
        color: Theme.bgCard

        border {
            width: 1
            color: Theme.borderFocus
        }

        // Inner subtle rim highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.radiusPopup - 1
            color: "transparent"
            border {
                width: 1
                color: "#15d5c6a5"
            }
        }

        Item {
            id: popupContent
            anchors {
                fill: parent
                margins: 16
            }
        }
    }
}
