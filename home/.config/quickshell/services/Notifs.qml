pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

// Notification server, do not disturb and history
Singleton {
    id: root

    property alias dnd: persist.dnd

    property var history: []
    property alias unread: persist.unread

    // Stored as JSON: JS values can't cross reloads
    PersistentProperties {
        id: persist
        reloadableId: "notifs"

        property bool dnd: false
        property string history: "[]"
        property int unread: 0

        onReloaded: root.history = JSON.parse(history)
    }

    onHistoryChanged: persist.history = JSON.stringify(history)

    readonly property var popups: server.trackedNotifications

    function remove(id) {
        history = history.filter(h => h.id !== id);
    }

    function clear() {
        history = [];
        unread = 0;
    }

    function markRead() {
        unread = 0;
    }

    // Notifications sharing a stack tag replace each other, whatever their id
    function stackTag(n) {
        const h = n.hints || {};
        return h["x-canonical-private-synchronous"] || h["x-dunst-stack-tag"] || "";
    }

    // image:// hints die with the notification, keep file paths only
    function snapshot(n) {
        const image = n.image || "";
        return {
            id: n.id,
            tag: stackTag(n),
            appName: n.appName || "System",
            summary: n.summary || "",
            body: n.body || "",
            appIcon: n.appIcon || "",
            image: image.startsWith("image://") ? "" : image,
            critical: n.urgency === NotificationUrgency.Critical,
            time: Date.now()
        };
    }

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            const tag = root.stackTag(n);
            if (tag !== "")
                for (const old of server.trackedNotifications.values.filter(o => o !== n && root.stackTag(o) === tag))
                    old.dismiss();
            if (!n.transient) {
                root.history = [root.snapshot(n)].concat(root.history.filter(h => h.id !== n.id && (tag === "" || h.tag !== tag))).slice(0, Config.notifHistoryLimit);
                root.unread++;
            }
            n.tracked = !root.dnd || n.urgency === NotificationUrgency.Critical;
        }
    }
}
