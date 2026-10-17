pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Themed tray icons from icons.py, cached across reloads
Singleton {
    id: root

    property var icons: ({})
    property var pending: ({})

    // Tooltips change often: not part of the key
    function key(item, iconName) {
        return [item.id || "", item.title || "", iconName].join("\u001f"); // unit separator
    }

    function request(item, iconName) {
        const k = key(item, iconName);
        if (k in icons || k in pending)
            return;
        pending[k] = true;
        lookup.createObject(root, {
            key: k,
            command: ["python3", Quickshell.shellDir + "/scripts/icons.py", "lookup", item.id || "", item.title || "", item.tooltipTitle || "", iconName]
        });
    }

    function store(k, file) {
        delete pending[k];
        icons = Object.assign({}, icons, {
            [k]: file
        });
        persist.icons = JSON.stringify(icons);
    }

    // Stored as JSON: JS values can't cross reloads
    PersistentProperties {
        id: persist
        reloadableId: "trayIcons"

        property string icons: "{}"

        onReloaded: root.icons = JSON.parse(icons)
    }

    Component {
        id: lookup

        Process {
            id: proc

            property string key

            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    let file = "";
                    try {
                        file = JSON.parse(text).iconFile || "";
                    } catch (e) {}
                    root.store(proc.key, file ? "file://" + file : "");
                    proc.destroy();
                }
            }
        }
    }
}
