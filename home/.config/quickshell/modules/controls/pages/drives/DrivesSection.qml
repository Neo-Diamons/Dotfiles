pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

// Drives page: removable drives (internal ones on demand) with mount / open / unmount / eject
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    SectionHeader {
        icon: "󰋊"
        title: "Drives"
        status: Drives.summary
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalText {
            Layout.fillWidth: true
            text: "SHOW INTERNAL"
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
        }

        BrutalSwitch {
            checked: Drives.showInternal
            onToggled: Drives.showInternal = !Drives.showInternal
        }
    }

    BrutalText {
        visible: Drives.shown.length === 0
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.md
        Layout.bottomMargin: Theme.spacing.md
        horizontalAlignment: Text.AlignHCenter
        text: "NO EXTERNAL DRIVE"
        color: Colors.textMuted
        font.bold: true
        font.pixelSize: Theme.font.sizeSmall
    }

    Repeater {
        model: Drives.shown

        DriveItem {}
    }

    BrutalText {
        visible: Drives.error !== ""
        Layout.fillWidth: true
        text: Drives.error
        color: Colors.textAccent
        font.pixelSize: Theme.font.sizeSmall
        wrapMode: Text.Wrap
    }
}
