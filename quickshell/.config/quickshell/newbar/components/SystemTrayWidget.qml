import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../theme"

Rectangle {
    id: root

    readonly property bool hasItems: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0

    visible: hasItems
    implicitHeight: Theme.capsuleHeight
    implicitWidth: hasItems ? trayRow.implicitWidth + 12 : 0
    radius: Theme.radiusPill
    color: Theme.bgAlt
    border {
        width: 1
        color: Theme.border
    }

    Behavior on implicitWidth {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: itemContainer
                required property var modelData

                implicitWidth: 20
                implicitHeight: 20
                radius: 4
                color: itemMouse.containsMouse ? Theme.bgLight : "transparent"

                IconImage {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: itemContainer.modelData.icon
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: itemContainer.modelData.menu
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton) {
                            menuAnchor.open();
                        } else {
                            itemContainer.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
