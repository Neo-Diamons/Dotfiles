import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

// Hours over minutes, click opens the calendar popup
Item {
    id: root

    property var screen

    property string hours: Qt.formatTime(new Date(), Config.barHourFormat)
    property string minutes: Qt.formatTime(new Date(), "mm")

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d = new Date();
            root.hours = Qt.formatTime(d, Config.barHourFormat);
            root.minutes = Qt.formatTime(d, "mm");
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 0

        BrutalText {
            Layout.alignment: Qt.AlignHCenter
            text: root.hours
            color: popup.open || area.containsMouse ? Colors.textAccent : Colors.textPrimary
            font.pixelSize: Theme.font.sizeClock
            font.bold: true
        }

        BrutalText {
            Layout.alignment: Qt.AlignHCenter
            text: root.minutes
            color: Colors.textAccent
            font.pixelSize: Theme.font.sizeClock
            font.bold: true
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.toggle(root)
    }

    ClockPopup {
        id: popup
        screen: root.screen
    }
}
