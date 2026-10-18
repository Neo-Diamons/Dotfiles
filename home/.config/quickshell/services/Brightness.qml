pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Backlight of the built-in panel (brightnessctl), unavailable on hosts without one
Singleton {
    id: root

    property bool available: false
    property real level: 0

    property var pendingSteps: []

    signal updated

    function increase() {
        change("+");
    }

    function decrease() {
        change("-");
    }

    function change(sign) {
        pendingSteps.push(Config.brightnessStep + "%" + sign);
        next();
    }

    function next() {
        if (query.running || pendingSteps.length === 0)
            return;
        query.command = ["brightnessctl", "-e4", "-n2", "-m", "-c", "backlight", "set", pendingSteps.shift()];
        query.running = true;
    }

    Process {
        id: query
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                // name,class,current,percent,max
                const fields = collector.text.trim().split(",");
                root.available = fields.length >= 5;
                if (root.available) {
                    root.level = parseInt(fields[3]) / 100;
                    root.updated();
                }
            }
        }
        onExited: root.next()
    }
}
