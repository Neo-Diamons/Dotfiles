pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.config

// Ethernet and Wi-Fi state, VPNs from nmcli (not exposed by Quickshell.Networking)
Singleton {
    id: root

    readonly property var devices: Networking.devices.values // qmllint disable missing-property
    readonly property var wired: devices.filter(d => d.type === DeviceType.Wired)
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null

    readonly property var wifiNetworks: wifi ? wifi.networks.values.filter(n => n.name !== "").sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)).slice(0, Config.wifiListLimit) : []

    readonly property bool ethernetConnected: wired.some(d => d.connected)
    readonly property var wifiConnected: wifiNetworks.find(n => n.connected) ?? null
    readonly property bool vpnActive: vpnList.some(v => v.active)
    readonly property bool online: ethernetConnected || wifiConnected !== null

    property var vpnList: []
    property string pendingSsid: ""
    property string error: ""

    property bool scanning: false

    readonly property string summary: {
        const parts = [];
        if (ethernetConnected)
            parts.push("Ethernet");
        if (wifiConnected)
            parts.push(wifiConnected.name);
        if (vpnActive)
            parts.push("VPN");
        return parts.length > 0 ? parts.join(" · ") : "Disconnected";
    }

    readonly property string icon: ethernetConnected ? "󰈀" : ""

    function connectWifi(n) {
        error = "";
        if (n.connected)
            n.disconnect();
        else if (n.known || n.security === WifiSecurityType.Open)
            n.connect();
        else
            pendingSsid = n.name;
    }

    function toggleVpn(vpn) {
        error = "";
        vpnRunner.command = ["nmcli", "connection", vpn.active ? "down" : "up", "id", vpn.name];
        vpnRunner.running = true;
    }

    onScanningChanged: {
        if (!scanning) {
            pendingSsid = "";
            error = "";
        }
    }

    Binding {
        when: root.wifi !== null
        target: root.wifi
        property: "scannerEnabled"
        value: root.scanning && Networking.wifiEnabled
    }

    // nmcli -t escapes ':' as '\:'
    function splitFields(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[i + 1];
                i++;
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }

    function parseVpns(text) {
        const vpns = [];
        for (const line of text.trim().split("\n")) {
            if (!line)
                continue;
            const f = splitFields(line);
            if (f[1] === "vpn" || f[1] === "wireguard")
                vpns.push({
                    name: f[0],
                    active: f[2] === "yes"
                });
        }
        vpnList = vpns;
    }

    Process {
        id: vpnQuery
        running: true
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.parseVpns(text)
        }
    }

    Process {
        id: vpnRunner
        stderr: StdioCollector {
            onStreamFinished: root.error = text.trim()
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: vpnDebounce.restart()
        }
    }

    Timer {
        id: vpnDebounce
        interval: 400
        onTriggered: vpnQuery.running = true
    }
}
