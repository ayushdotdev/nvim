import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: root

    required property var barWindow

    implicitHeight: Theme.capsuleHeight
    implicitWidth: netCapsule.implicitWidth

    // ─────────────────────────────────────────────────────────────
    // STATE
    // ─────────────────────────────────────────────────────────────
    property bool isConnected: false
    property bool isWifi: false
    property bool isEthernet: false
    property string ssid: ""
    property int signalPercent: 0
    property string ipAddress: ""
    property bool isScanning: false
    property var networks: []

    readonly property string netIcon: {
        if (isEthernet) return "󰈀";
        if (!isConnected) return "󰤮";
        if (signalPercent >= 80) return "󰤨";
        if (signalPercent >= 60) return "󰤥";
        if (signalPercent >= 40) return "󰤢";
        if (signalPercent >= 20) return "󰤟";
        return "󰤯";
    }

    function signalIcon(sig) {
        if (sig >= 80) return "󰤨";
        if (sig >= 60) return "󰤥";
        if (sig >= 40) return "󰤢";
        if (sig >= 20) return "󰤟";
        return "󰤯";
    }

    function signalColor(sig) {
        if (sig >= 60) return Theme.green;
        if (sig >= 35) return Theme.yellow;
        return Theme.red;
    }

    // ─────────────────────────────────────────────────────────────
    // STATUS POLLER
    // ─────────────────────────────────────────────────────────────
    Process {
        id: netProc
        command: ["bash", "-c",
            "wifi=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -n 1); " +
            "ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'); " +
            "eth=$(nmcli -t -f type,state dev 2>/dev/null | grep 'ethernet:connected'); " +
            "echo \"$wifi|$eth|$ip\""
        ]
        running: true
        stdout: StdioCollector {
            onDataChanged: {
                try {
                    var parts = text.trim().split("|");
                    if (parts.length >= 3) {
                        var wifiPart = parts[0];
                        var ethPart  = parts[1];
                        var ipPart   = parts[2];
                        root.ipAddress = ipPart || "Disconnected";
                        if (ethPart && ethPart.indexOf("connected") !== -1) {
                            root.isConnected   = true;
                            root.isEthernet    = true;
                            root.isWifi        = false;
                            root.ssid          = "Ethernet";
                            root.signalPercent = 100;
                        } else if (wifiPart && wifiPart.indexOf("yes:") === 0) {
                            var w = wifiPart.split(":");
                            root.isConnected   = true;
                            root.isEthernet    = false;
                            root.isWifi        = true;
                            root.ssid          = w[1] || "Wi-Fi";
                            root.signalPercent = parseInt(w[2]) || 0;
                        } else {
                            root.isConnected   = false;
                            root.isEthernet    = false;
                            root.isWifi        = false;
                            root.ssid          = "Disconnected";
                            root.signalPercent = 0;
                        }
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: netProc.running = true
    }

    // ─────────────────────────────────────────────────────────────
    // NETWORK SCANNER
    // ─────────────────────────────────────────────────────────────
    Process {
        id: scanProc
        command: ["bash", "-c",
            "nmcli -t -f active,ssid,signal,security dev wifi 2>/dev/null " +
            "| awk -F: 'BEGIN{OFS=\"|\"} {active=$1; ssid=$2; sig=$3; sec=$4; for(i=5;i<=NF;i++) sec=sec \":\" $i; print active,ssid,sig,sec}' " +
            "| sort -t'|' -k3 -rn " +
            "| awk -F'|' '!seen[$2]++'"
        ]
        running: false
        stdout: StdioCollector {
            onDataChanged: {
                if (text.trim() === "") { root.isScanning = false; return; }
                var lines = text.trim().split("\n");
                var result = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line === "") continue;
                    var p = line.split("|");
                    if (p.length < 4) continue;
                    var ssid = p[1];
                    if (ssid === "" || ssid === "--") continue;
                    result.push({
                        active:   p[0] === "yes",
                        ssid:     ssid,
                        signal:   parseInt(p[2]) || 0,
                        security: p[3] || ""
                    });
                }
                root.networks = result;
                root.isScanning = false;
            }
        }
    }

    // Connects to an open (unsecured) network
    Process {
        id: connectProc
        property string targetSsid: ""
        command: ["bash", "-c", "nmcli dev wifi connect \"" + targetSsid + "\" 2>/dev/null || true"]
        running: false
        onRunningChanged: {
            if (!running) {
                refreshTimer.start();
            }
        }
    }

    function scanNetworks() {
        root.isScanning = true;
        root.networks = [];
        scanProc.running = true;
    }

    Timer {
        id: refreshTimer
        interval: 2500; repeat: false
        onTriggered: {
            netProc.running = true;
            root.scanNetworks();
        }
    }

    // ─────────────────────────────────────────────────────────────
    // STATUS BAR CAPSULE
    // ─────────────────────────────────────────────────────────────
    Rectangle {
        id: netCapsule
        anchors.fill: parent
        radius: Theme.radiusPill
        color: netMouse.containsMouse ? Theme.bgLight : Theme.bgAlt
        border {
            width: 1
            color: netPopup.visible ? Theme.borderFocus : (netMouse.containsMouse ? Theme.borderHover : Theme.border)
        }
        implicitWidth: netRow.implicitWidth + 16
        implicitHeight: Theme.capsuleHeight

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        RowLayout {
            id: netRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.netIcon
                color: root.isConnected ? Theme.fgBright : Theme.fgMuted
                font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }
            }

            Text {
                text: root.isConnected ? (root.isWifi ? root.ssid : "Ethernet") : "Offline"
                color: root.isConnected ? Theme.fg : Theme.fgMuted
                font { family: Theme.fontMono; pixelSize: Theme.fontSizeSm; weight: Font.Medium }
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        MouseArea {
            id: netMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!netPopup.visible) {
                    netPopup.visible = true;
                    netProc.running = true;
                    root.scanNetworks();
                } else {
                    netPopup.visible = false;
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // NETWORK POPUP
    // ─────────────────────────────────────────────────────────────
    PopupWindow {
        id: netPopup

        anchor.window: root.barWindow
        anchor.rect.x: Math.round(Math.max(12, Math.min(
            root.barWindow.width - width - 12,
            root.mapToItem(null, 0, 0).x + root.width / 2 - width / 2
        )))
        anchor.rect.y: root.barWindow.height + 2

        implicitWidth: 300
        implicitHeight: 380
        color: "transparent"
        visible: false
        grabFocus: true

        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusPopup
            color: Theme.bgCard
            border { width: 1; color: Theme.borderFocus }

            // Inner rim
            Rectangle {
                anchors { fill: parent; margins: 1 }
                radius: Theme.radiusPopup - 1
                color: "transparent"
                border { width: 1; color: "#15d5c6a5" }
            }

            // ── Header ─────────────────────────────────────────────
            RowLayout {
                id: netHeader
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                height: 50
                spacing: 10

                // Icon badge
                Rectangle {
                    width: 36; height: 36; radius: 10
                    color: root.isConnected ? "#1ab8bb26" : Theme.bgLight
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.netIcon
                        color: root.isConnected ? Theme.green : Theme.fgMuted
                        font { family: Theme.fontMono; pixelSize: Theme.iconSizeMd }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: root.ssid !== "" ? root.ssid : "Wi-Fi"
                        color: Theme.fgBright
                        font { family: Theme.fontMono; pixelSize: Theme.fontSizeMd; weight: Font.Bold }
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.isConnected
                            ? (root.isEthernet
                                ? "Wired · " + root.ipAddress
                                : root.signalPercent + "% signal · " + root.ipAddress)
                            : "Not connected"
                        color: Theme.fgMuted
                        font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs }
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Refresh button
                Rectangle {
                    width: 28; height: 28; radius: 7
                    color: scanBtnHover.containsMouse ? Theme.bgLight : Theme.bgSubtle
                    border { width: 1; color: Theme.border }
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰑓"
                        color: root.isScanning ? Theme.yellow : Theme.fgMuted
                        font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }

                        RotationAnimation on rotation {
                            running: root.isScanning
                            from: 0; to: 360; duration: 900
                            loops: Animation.Infinite
                        }
                    }

                    MouseArea {
                        id: scanBtnHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.scanNetworks()
                    }
                }
            }

            // Divider
            Rectangle {
                id: netDivider
                anchors { top: netHeader.bottom; left: parent.left; right: parent.right; topMargin: 2; leftMargin: 16; rightMargin: 16 }
                height: 1
                color: Theme.borderSubtle
            }

            // Section label
            Text {
                id: netLabel
                anchors { top: netDivider.bottom; left: parent.left; right: parent.right; topMargin: 10; leftMargin: 16 }
                text: "Available Networks"
                color: Theme.fgDark
                font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs; weight: Font.Medium }
            }

            // ── Network list ────────────────────────────────────────
            ListView {
                id: netList
                anchors {
                    top: netLabel.bottom; bottom: parent.bottom
                    left: parent.left; right: parent.right
                    topMargin: 6; bottomMargin: 8; leftMargin: 8; rightMargin: 8
                }
                clip: true
                model: root.networks
                spacing: 3

                // Placeholder
                Item {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 80
                    visible: root.networks.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.isScanning ? "󱕼" : "󰤮"
                            color: Theme.fgSubdued
                            font { family: Theme.fontMono; pixelSize: Theme.iconSizeLg }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.isScanning ? "Scanning…" : "No networks found"
                            color: Theme.fgDark
                            font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs }
                        }
                    }
                }

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 46
                    radius: Theme.radiusInner
                    color: modelData.active
                        ? "#18b8bb26"
                        : (netRowHover.containsMouse ? Theme.bgSubtle : "transparent")
                    border { width: 1; color: modelData.active ? "#33b8bb26" : "transparent" }
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                        spacing: 10

                        // Signal icon
                        Text {
                            text: root.signalIcon(modelData.signal)
                            color: modelData.active ? Theme.green : root.signalColor(modelData.signal)
                            font { family: Theme.fontMono; pixelSize: Theme.iconSizeSm }
                        }

                        // SSID + signal bar
                        ColumnLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            RowLayout {
                                spacing: 6
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.ssid
                                    color: modelData.active ? Theme.green : Theme.fgBright
                                    font {
                                        family: Theme.fontMono
                                        pixelSize: Theme.fontSizeSm
                                        weight: modelData.active ? Font.Bold : Font.Normal
                                    }
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Lock icon
                                Text {
                                    visible: modelData.security !== "" && modelData.security !== "--"
                                    text: "󰌾"
                                    color: Theme.fgDark
                                    font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs }
                                }

                                // "Connected" badge
                                Rectangle {
                                    visible: modelData.active
                                    width: 56; height: 15; radius: 4
                                    color: "#33b8bb26"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Connected"
                                        color: Theme.green
                                        font { family: Theme.fontMono; pixelSize: 9; weight: Font.Medium }
                                    }
                                }
                            }

                            // Signal strength bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 3; radius: 2
                                color: Theme.bgLighter

                                Rectangle {
                                    width: parent.width * (modelData.signal / 100.0)
                                    height: parent.height; radius: 2
                                    color: root.signalColor(modelData.signal)
                                    opacity: 0.7
                                }
                            }
                        }

                        // Connect button (non-active only)
                        Rectangle {
                            visible: !modelData.active
                            width: 60; height: 22; radius: 6
                            color: connHover.containsMouse ? "#2283a598" : "#1283a598"
                            border { width: 1; color: "#4483a598" }
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "Connect"
                                color: Theme.blue
                                font { family: Theme.fontMono; pixelSize: Theme.fontSizeXs; weight: Font.Medium }
                            }

                            MouseArea {
                                id: connHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var net = modelData;
                                    if (net.security !== "" && net.security !== "--") {
                                        // Secured: open nmtui for password
                                        Quickshell.execDetached(["kitty", "-e", "nmtui"]);
                                        netPopup.visible = false;
                                    } else {
                                        // Open network: connect directly
                                        connectProc.targetSsid = net.ssid;
                                        connectProc.running = true;
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: netRowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }
}
