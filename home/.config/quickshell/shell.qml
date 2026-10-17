//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.osd
import qs.modules.polkit
import qs.modules.wallpaper
import qs.utils

// Entry point: bars, launcher, notifications, OSD, wallpaper menu and polkit agent (`qs ipc call shell reload`)
ShellRoot {
    settings.watchFiles: false

    IpcHandler {
        target: "shell"

        function reload(): void {
            Quickshell.reload(true);
        }
    }

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
            Quickshell.execDetached(["notify-send", "-e", "-a", "Quickshell", "-h", "string:x-dunst-stack-tag:quickshell-reload", "Shell reloaded"]);
        }

        function onReloadFailed(error) {
            Quickshell.inhibitReloadPopup();
            Quickshell.execDetached(["notify-send", "-e", "-u", "critical", "-a", "Quickshell", "-h", "string:x-dunst-stack-tag:quickshell-reload", "Reload failed", error]);
        }
    }

    Variants {
        model: ScreenUtils.barScreens

        BarWindow {}
    }

    LauncherWindow {}
    NotifWindow {}
    VolumeOsd {}
    WallpaperMenu {}
    PolkitDialog {}
}
