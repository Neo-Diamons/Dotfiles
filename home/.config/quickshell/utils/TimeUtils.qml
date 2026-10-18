pragma Singleton

import QtQuick
import Quickshell
import qs.config

// Relative times: "now", "5m", "2h", "07/10"
Singleton {
    id: root

    property real now: Date.now()

    function timeAgo(time) {
        const minutes = Math.floor((now - time) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return minutes + "m";
        if (minutes < 24 * 60)
            return Math.floor(minutes / 60) + "h";
        return Qt.formatDate(new Date(time), Config.shortDateFormat);
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
