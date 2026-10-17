import QtQuick
import QtQuick.Layouts
import qs.config

// Accent title strip for panels and cards, with an optional close button
Rectangle {
    id: root

    property string title: ""
    property bool closable: false
    property color accentColor: Colors.accent

    signal closeClicked

    Layout.fillWidth: true
    implicitHeight: Theme.dims.headerStrip
    color: accentColor

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: root.closable ? 0 : Theme.spacing.sm
        spacing: Theme.spacing.sm

        BrutalText {
            Layout.fillWidth: true
            text: root.title.toUpperCase()
            color: Colors.bgBase
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
            elide: Text.ElideRight
        }

        Rectangle {
            visible: root.closable
            Layout.fillHeight: true
            implicitWidth: height
            color: closeArea.containsMouse ? Colors.bgBase : "transparent"

            BrutalText {
                anchors.centerIn: parent
                text: "✕"
                color: closeArea.containsMouse ? root.accentColor : Colors.bgBase
                font.bold: true
                font.pixelSize: Theme.font.sizeSmall
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeClicked()
            }
        }
    }
}
