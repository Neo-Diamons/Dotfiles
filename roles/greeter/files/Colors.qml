pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string themeDir: "/var/lib/quickshell-greeter"

    function pick(name, fallback) {
        const value = theme.adapter.colors[name]; // qmllint disable unresolved-type
        return typeof value === "string" && /^#[0-9a-fA-F]{6,8}$/.test(value) ? value : fallback;
    }

    readonly property string wallpaper: {
        const path = theme.adapter.wallpaper; // qmllint disable unresolved-type
        return typeof path === "string" && path.startsWith(themeDir + "/") && path.indexOf("..") < 0 ? path : "";
    }

    readonly property color bgBase: pick("bgBase", "#1e1a29")
    readonly property color bgSurface: pick("bgSurface", "#262035")
    readonly property color bgOverlay: pick("bgOverlay", "#2e2840")
    readonly property color bgActive: pick("bgActive", "#3a3050")
    readonly property color bgHover: pick("bgHover", "#383250")

    readonly property color accent: pick("accent", "#b48ead")
    readonly property color borderMuted: pick("borderMuted", "#2e2840")
    readonly property color borderDefault: pick("borderDefault", "#383250")
    readonly property color borderFocused: pick("borderFocused", "#b48ead")
    readonly property color borderActive: pick("borderActive", "#ebcb8b")

    readonly property color textPrimary: pick("textPrimary", "#e5e0f0")
    readonly property color textAccent: pick("textAccent", "#b48ead")
    readonly property color textMuted: pick("textMuted", "#8a84a0")
    readonly property color textSubtle: pick("textSubtle", "#b0aac5")

    readonly property color urgent: pick("urgent", "#bf616a")
    readonly property color warning: pick("warning", "#ebcb8b")
    readonly property color info: pick("info", "#88c0d0")

    FileView {
        id: theme
        path: root.themeDir + "/theme.json"
        blockLoading: true
        printErrors: false

        adapter: JsonAdapter { // qmllint disable unresolved-type
            property string wallpaper: ""
            property var colors: ({})
        }
    }
}
