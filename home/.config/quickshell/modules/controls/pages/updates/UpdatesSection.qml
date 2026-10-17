pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils

// Updates page: pending packages, refresh and update
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    SectionHeader {
        icon: "󰚰"
        title: "Updates"
        status: Updates.checking ? "checking…" : (Updates.lastCheck > 0 ? "checked " + TimeUtils.timeAgo(Updates.lastCheck) : "")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalText {
            Layout.fillWidth: true
            text: Updates.error !== "" ? "CHECK FAILED" : (Updates.count > 0 ? Updates.count + (Updates.count === 1 ? " PACKAGE" : " PACKAGES") : "UP TO DATE")
            color: Updates.error !== "" ? Colors.textAccent : Colors.textMuted
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
        }

        BrutalButton {
            icon: "󰑐"
            text: "Refresh"
            onClicked: Updates.refresh()
        }

        BrutalButton {
            visible: Updates.count > 0
            text: "Update"
            active: true
            onClicked: Updates.upgrade()
        }
    }

    BrutalText {
        visible: Updates.error !== ""
        Layout.fillWidth: true
        text: Updates.error
        color: Colors.textMuted
        font.pixelSize: Theme.font.sizeSmall
        wrapMode: Text.Wrap
    }

    Repeater {
        model: Updates.packages

        BrutalRow {
            required property var modelData
            text: modelData.name
            trailing: modelData.to
        }
    }
}
