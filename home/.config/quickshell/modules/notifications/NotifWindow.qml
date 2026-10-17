import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.utils

// Notification popups, top right of the primary screen
PanelWindow { // qmllint disable uncreatable-type
    id: notifWindow

    screen: ScreenUtils.primaryScreen

    anchors {
        top: true
        right: true
    }

    margins { // qmllint disable unresolved-type unqualified
        top: Theme.spacing.md
        right: Theme.dims.barWidth + Theme.spacing.md
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Notifs.popups.values.some(n => n.hasInlineReply) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: Theme.dims.notifWidth
    implicitHeight: Math.max(1, notifColumn.implicitHeight)

    Column {
        id: notifColumn
        width: Theme.dims.notifWidth
        spacing: Theme.spacing.xs

        Repeater {
            model: Notifs.popups

            NotificationCard {
                width: parent.width
            }
        }
    }
}
