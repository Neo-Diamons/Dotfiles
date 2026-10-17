pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

// Month grid with previous / next, clicking the title returns to today
ColumnLayout {
    id: root

    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    readonly property var dateLocale: Qt.locale(Config.locale)
    readonly property int firstDay: dateLocale.firstDayOfWeek % 7

    // 6×7 grid from the locale's first weekday
    readonly property var cells: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() - firstDay + 7) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(year, month, 1 - offset + i);
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === month,
                isToday: d.toDateString() === today.toDateString()
            });
        }
        return out;
    }

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    function reset() {
        today = new Date();
        year = today.getFullYear();
        month = today.getMonth();
    }

    spacing: Theme.spacing.sm

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalTile {
            size: Theme.dims.controlHeight
            text: "‹"
            onLeftClicked: root.shift(-1)
        }

        BrutalText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.dateLocale.standaloneMonthName(root.month).toUpperCase() + " " + root.year
            color: titleArea.containsMouse ? Colors.textAccent : Colors.textPrimary
            font.bold: true

            MouseArea {
                id: titleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.reset()
            }
        }

        BrutalTile {
            size: Theme.dims.controlHeight
            text: "›"
            onLeftClicked: root.shift(1)
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: Theme.spacing.xxs
        columnSpacing: Theme.spacing.xxs

        Repeater {
            model: 7

            BrutalText {
                required property int index
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.dateLocale.dayName((root.firstDay + index) % 7, Locale.ShortFormat).slice(0, 2).toUpperCase()
                color: Colors.textMuted
                font.bold: true
                font.pixelSize: Theme.font.sizeSmall
            }
        }

        Repeater {
            model: root.cells

            Rectangle {
                id: cell
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: Theme.dims.calendarCell
                color: modelData.isToday ? Colors.accent : "transparent"
                border.color: modelData.isToday ? Colors.accent : "transparent"
                border.width: Theme.dims.borderWidthActive

                BrutalText {
                    anchors.centerIn: parent
                    text: cell.modelData.day
                    color: cell.modelData.isToday ? Colors.bgBase : (cell.modelData.inMonth ? Colors.textPrimary : Colors.textMuted)
                    opacity: cell.modelData.inMonth ? 1.0 : Theme.dimOpacity
                    font.bold: cell.modelData.isToday
                }
            }
        }
    }
}
