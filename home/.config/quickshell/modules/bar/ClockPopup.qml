import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

// Full date, live time and month calendar
BrutalPopup {
    id: root

    property date now: new Date()

    title: now.toLocaleDateString(Qt.locale(Config.locale), Config.dateFormat)
    layerName: "quickshell-clock"
    panelWidth: Theme.dims.calendarWidth

    onOpenChanged: {
        if (open) {
            now = new Date();
            calendar.reset();
        }
    }

    Timer {
        interval: 1000
        running: root.open
        repeat: true
        onTriggered: root.now = new Date()
    }

    BrutalText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatTime(root.now, Config.timeFormat)
        font.bold: true
        font.pixelSize: Theme.font.sizeHuge
    }

    BrutalDivider {}

    Calendar {
        id: calendar
        Layout.fillWidth: true
    }
}
