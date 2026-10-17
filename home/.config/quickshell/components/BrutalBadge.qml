import QtQuick
import qs.config

// Small solid label with bold text
Rectangle {
    id: root

    property string text: ""
    property color fillColor: Colors.accent
    property color textColor: Colors.bgBase

    implicitWidth: label.implicitWidth + Theme.spacing.md
    implicitHeight: Theme.dims.badgeHeight
    color: fillColor

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.family: Theme.font.family
        font.bold: true
        font.pixelSize: Theme.font.sizeSmall
    }
}
