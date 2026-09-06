import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../theme"

Item {
    id: root

    required property var barWindow

    implicitHeight: Theme.capsuleHeight
    implicitWidth: batCapsule.implicitWidth

    readonly property var dev: UPower.displayDevice
    readonly property int percentage: dev ? Math.round(dev.percentage * 100) : 100
    readonly property bool isCharging: dev ? (dev.state === UPowerDeviceState.Charging) : false
    readonly property bool isLow: percentage <= 20 && !isCharging

    readonly property string batteryIcon: {
        if (isCharging) return "󰂄";
        if (percentage >= 90) return "󰁹";
        if (percentage >= 70) return "󰂂";
        if (percentage >= 50) return "󰁿";
        if (percentage >= 30) return "󰁾";
        if (percentage >= 15) return "󰁼";
        return "󰂎";
    }

    // Status bar capsule
    Rectangle {
        id: batCapsule
        anchors.fill: parent
        radius: Theme.radiusPill
        color: batMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
        border {
            width: 1
            color: batPopup.visible ? Theme.borderFocus : (root.isLow ? Theme.red : (batMouse.containsMouse ? Theme.borderHover : Theme.border))
        }

        implicitWidth: batRow.implicitWidth + 16
        implicitHeight: Theme.capsuleHeight

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            id: batRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.batteryIcon
                color: root.isCharging ? Theme.green : (root.isLow ? Theme.red : Theme.fg)
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.iconSizeSm
                }
            }

            Text {
                text: root.percentage + "%"
                color: root.isLow ? Theme.red : Theme.fg
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.fontSizeSm
                    weight: Font.Medium
                }
            }
        }

        MouseArea {
            id: batMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                batPopup.visible = !batPopup.visible;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // BATTERY DETAILS POPUP
    // ─────────────────────────────────────────────────────────────
    PopupWindow {
        id: batPopup

        anchor.window: root.barWindow
        anchor.rect.x: Math.round(Math.max(12, Math.min(root.barWindow.width - width - 12, root.mapToItem(null, 0, 0).x + root.width / 2 - width / 2)))
        anchor.rect.y: root.barWindow.height + 2

        implicitWidth: 260
        implicitHeight: 210
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

                Text {
                    text: "󰂄 Battery & Power"
                    color: Theme.fgBright
                    font {
                        family: Theme.fontMono
                        pixelSize: Theme.fontSizeMd
                        weight: Font.Bold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.borderSubtle
                }

                // Status & Percent
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.batteryIcon
                        color: root.isCharging ? Theme.green : (root.isLow ? Theme.red : Theme.yellow)
                        font { family: Theme.fontMono; pixelSize: Theme.iconSizeLg }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            text: root.percentage + "% Charged"
                            color: Theme.fgBright
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm; weight: Font.Bold }
                        }

                        Text {
                            text: {
                                if (!root.dev) return "Unknown";
                                if (root.dev.state === UPowerDeviceState.Charging) return "Charging on AC";
                                if (root.dev.state === UPowerDeviceState.FullyCharged) return "Fully Charged";
                                if (root.dev.state === UPowerDeviceState.Discharging) return "Running on Battery";
                                return "Connected";
                            }
                            color: Theme.fgMuted
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs }
                        }
                    }
                }

                // Progress Bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Theme.bgLight

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: parent.width * (root.percentage / 100.0)
                        radius: 3
                        color: root.isCharging ? Theme.green : (root.isLow ? Theme.red : Theme.yellow)
                    }
                }

                // Battery Health
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.dev ? root.dev.healthSupported : false

                    Text {
                        text: "Battery Health"
                        color: Theme.fgMuted
                        font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs }
                    }

                    Text {
                        text: root.dev ? Math.round(root.dev.healthPercentage) + "%" : "N/A"
                        color: Theme.fg
                        font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs; weight: Font.Bold }
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
