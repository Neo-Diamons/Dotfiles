import QtQuick
import Quickshell.Io
import qs.modules.controls
import qs.services
import qs.utils

// Settings cog, dot when notifications are unread (`qs ipc call controls`)
ControlTile {
    id: root

    property var screen

    icon: ""
    selected: panel.open
    badge: Notifs.unread > 0

    onLeftClicked: panel.toggle(null)

    SettingsPanel {
        id: panel
        screen: root.screen
    }

    // One bar per screen: only the primary one answers
    IpcHandler {
        target: "controls"
        enabled: root.screen === ScreenUtils.primaryScreen

        function toggle(page: string): void {
            panel.togglePage(page);
        }
        function open(page: string): void {
            panel.show(page);
        }
        function close(): void {
            panel.closeRequested();
        }
    }
}
