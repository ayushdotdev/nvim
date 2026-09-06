import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"
import "./components"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar

                required property var modelData
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                implicitHeight: Theme.barHeight + 8
                exclusiveZone: Theme.barHeight + 8
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "quickshell-bar"

                // Floating glassmorphism bar container
                Rectangle {
                    id: barBackground
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                        topMargin: 6
                        bottomMargin: 2
                    }

                    radius: Theme.radiusBar
                    color: Theme.bgAlpha

                    border {
                        width: 1
                        color: Theme.border
                    }

                    // Inner delicate border for refined depth
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: Theme.radiusBar - 1
                        color: "transparent"
                        border {
                            width: 1
                            color: "#12d5c6a5"
                        }
                    }

                    // ─────────────────────────────────────────────────────
                    // LEFT REGION: Launcher, Workspaces, Window Title
                    // ─────────────────────────────────────────────────────
                    RowLayout {
                        id: leftRegion
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 8

                        // Application Launcher Button
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: Theme.capsuleHeight
                            radius: Theme.radiusPill
                            color: launcherMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
                            border {
                                width: 1
                                color: launcherMouse.containsMouse ? Theme.yellow : Theme.border
                            }

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰣇"
                                color: launcherMouse.containsMouse ? Theme.yellow : Theme.fgBright
                                font {
                                    family: Theme.fontMono
                                    pixelSize: Theme.iconSizeMd
                                }
                            }

                            MouseArea {
                                id: launcherMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Quickshell.execDetached(["wofi", "--show", "drun"]);
                                }
                            }
                        }

                        // Hyprland Workspaces
                        Workspaces {}

                        // Active Window Title
                        WindowTitle {}
                    }

                    // ─────────────────────────────────────────────────────
                    // CENTER REGION: Clock & Interactive Calendar
                    // ─────────────────────────────────────────────────────
                    ClockWidget {
                        anchors.centerIn: parent
                        barWindow: bar
                    }

                    // ─────────────────────────────────────────────────────
                    // RIGHT REGION: Media, Stats, Controls, Tray, Power
                    // ─────────────────────────────────────────────────────
                    RowLayout {
                        id: rightRegion
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 6

                        // MPRIS Media Player
                        MprisPlayer {}

                        // System Stats (CPU & RAM)
                        SystemStats {
                            barWindow: bar
                        }

                        // Brightness
                        BrightnessWidget {
                            barWindow: bar
                        }

                        // Volume
                        VolumeWidget {
                            barWindow: bar
                        }

                        // Network
                        NetworkWidget {
                            barWindow: bar
                        }

                        // Bluetooth
                        BluetoothWidget {
                            barWindow: bar
                        }

                        // Battery
                        BatteryWidget {
                            barWindow: bar
                        }

                        // SwayNC Notifications
                        NotificationsWidget {}

                        // System Tray
                        SystemTrayWidget {}

                        // Power Menu
                        PowerMenuWidget {
                            barWindow: bar
                        }
                    }
                }
            }
        }
    }
}
