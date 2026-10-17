pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.modules.notifications
import qs.services

// Notifications page: do not disturb and history
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalText {
            text: "DO NOT DISTURB"
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
        }

        BrutalSwitch {
            checked: Notifs.dnd
            onToggled: Notifs.dnd = !Notifs.dnd
        }

        Item {
            Layout.fillWidth: true
        }

        BrutalButton {
            visible: Notifs.history.length > 0
            text: "Clear"
            onClicked: Notifs.clear()
        }
    }

    BrutalText {
        visible: Notifs.history.length === 0
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.md
        Layout.bottomMargin: Theme.spacing.md
        horizontalAlignment: Text.AlignHCenter
        text: "NO NOTIFICATIONS"
        color: Colors.textMuted
        font.bold: true
        font.pixelSize: Theme.font.sizeSmall
    }

    Repeater {
        model: Notifs.history

        HistoryItem {}
    }
}
