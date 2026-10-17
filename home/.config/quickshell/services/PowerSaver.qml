pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Battery saver (no blur, shadows or animations): `auto` follows the power source (`qs ipc call powersave toggle`)
Singleton {
    id: root

    readonly property string script: Quickshell.shellDir + "/scripts/powersave.py"

    property bool battery: false
    property string mode: "auto"
    property bool active: false

    function setMode(newMode) {
        setter.command = ["python3", script, "mode", newMode];
        setter.running = true;
    }

    function toggle() {
        setter.command = ["python3", script, "toggle"];
        setter.running = true;
    }

    function parse(line) {
        const state = JSON.parse(line);
        battery = state.battery;
        mode = state.mode;
        active = state.active;
    }

    Process {
        running: true
        command: ["python3", root.script, "watch"]
        stdout: SplitParser {
            onRead: line => root.parse(line)
        }
    }

    Process {
        id: setter
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    IpcHandler {
        target: "powersave"

        function toggle(): void {
            root.toggle();
        }
    }
}
