pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Pending pacman updates from checkupdates, kept across reloads (`qs ipc call updates`)
Singleton {
    id: root

    property var packages: []
    property bool checking: false
    property string error: ""
    property real lastCheck: 0

    readonly property int count: packages.length

    function refresh() {
        if (check.running)
            return;
        checking = true;
        check.running = true;
    }

    // Terminal calls back over IPC (Hyprland starts it, so no exit signal)
    function upgrade() {
        const script = `${Config.updateCommand}; qs ipc call updates refresh; echo; read -rp 'Done. Press Enter to close' _`;
        const cmd = `${Config.terminal} --app-id=quickshell-updates --title=Updates sh -c "${script}"`;
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd([[${cmd}]], { float = true, center = true, size = "${Config.updatesWindowSize}" })`]);
    }

    // "linux 6.1-1 -> 6.2-1" lines; exit 2 = no updates, anything else = error
    function parse(text) {
        const lines = text.trim().split("\n");
        const status = parseInt((lines.pop() || "").replace("exit:", ""));
        if (status === 0 || status === 2) {
            packages = lines.map(l => l.trim().split(/\s+/)).filter(f => f.length >= 4).map(f => ({
                        name: f[0],
                        from: f[1],
                        to: f[3]
                    }));
            error = "";
        } else {
            error = lines.filter(l => l.trim() !== "").pop() || "checkupdates failed";
        }
        lastCheck = Date.now();
        checking = false;
        persist.packages = JSON.stringify(packages);
        persist.lastCheck = lastCheck;
    }

    PersistentProperties {
        id: persist
        reloadableId: "updates"

        property string packages: "[]"
        property real lastCheck: 0

        onReloaded: {
            root.packages = JSON.parse(packages);
            root.lastCheck = lastCheck;
            tick.triggered();
        }
    }

    Process {
        id: check
        command: ["sh", "-c", "checkupdates --nocolor 2>&1; echo \"exit:$?\""]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    IpcHandler {
        target: "updates"

        function refresh(): void {
            root.refresh();
        }
    }

    Timer {
        id: tick
        interval: 10 * 60 * 1000
        repeat: true
        running: true
        onTriggered: {
            if (Date.now() - root.lastCheck >= Config.updatesInterval * 3600 * 1000)
                root.refresh();
        }
    }
}
