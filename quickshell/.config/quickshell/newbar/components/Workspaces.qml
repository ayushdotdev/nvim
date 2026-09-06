import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root

    implicitHeight: Theme.capsuleHeight
    implicitWidth: wsRow.implicitWidth + 12
    radius: Theme.radiusPill
    color: Theme.bgAlt
    border {
        width: 1
        color: Theme.border
    }

    // Helper to find a workspace object by ID
    function getWorkspace(id) {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return null;
        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            var ws = Hyprland.workspaces.values[i];
            if (ws && ws.id === id) return ws;
        }
        return null;
    }

    // Determine the list of workspaces to display (at least 1..5)
    readonly property var workspaceIds: {
        var maxId = 5;
        if (Hyprland.workspaces && Hyprland.workspaces.values) {
            for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                var w = Hyprland.workspaces.values[i];
                if (w && w.id > maxId) maxId = w.id;
            }
        }
        var res = [];
        for (var n = 1; n <= Math.min(maxId, 10); n++) {
            res.push(n);
        }
        return res;
    }

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.workspaceIds

            delegate: Rectangle {
                id: wsButton
                required property int modelData

                readonly property var wsObj: root.getWorkspace(modelData)
                readonly property bool isActive: wsObj ? (wsObj.active || wsObj.focused) : false
                readonly property bool isUrgent: wsObj ? wsObj.urgent : false
                readonly property bool hasWindows: wsObj ? (wsObj.toplevels && wsObj.toplevels.values && wsObj.toplevels.values.length > 0) : false

                implicitHeight: 22
                // Active workspace pill expands for a sleek look
                implicitWidth: isActive ? 34 : (hasWindows ? 24 : 22)
                radius: 6

                color: {
                    if (isUrgent) return Theme.red;
                    if (isActive) return Theme.yellow;
                    if (wsMouse.containsMouse) return Theme.bgLight;
                    if (hasWindows) return Theme.bgSubtle;
                    return "transparent";
                }

                border {
                    width: 1
                    color: {
                        if (isUrgent) return Theme.red;
                        if (isActive) return Theme.yellowDim;
                        if (wsMouse.containsMouse) return Theme.borderHover;
                        if (hasWindows) return Theme.borderSubtle;
                        return "transparent";
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        text: wsButton.modelData
                        font {
                            family: Theme.fontMono
                            pixelSize: Theme.fontSizeRegular
                            weight: wsButton.isActive ? Font.Bold : (wsButton.hasWindows ? Font.Medium : Font.Normal)
                        }
                        color: {
                            if (wsButton.isUrgent) return Theme.fgBright;
                            if (wsButton.isActive) return Theme.bg; // Contrast on yellow pill
                            if (wsButton.hasWindows) return Theme.fgBright;
                            return Theme.fgMuted;
                        }
                    }

                    // Active dot indicator inside the expanded pill
                    Rectangle {
                        visible: wsButton.isActive
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.bg
                    }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (wsButton.wsObj) {
                            wsButton.wsObj.activate();
                        } else {
                            Hyprland.dispatch("workspace " + wsButton.modelData);
                        }
                    }
                }
            }
        }
    }

    // Scroll wheel on the entire workspace bar cycles workspaces
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.NoButton
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                Hyprland.dispatch("workspace e-1");
            } else if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("workspace e+1");
            }
        }
    }
}
