pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.components
import qs.config

// Bluetooth page: power switch, devices with type and battery, scan
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    property bool panelOpen: false

    // Wrong type name in Quickshell's qmltypes, fine at runtime
    readonly property var adapter: Bluetooth.defaultAdapter // qmllint disable unresolved-type
    readonly property bool on: adapter ? adapter.enabled : false
    readonly property bool scanning: adapter ? adapter.discovering : false
    readonly property var devices: adapter ? adapter.devices.values.filter(d => d.paired || d.connected || root.scanning) : []
    readonly property int connectedCount: devices.filter(d => d.connected).length
    readonly property string status: !adapter ? "No adapter" : !on ? "Off" : connectedCount > 0 ? connectedCount + " connected" : "On"

    function deviceIcon(name) {
        const n = name || "";
        if (n.startsWith("audio-headset") || n.startsWith("audio-headphones"))
            return "󰋋";
        if (n.startsWith("audio"))
            return "󰓃";
        if (n === "input-mouse")
            return "󰍽";
        if (n === "input-keyboard")
            return "󰌌";
        if (n === "input-gaming")
            return "󰊗";
        if (n === "input-tablet")
            return "󰓶";
        if (n === "phone")
            return "󰄜";
        if (n === "computer")
            return "󰌢";
        if (n.startsWith("camera"))
            return "󰄀";
        return "";
    }

    function batteryText(d) {
        return d.batteryAvailable ? "󰁹 " + Math.round(d.battery * 100) + "%" : "";
    }

    onPanelOpenChanged: {
        if (!panelOpen && adapter && adapter.discovering)
            adapter.discovering = false;
    }

    SectionHeader {
        icon: ""
        title: "Bluetooth"
        status: root.status
        showSwitch: root.adapter !== null
        checked: root.on
        onToggled: root.adapter.enabled = !root.adapter.enabled
    }

    Repeater {
        model: root.on ? root.devices : []

        BrutalRow {
            required property var modelData
            icon: root.deviceIcon(modelData.icon)
            text: modelData.name || modelData.deviceName || modelData.address
            trailing: modelData.connected ? (root.batteryText(modelData) || "connected") : (modelData.paired ? "" : "pair")
            highlighted: modelData.connected
            onClicked: {
                if (!modelData.paired)
                    modelData.pair();
                else if (modelData.connected)
                    modelData.disconnect();
                else
                    modelData.connect();
            }
        }
    }

    BrutalText {
        visible: root.on && root.devices.length === 0
        text: "No paired devices"
        font.pixelSize: Theme.font.sizeSmall
        color: Colors.textMuted
    }

    BrutalRow {
        visible: root.on
        icon: ""
        text: root.scanning ? "Scanning… (tap to stop)" : "Scan for devices"
        onClicked: root.adapter.discovering = !root.adapter.discovering
    }
}
