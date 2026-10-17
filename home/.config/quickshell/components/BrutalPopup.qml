import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

// Popup beside the bar, aligned with the item that opened it, closes on Escape or outside click
PanelWindow { // qmllint disable uncreatable-type
    id: root

    property bool open: false
    property string title: ""
    property int panelWidth: Theme.dims.settingsWidth
    property int contentMargins: Theme.spacing.md
    property int contentSpacing: Theme.spacing.md
    property string layerName: "quickshell-popup"

    default property alias content: body.data

    property real anchorY: -1

    property Item anchorItem: null
    property real closedAt: 0
    readonly property int reopenGuard: 300

    signal closeRequested

    function popup(item) {
        anchorItem = item;
        anchorY = item ? item.mapToItem(null, 0, 0).y : -1;
        open = true;
    }

    function justClosedFrom(item) {
        return !open && item === anchorItem && Date.now() - closedAt < reopenGuard;
    }

    function toggle(item) {
        if (open)
            closeRequested();
        else if (!justClosedFrom(item))
            popup(item);
    }

    onCloseRequested: open = false
    onOpenChanged: {
        if (!open)
            closedAt = Date.now();
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.open
        onCleared: root.closeRequested()
    }

    visible: open
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins { // qmllint disable unqualified unresolved-type
        right: Theme.dims.barWidth
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: root.layerName
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Item {
        id: stage
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.closeRequested()

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }

        MouseArea {
            anchors.fill: panel
        }

        BrutalPanel {
            id: panel

            readonly property real maxY: stage.height - height - Theme.spacing.sm

            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.sm
            y: root.anchorY < 0 ? maxY : Math.max(Theme.spacing.sm, Math.min(root.anchorY, maxY))

            width: root.panelWidth
            height: Math.min(implicitHeight, stage.height - 2 * Theme.spacing.sm)

            BrutalHeader {
                visible: root.title !== ""
                title: root.title
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: root.contentMargins
                implicitHeight: body.implicitHeight
                contentWidth: width
                contentHeight: body.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: body
                    width: parent.width
                    spacing: root.contentSpacing
                }
            }
        }
    }
}
