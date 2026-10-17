pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils

// Clipboard page: searchable history, click an entry to copy it again
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    property bool panelOpen: false

    readonly property var entries: {
        const q = search.text.toLowerCase();
        return q === "" ? Clipboard.history : Clipboard.history.filter(h => h.text.toLowerCase().includes(q));
    }

    signal copied

    onPanelOpenChanged: {
        if (panelOpen) {
            search.text = "";
            search.focusInput();
        }
    }

    SectionHeader {
        icon: ""
        title: "Clipboard"
        status: Clipboard.history.length + (Clipboard.history.length === 1 ? " item" : " items")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalInput {
            id: search
            Layout.fillWidth: true
            placeholder: "SEARCH"
            onAccepted: {
                if (root.entries.length > 0) {
                    Clipboard.copy(root.entries[0].text);
                    root.copied();
                }
            }
        }

        BrutalButton {
            visible: Clipboard.history.length > 0
            text: "Clear"
            onClicked: Clipboard.clear()
        }
    }

    BrutalText {
        visible: root.entries.length === 0
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.md
        Layout.bottomMargin: Theme.spacing.md
        horizontalAlignment: Text.AlignHCenter
        text: Clipboard.history.length === 0 ? "NOTHING COPIED YET" : "NO MATCH"
        color: Colors.textMuted
        font.bold: true
        font.pixelSize: Theme.font.sizeSmall
    }

    Repeater {
        model: root.entries

        RowLayout {
            id: entry
            required property var modelData
            required property int index

            readonly property var lines: modelData.text.trim().split("\n")

            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            BrutalRow {
                Layout.fillWidth: true
                text: entry.lines[0].trim()
                trailing: entry.lines.length > 1 ? "+" + (entry.lines.length - 1) + " lines" : TimeUtils.timeAgo(entry.modelData.time)
                highlighted: entry.modelData === Clipboard.history[0]
                onClicked: {
                    Clipboard.copy(entry.modelData.text);
                    root.copied();
                }
            }

            BrutalTile {
                size: Theme.dims.badgeHeight
                shadowOffset: 0
                ghost: true
                text: "✕"
                textSize: Theme.font.sizeSmall
                onLeftClicked: Clipboard.remove(entry.modelData.text)
            }
        }
    }
}
