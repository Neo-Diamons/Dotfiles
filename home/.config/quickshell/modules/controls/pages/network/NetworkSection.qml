pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.components
import qs.config
import qs.services

// Network page: Ethernet, Wi-Fi with inline password prompt, VPNs
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    SectionHeader {
        icon: Net.icon
        title: "Network"
        status: Net.summary
    }

    Repeater {
        model: Net.wired.filter(d => d.hasLink || d.connected)

        BrutalRow {
            required property var modelData
            icon: "󰈀"
            text: "Ethernet"
            trailing: modelData.connected ? (modelData.network ? modelData.network.name : modelData.name) : "off"
            highlighted: modelData.connected
            onClicked: {
                if (modelData.connected)
                    modelData.disconnect();
                else if (modelData.network)
                    modelData.network.connect();
            }
        }
    }

    BrutalRow {
        visible: Net.wifi !== null
        enabled: Networking.wifiHardwareEnabled
        icon: ""
        text: "Wi-Fi"
        trailing: !Networking.wifiHardwareEnabled ? "blocked" : (Networking.wifiEnabled ? "on" : "off")
        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
    }

    Repeater {
        model: Networking.wifiEnabled ? Net.wifiNetworks : []

        ColumnLayout {
            id: net
            required property var modelData
            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            readonly property bool secure: modelData.security !== WifiSecurityType.Open

            Connections {
                target: net.modelData
                function onConnectionFailed(reason) {
                    Net.error = net.modelData.name + ": " + ConnectionFailReason.toString(reason);
                    if (reason === ConnectionFailReason.NoSecrets)
                        Net.pendingSsid = net.modelData.name;
                }
            }

            BrutalRow {
                icon: ""
                text: net.modelData.name
                trailing: net.modelData.stateChanging ? "…" : Math.round(net.modelData.signalStrength * 100) + "%" + (net.secure ? " · " + WifiSecurityType.toString(net.modelData.security) : "")
                highlighted: net.modelData.connected
                onClicked: Net.connectWifi(net.modelData)
            }

            BrutalInput {
                id: pw
                visible: Net.pendingSsid === net.modelData.name
                Layout.fillWidth: true
                fieldHeight: Theme.dims.rowHeight
                password: true
                placeholder: "Password, Enter to connect"

                onVisibleChanged: {
                    if (visible)
                        pw.focusInput();
                }

                onAccepted: {
                    Net.error = "";
                    net.modelData.connectWithPsk(text);
                    Net.pendingSsid = "";
                    text = "";
                }
            }
        }
    }

    Repeater {
        model: Net.vpnList

        BrutalRow {
            required property var modelData
            icon: ""
            text: modelData.name
            trailing: modelData.active ? "connected" : "off"
            highlighted: modelData.active
            onClicked: Net.toggleVpn(modelData)
        }
    }

    BrutalText {
        visible: Net.error !== ""
        Layout.fillWidth: true
        text: Net.error
        wrapMode: Text.Wrap
        font.pixelSize: Theme.font.sizeSmall
        color: Colors.textAccent
    }
}
