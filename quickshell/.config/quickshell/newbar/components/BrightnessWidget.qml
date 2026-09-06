import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: root

    required property var barWindow

    implicitHeight: Theme.capsuleHeight
    implicitWidth: brightCapsule.implicitWidth

    property int brightnessPercent: 50

    readonly property string brightIcon: {
        if (brightnessPercent >= 70) return "󰃠";
        if (brightnessPercent >= 35) return "󰃟";
        return "󰃞";
    }

    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onDataChanged: {
                try {
                    var parts = text.trim().split(",");
                    if (parts.length >= 4) {
                        var p = parseInt(parts[3].replace("%", ""));
                        if (!isNaN(p)) root.brightnessPercent = p;
                    }
                } catch(e) {}
            }
        }
    }

    function setBrightness(percent) {
        var p = Math.max(5, Math.min(100, Math.round(percent)));
        root.brightnessPercent = p;
        Quickshell.execDetached(["brightnessctl", "set", p + "%"]);
    }

    function changeBrightness(delta) {
        var newP = Math.max(5, Math.min(100, root.brightnessPercent + delta));
        root.brightnessPercent = newP;
        Quickshell.execDetached(["brightnessctl", "set", newP + "%"]);
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: brightProc.running = true
    }

    // Status bar capsule
    Rectangle {
        id: brightCapsule
        anchors.fill: parent
        radius: Theme.radiusPill
        color: brightMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
        border {
            width: 1
            color: brightPopup.visible ? Theme.borderFocus : (brightMouse.containsMouse ? Theme.borderHover : Theme.border)
        }

        implicitWidth: brightRow.implicitWidth + 16
        implicitHeight: Theme.capsuleHeight

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            id: brightRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.brightIcon
                color: Theme.yellow
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.iconSizeSm
                }
            }

            Text {
                text: root.brightnessPercent + "%"
                color: Theme.fg
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.fontSizeSm
                    weight: Font.Medium
                }
            }
        }

        MouseArea {
            id: brightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                brightPopup.visible = !brightPopup.visible;
                if (brightPopup.visible) brightProc.running = true;
            }

            onWheel: function(wheel) {
                if (wheel.angleDelta.y > 0) {
                    root.changeBrightness(5);
                } else if (wheel.angleDelta.y < 0) {
                    root.changeBrightness(-5);
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // BRIGHTNESS SLIDER POPUP
    // ─────────────────────────────────────────────────────────────
    PopupWindow {
        id: brightPopup

        anchor.window: root.barWindow
        anchor.rect.x: Math.round(Math.max(12, Math.min(root.barWindow.width - width - 12, root.mapToItem(null, 0, 0).x + root.width / 2 - width / 2)))
        anchor.rect.y: root.barWindow.height + 2

        implicitWidth: 260
        implicitHeight: 180
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
                    text: "󰃠 Display Backlight"
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

                // Slider Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: root.brightIcon
                        color: Theme.yellow
                        font { family: Theme.fontMono; pixelSize: Theme.iconSizeMd }
                    }

                    BarSlider {
                        Layout.fillWidth: true
                        value: root.brightnessPercent / 100.0
                        activeColor: Theme.yellow
                        onMoved: function(newVal) {
                            root.setBrightness(newVal * 100);
                        }
                    }

                    Text {
                        text: root.brightnessPercent + "%"
                        color: Theme.fgBright
                        font {
                            family: Theme.fontMono
                            pixelSize: Theme.fontSizeSm
                            weight: Font.Bold
                        }
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Quick presets (25%, 50%, 75%, 100%)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [25, 50, 75, 100]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 26
                            radius: 6
                            required property int modelData

                            color: pMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
                            border { width: 1; color: Theme.border }

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData + "%"
                                color: Theme.fg
                                font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs; weight: Font.Medium }
                            }

                            MouseArea {
                                id: pMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setBrightness(parent.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
