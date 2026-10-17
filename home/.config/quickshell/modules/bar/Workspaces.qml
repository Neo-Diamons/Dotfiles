import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.components
import qs.config

// Workspace tiles 1–5, outlined when empty, accent when active
ColumnLayout {
    id: root
    spacing: Theme.spacing.xs
    Layout.alignment: Qt.AlignHCenter

    property var workspacesList: Array.from({ length: Config.workspaceCount }, (_, i) => i + 1)

    Repeater {
        model: root.workspacesList

        BrutalTile {
            id: wsBox
            required property int modelData

            readonly property bool isActive: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace && Hyprland.focusedMonitor.activeWorkspace.id === modelData

            readonly property var wsObj: Hyprland.workspaces.values.find(w => w.id === modelData)
            readonly property bool isOccupied: wsObj !== undefined

            Layout.alignment: Qt.AlignHCenter
            text: String(modelData)
            selected: isActive
            ghost: !isOccupied

            onLeftClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsBox.modelData} })`)
        }
    }
}
