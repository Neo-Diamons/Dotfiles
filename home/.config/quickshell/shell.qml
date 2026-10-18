//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.dim
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.power
import qs.modules.polkit
import qs.modules.wallpaper
import qs.utils

// Entry point: bars, launcher, power menu, lock screen, notifications, OSD, wallpaper menu and polkit agent (`qs ipc call shell reload`)
ShellRoot {
    id: root

    property bool reloadPending: false

    settings.watchFiles: false

    IpcHandler {
        target: "shell"

        function reload(): void {
            if (lockScreen.locked)
                root.reloadPending = true;
            else
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

    DimOverlay {}
    LauncherWindow {}
    PowerMenu {}
    LockScreen {
        id: lockScreen
        onLockedChanged: {
            if (!locked && root.reloadPending)
                Quickshell.reload(true);
        }
    }
    NotifWindow {}
    VolumeOsd {}
    BrightnessOsd {}
    WallpaperMenu {}
    PolkitDialog {}
}
