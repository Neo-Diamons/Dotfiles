import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

// Drive card: name, size, usage and Mount / Open / Unmount / Eject
BrutalSurface {
    id: root

    required property var modelData

    readonly property bool mounted: modelData.mountpoint !== ""
    readonly property bool busy: Drives.busyDevice === modelData.device
    readonly property bool usageKnown: mounted && modelData.used >= 0 && modelData.avail >= 0

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + Theme.spacing.sm * 2 + shadowOffset

    fillColor: Colors.bgOverlay
    borderColor: mounted ? Colors.accent : Colors.borderDefault
    borderWidth: mounted ? Theme.dims.borderWidthActive : Theme.dims.borderWidth

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.sm
        spacing: Theme.spacing.xs

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.sm

            BrutalText {
                text: root.modelData.locked ? "󰌾" : (root.modelData.removable ? "󰕓" : "󰋊")
                color: root.mounted ? Colors.textAccent : Colors.textMuted
            }

            BrutalText {
                Layout.fillWidth: true
                text: root.modelData.name
                font.bold: true
                elide: Text.ElideRight
            }

            BrutalText {
                text: Drives.formatSize(root.modelData.size) + " · " + root.modelData.fstype
                color: Colors.textMuted
                font.pixelSize: Theme.font.sizeSmall
            }
        }

        BrutalProgress {
            visible: root.usageKnown
            Layout.fillWidth: true
            value: root.usageKnown ? root.modelData.used / (root.modelData.used + root.modelData.avail) : 0
        }

        BrutalText {
            Layout.fillWidth: true
            text: {
                const d = root.modelData;
                if (root.busy)
                    return "Working…";
                if (d.locked)
                    return d.deviceName + " · encrypted";
                if (!root.mounted)
                    return d.deviceName + " · not mounted";
                return d.mountpoint + (root.usageKnown ? " · " + Drives.formatSize(d.avail) + " free" : "");
            }
            color: Colors.textMuted
            font.pixelSize: Theme.font.sizeSmall
            elide: Text.ElideMiddle
        }

        Flow {
            visible: !root.busy && !root.modelData.locked
            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            BrutalButton {
                visible: !root.mounted
                text: "Mount"
                onClicked: Drives.mount(root.modelData)
            }

            BrutalButton {
                visible: root.mounted
                text: "Open"
                onClicked: Drives.open(root.modelData)
            }

            BrutalButton {
                visible: root.mounted && !root.modelData.system
                text: "Unmount"
                onClicked: Drives.unmount(root.modelData)
            }

            BrutalButton {
                visible: root.modelData.removable && !root.modelData.system
                text: "Eject"
                onClicked: Drives.eject(root.modelData)
            }
        }
    }
}
