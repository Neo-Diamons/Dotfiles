pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.config
import qs.modules.controls.pages.audio
import qs.modules.controls.pages.bluetooth
import qs.modules.controls.pages.clipboard
import qs.modules.controls.pages.drives
import qs.modules.controls.pages.media
import qs.modules.controls.pages.network
import qs.modules.controls.pages.notifications
import qs.modules.controls.pages.power
import qs.modules.controls.pages.updates
import qs.services

// Settings popup: menu of pages with live status, each page opens with a Back row
BrutalPopup {
    id: root

    property string page: ""

    readonly property var pages: [
        {
            id: "media",
            title: "Media",
            icon: Media.active && Media.active.isPlaying ? "" : "",
            status: Media.active ? (Media.active.trackTitle || Media.active.identity) : "",
            shown: Media.active !== null,
            alert: false
        },
        {
            id: "audio",
            title: "Audio",
            icon: Audio.volumeIcon(Audio.volume, Audio.muted),
            status: Audio.muted ? "muted" : Math.round(Audio.volume * 100) + "%",
            shown: true,
            alert: false
        },
        {
            id: "notifications",
            title: "Notifications",
            icon: Notifs.dnd ? "" : "",
            status: Notifs.unread > 0 ? Notifs.unread + " new" : (Notifs.dnd ? "do not disturb" : String(Notifs.history.length)),
            shown: true,
            alert: Notifs.unread > 0
        },
        {
            id: "clipboard",
            title: "Clipboard",
            icon: "",
            status: String(Clipboard.history.length),
            shown: true,
            alert: false
        },
        {
            id: "bluetooth",
            title: "Bluetooth",
            icon: "",
            status: bluetooth.status,
            shown: true,
            alert: false
        },
        {
            id: "network",
            title: "Network",
            icon: Net.icon,
            status: Net.summary,
            shown: true,
            alert: false
        },
        {
            id: "drives",
            title: "Drives",
            icon: "󰋊",
            status: Drives.summary,
            shown: true,
            alert: false
        },
        {
            id: "updates",
            title: "Updates",
            icon: "󰚰",
            status: Updates.checking ? "checking…" : (Updates.error !== "" ? "check failed" : (Updates.count > 0 ? Updates.count + " available" : "up to date")),
            shown: true,
            alert: false
        },
        {
            id: "power",
            title: "Battery",
            icon: "",
            status: (PowerSaver.active ? "saver on" : "") + (PowerSaver.active && power.count > 0 ? " · " : "") + (power.count > 0 ? power.count + (power.count === 1 ? " device" : " devices") : ""),
            shown: power.count > 0 || PowerSaver.battery,
            alert: false
        }
    ]

    readonly property var current: pages.find(p => p.id === page) ?? null

    function show(name) {
        page = name;
        if (!open)
            popup(null);
    }

    function togglePage(name) {
        if (open && page === name)
            closeRequested();
        else
            show(name);
    }

    function syncServices() {
        Audio.panelOpen = open && page === "audio";
        Net.scanning = open && page === "network";
        if (open && page === "notifications")
            Notifs.markRead();
    }

    title: current ? current.title : "Controls"
    layerName: "quickshell-settings"
    contentSpacing: Theme.spacing.sm

    onOpenChanged: {
        if (!open)
            page = "";
        syncServices();
    }
    onPageChanged: syncServices()

    Repeater {
        model: root.pages

        BrutalRow {
            required property var modelData
            visible: root.page === "" && modelData.shown
            icon: modelData.icon
            text: modelData.title
            trailing: modelData.status
            highlighted: modelData.alert
            hasChildren: true
            onClicked: root.page = modelData.id
        }
    }

    BrutalRow {
        visible: root.page !== ""
        icon: "‹"
        text: "Back"
        onClicked: root.page = ""
    }

    BrutalDivider {
        visible: root.page !== ""
    }

    ColumnLayout {
        visible: root.page === "audio"
        Layout.fillWidth: true

        AudioSection {}
    }

    ColumnLayout {
        visible: root.page === "network"
        Layout.fillWidth: true

        NetworkSection {}
    }

    ColumnLayout {
        visible: root.page === "drives"
        Layout.fillWidth: true

        DrivesSection {}
    }

    ColumnLayout {
        visible: root.page === "bluetooth"
        Layout.fillWidth: true

        BluetoothSection {
            id: bluetooth
            panelOpen: root.open && root.page === "bluetooth"
        }
    }

    ColumnLayout {
        visible: root.page === "media"
        Layout.fillWidth: true

        MediaSection {
            panelOpen: root.open && root.page === "media"
        }
    }

    ColumnLayout {
        visible: root.page === "notifications"
        Layout.fillWidth: true

        NotifSection {}
    }

    ColumnLayout {
        visible: root.page === "clipboard"
        Layout.fillWidth: true

        ClipboardSection {
            panelOpen: root.open && root.page === "clipboard"
            onCopied: root.closeRequested()
        }
    }

    ColumnLayout {
        visible: root.page === "updates"
        Layout.fillWidth: true

        UpdatesSection {}
    }

    // Loaded only if UPower exists, else it logs an error on launch
    ColumnLayout {
        visible: root.page === "power"
        Layout.fillWidth: true
        spacing: Theme.spacing.md

        PowerSaverSection {
            visible: PowerSaver.battery
        }

        Loader {
            id: power
            Layout.fillWidth: true
            active: false

            readonly property int count: item ? (item as PowerSection).devices.length : 0

            sourceComponent: PowerSection {}
        }
    }

    Process {
        running: true
        command: ["gdbus", "call", "--system", "--dest", "org.freedesktop.DBus", "--object-path", "/org/freedesktop/DBus", "--method", "org.freedesktop.DBus.ListActivatableNames"]
        stdout: StdioCollector {
            onStreamFinished: power.active = text.includes("org.freedesktop.UPower")
        }
    }
}
