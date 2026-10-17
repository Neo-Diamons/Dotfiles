import QtQuick
import QtQuick.Layouts
import qs.config

// Footer strip with keyboard hints, extra items on the right
Rectangle {
    id: root

    property string text: ""
    property bool centered: false

    default property alias extras: row.data

    Layout.fillWidth: true
    implicitHeight: Theme.dims.footerHeight
    color: Colors.bgBase

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        spacing: Theme.spacing.sm

        BrutalText {
            Layout.fillWidth: true
            horizontalAlignment: root.centered ? Text.AlignHCenter : Text.AlignLeft
            text: root.text
            color: Colors.textMuted
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
            elide: Text.ElideRight
        }
    }
}
