import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: root

    required property var barWindow

    implicitHeight: Theme.capsuleHeight
    implicitWidth: statsCapsule.implicitWidth

    // Parsed properties
    property int cpuPercent: 0
    property int memPercent: 0
    property string memUsedGb: "0.0"
    property string memTotalGb: "0.0"
    property string diskUsed: "0"
    property string diskTotal: "0"
    property string diskPercent: "0%"

    Process {
        id: statsProc
        command: ["bash", "-c", "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{printf(\"%.0f\", $2 + $4)}'); mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf(\"%.0f:%.1f:%.1f\", (t-a)/t*100, (t-a)/1048576, t/1048576)}' /proc/meminfo); disk=$(df -h / | awk 'NR==2 {printf(\"%s:%s:%s\", $3, $2, $5)}'); echo \"$cpu|$mem|$disk\""]
        running: true
        stdout: StdioCollector {
            onDataChanged: {
                try {
                    var parts = text.trim().split("|");
                    if (parts.length >= 3) {
                        root.cpuPercent = parseInt(parts[0]) || 0;
                        var m = parts[1].split(":");
                        if (m.length >= 3) {
                            root.memPercent = parseInt(m[0]) || 0;
                            root.memUsedGb = m[1];
                            root.memTotalGb = m[2];
                        }
                        var d = parts[2].split(":");
                        if (d.length >= 3) {
                            root.diskUsed = d[0];
                            root.diskTotal = d[1];
                            root.diskPercent = d[2];
                        }
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: statsProc.running = true
    }

    // Status bar capsule
    Rectangle {
        id: statsCapsule
        anchors.fill: parent
        radius: Theme.radiusPill
        color: statsMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
        border {
            width: 1
            color: sysPopup.visible ? Theme.borderFocus : (statsMouse.containsMouse ? Theme.borderHover : Theme.border)
        }

        implicitWidth: statsRow.implicitWidth + 16
        implicitHeight: Theme.capsuleHeight

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            id: statsRow
            anchors.centerIn: parent
            spacing: 8

            // CPU
            RowLayout {
                spacing: 4

                Text {
                    text: "󰍛"
                    color: root.cpuPercent > 80 ? Theme.red : (root.cpuPercent > 50 ? Theme.yellow : Theme.aqua)
                    font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }
                }

                Text {
                    text: root.cpuPercent + "%"
                    color: Theme.fg
                    font {
                        family: Theme.fontMono
                        pixelSize: Theme.fontSizeSm
                        weight: Font.Medium
                    }
                }
            }

            Rectangle {
                width: 1
                height: 10
                color: Theme.borderSubtle
            }

            // RAM
            RowLayout {
                spacing: 4

                Text {
                    text: "󰘚"
                    color: root.memPercent > 80 ? Theme.red : (root.memPercent > 60 ? Theme.yellow : Theme.accent)
                    font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }
                }

                Text {
                    text: root.memUsedGb + "G"
                    color: Theme.fg
                    font {
                        family: Theme.fontMono
                        pixelSize: Theme.fontSizeSm
                        weight: Font.Medium
                    }
                }
            }
        }

        MouseArea {
            id: statsMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                sysPopup.visible = !sysPopup.visible;
                if (sysPopup.visible) statsProc.running = true;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // SYSTEM MONITOR POPUP
    // ─────────────────────────────────────────────────────────────
    PopupWindow {
        id: sysPopup

        anchor.window: root.barWindow
        anchor.rect.x: Math.round(Math.max(12, Math.min(root.barWindow.width - width - 12, root.mapToItem(null, 0, 0).x + root.width / 2 - width / 2)))
        anchor.rect.y: root.barWindow.height + 2

        implicitWidth: 280
        implicitHeight: 250
        color: "transparent"
        visible: false
        grabFocus: true

        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusPopup
            color: Theme.bgCard
            border {
                width: 1
                color: Theme.borderFocus
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "󰍛 System Resources"
                        color: Theme.fgBright
                        font {
                            family: Theme.fontMono
                            pixelSize: Theme.fontSizeMd
                            weight: Font.Bold
                        }
                        Layout.fillWidth: true
                    }

                    // Open btop
                    Rectangle {
                        implicitWidth: 48
                        implicitHeight: 22
                        radius: 6
                        color: btopMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
                        border { width: 1; color: Theme.border }

                        Text {
                            anchors.centerIn: parent
                            text: "btop"
                            color: Theme.yellow
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs; weight: Font.Bold }
                        }

                        MouseArea {
                            id: btopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["kitty", "-e", "btop"]);
                                sysPopup.visible = false;
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.borderSubtle
                }

                // CPU Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Processor"
                            color: Theme.fgMuted
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm }
                        }
                        Text {
                            text: root.cpuPercent + "%"
                            color: Theme.fgBright
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm; weight: Font.Bold }
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.bgLight

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: parent.width * Math.min(1.0, root.cpuPercent / 100.0)
                            radius: 3
                            color: root.cpuPercent > 80 ? Theme.red : (root.cpuPercent > 50 ? Theme.yellow : Theme.aqua)
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }

                // RAM Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Memory (" + root.memUsedGb + " / " + root.memTotalGb + " GB)"
                            color: Theme.fgMuted
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm }
                        }
                        Text {
                            text: root.memPercent + "%"
                            color: Theme.fgBright
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm; weight: Font.Bold }
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.bgLight

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: parent.width * Math.min(1.0, root.memPercent / 100.0)
                            radius: 3
                            color: root.memPercent > 80 ? Theme.red : (root.memPercent > 60 ? Theme.yellow : Theme.accent)
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }

                // Disk Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Storage / (" + root.diskUsed + " / " + root.diskTotal + ")"
                            color: Theme.fgMuted
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm }
                        }
                        Text {
                            text: root.diskPercent
                            color: Theme.fgBright
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm; weight: Font.Bold }
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.bgLight

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: parent.width * Math.min(1.0, (parseInt(root.diskPercent) || 0) / 100.0)
                            radius: 3
                            color: Theme.green
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }
    }
}
