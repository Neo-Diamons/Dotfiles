import QtQuick
import QtQuick.Layouts
import qs.config

// Settings page heading: icon badge, title, status and an optional switch
RowLayout {
    id: root

    property string icon: ""
    property string title: ""
    property string status: ""
    property bool showSwitch: false
    property bool checked: false

    signal toggled

    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    BrutalBadge {
        implicitWidth: implicitHeight
        text: root.icon
    }

    BrutalText {
        text: root.title.toUpperCase()
        font.bold: true
    }

    BrutalText {
        Layout.fillWidth: true
        text: root.status
        color: Colors.textMuted
        font.pixelSize: Theme.font.sizeSmall
        elide: Text.ElideRight
    }

    BrutalSwitch {
        visible: root.showSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
