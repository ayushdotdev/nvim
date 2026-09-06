import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root

    property string windowTitle: ""
    property string windowClass: ""

    implicitHeight: Theme.capsuleHeight
    implicitWidth: Math.min(260, titleRow.implicitWidth + 16)
    radius: Theme.radiusPill
    color: Theme.bgAlt
    border {
        width: 1
        color: Theme.border
    }

    // Determine icon based on app class
    readonly property string appIcon: {
        var c = windowClass.toLowerCase();
        if (c.indexOf("kitty") !== -1 || c.indexOf("term") !== -1 || c.indexOf("alacritty") !== -1 || c.indexOf("foot") !== -1) return "󰄛";
        if (c.indexOf("zen") !== -1 || c.indexOf("firefox") !== -1 || c.indexOf("browser") !== -1 || c.indexOf("chromium") !== -1 || c.indexOf("chrome") !== -1) return "󰈹";
        if (c.indexOf("dolphin") !== -1 || c.indexOf("nautilus") !== -1 || c.indexOf("thunar") !== -1 || c.indexOf("file") !== -1) return "󰉋";
        if (c.indexOf("spotify") !== -1) return "󰓇";
        if (c.indexOf("discord") !== -1 || c.indexOf("vesktop") !== -1) return "󰙯";
        if (c.indexOf("nvim") !== -1 || c.indexOf("neovim") !== -1 || c.indexOf("code") !== -1 || c.indexOf("vscodium") !== -1) return "󰅩";
        if (c.indexOf("thunderbird") !== -1 || c.indexOf("mail") !== -1) return "󰇮";
        if (windowTitle === "") return "󰇄";
        return "󰖲";
    }

    Process {
        id: activeWinProc
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onDataChanged: {
                try {
                    var data = JSON.parse(text);
                    if (data && data.title) {
                        root.windowTitle = data.title;
                        root.windowClass = data.class || data.initialClass || "";
                    } else {
                        root.windowTitle = "";
                        root.windowClass = "";
                    }
                } catch(e) {}
            }
        }
    }

    // Reactively refresh whenever Hyprland reports a window change
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activewindow" || event.name === "activewindowv2" || event.name === "closewindow" || event.name === "openwindow") {
                activeWinProc.running = true;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            activeWinProc.running = true;
        }
    }

    RowLayout {
        id: titleRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 8
            rightMargin: 8
        }
        spacing: 6

        Text {
            text: root.appIcon
            color: Theme.accent
            font {
                family: Theme.fontMono
                pixelSize: Theme.iconSizeSm
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.windowTitle !== "" ? root.windowTitle : "Desktop"
            color: root.windowTitle !== "" ? Theme.fg : Theme.fgMuted
            elide: Text.ElideRight
            font {
                family: Theme.fontMono
                pixelSize: Theme.fontSizeSm
                weight: Font.Medium
            }
        }
    }
}
