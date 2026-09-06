import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../theme"

Item {
    id: root

    required property var barWindow

    implicitHeight: Theme.capsuleHeight
    implicitWidth: volCapsule.implicitWidth

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0.0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false
    readonly property int volumePercent: Math.round(volume * 100)

    readonly property string volumeIcon: {
        if (muted) return "󰝟";
        if (volumePercent >= 60) return "󰕾";
        if (volumePercent >= 30) return "󰖀";
        return "󰕿";
    }

    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function changeVolume(delta) {
        if (sink && sink.audio) {
            var newVol = Math.max(0.0, Math.min(1.0, sink.audio.volume + delta));
            sink.audio.volume = newVol;
            if (sink.audio.muted && delta > 0) {
                sink.audio.muted = false;
            }
        }
    }

    // Status bar capsule
    Rectangle {
        id: volCapsule
        anchors.fill: parent
        radius: Theme.radiusPill
        color: volMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
        border {
            width: 1
            color: volPopup.visible ? Theme.borderFocus : (volMouse.containsMouse ? Theme.borderHover : Theme.border)
        }

        implicitWidth: volRow.implicitWidth + 16
        implicitHeight: Theme.capsuleHeight

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            id: volRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.volumeIcon
                color: root.muted ? Theme.red : Theme.aqua
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.iconSizeSm
                }
            }

            Text {
                text: root.muted ? "Muted" : root.volumePercent + "%"
                color: root.muted ? Theme.fgMuted : Theme.fg
                font {
                    family: Theme.fontMono
                    pixelSize: Theme.fontSizeSm
                    weight: Font.Medium
                }
            }
        }

        MouseArea {
            id: volMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    root.toggleMute();
                } else {
                    volPopup.visible = !volPopup.visible;
                }
            }

            onWheel: function(wheel) {
                if (wheel.angleDelta.y > 0) {
                    root.changeVolume(0.05);
                } else if (wheel.angleDelta.y < 0) {
                    root.changeVolume(-0.05);
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // VOLUME SLIDER POPUP
    // ─────────────────────────────────────────────────────────────
    PopupWindow {
        id: volPopup

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

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "󰕾 Audio Output"
                        color: Theme.fgBright
                        font {
                            family: Theme.fontMono
                            pixelSize: Theme.fontSizeMd
                            weight: Font.Bold
                        }
                        Layout.fillWidth: true
                    }

                    // Open Pavucontrol
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 24
                        radius: 6
                        color: pavuMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
                        border { width: 1; color: Theme.border }

                        Text {
                            anchors.centerIn: parent
                            text: "󰒓"
                            color: Theme.fg
                            font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }
                        }

                        MouseArea {
                            id: pavuMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["pavucontrol"]);
                                volPopup.visible = false;
                            }
                        }
                    }
                }

                // Device Description
                Text {
                    text: root.sink ? (root.sink.description || root.sink.name || "Default Output") : "No device"
                    color: Theme.fgMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    font {
                        family: Theme.fontMono
                        pixelSize: Theme.fontSizeXs
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.borderSubtle
                }

                // Volume slider row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Mute button
                    Rectangle {
                        implicitWidth: 34
                        implicitHeight: 34
                        radius: 8
                        color: root.muted ? Theme.redDim : (muteMouse.containsMouse ? Theme.bgLight : Theme.bgAlt)
                        border {
                            width: 1
                            color: root.muted ? Theme.red : Theme.border
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.volumeIcon
                            color: root.muted ? Theme.fgBright : Theme.aqua
                            font {
                                family: Theme.fontMono
                                pixelSize: Theme.iconSizeMd
                            }
                        }

                        MouseArea {
                            id: muteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleMute()
                        }
                    }

                    // Slider
                    BarSlider {
                        Layout.fillWidth: true
                        value: root.volume
                        activeColor: root.muted ? Theme.fgDark : Theme.aqua
                        onMoved: function(newVal) {
                            if (root.sink && root.sink.audio) {
                                root.sink.audio.volume = newVal;
                                if (root.sink.audio.muted && newVal > 0) {
                                    root.sink.audio.muted = false;
                                }
                            }
                        }
                    }

                    Text {
                        text: root.volumePercent + "%"
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
            }
        }
    }
}
