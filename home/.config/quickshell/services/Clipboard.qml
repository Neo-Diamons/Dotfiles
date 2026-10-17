pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Text clipboard history in memory, skips password-manager secrets
Singleton {
    id: root

    property var history: []

    // Stored as JSON: JS values can't cross reloads
    PersistentProperties {
        id: persist
        reloadableId: "clipboard"

        property string history: "[]"

        onReloaded: root.history = JSON.parse(history)
    }

    onHistoryChanged: persist.history = JSON.stringify(history)

    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    function remove(text) {
        history = history.filter(h => h.text !== text);
    }

    function clear() {
        history = [];
        Quickshell.execDetached(["wl-copy", "--clear"]);
    }

    function add(text) {
        if (text.trim() === "")
            return;
        history = [{
                text: text,
                time: Date.now()
            }].concat(history.filter(h => h.text !== text)).slice(0, Config.clipboardHistoryLimit);
    }

    // One JSON string per clipboard change (jq keeps newlines intact)
    Process {
        running: true
        command: ["wl-paste", "--type", "text", "--watch", "sh", "-c", "wl-paste --list-types | grep -q x-kde-passwordManagerHint || jq -Rsc ."]
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.add(JSON.parse(line));
                } catch (e) {}
            }
        }
    }
}
