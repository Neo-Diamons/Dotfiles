import QtQuick
import qs.config

// Button with an optional icon and uppercase text, square when icon-only
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property bool active: false
    property bool flat: false
    property color accentColor: Colors.accent

    signal clicked

    readonly property bool hot: hover.hovered || active

    readonly property color idleFill: flat ? "transparent" : Colors.bgOverlay
    readonly property color idleText: flat ? Colors.bgBase : Colors.textPrimary
    readonly property color hotFill: flat ? Colors.bgBase : accentColor
    readonly property color hotText: flat ? accentColor : Colors.bgBase

    implicitHeight: Theme.dims.controlHeight
    implicitWidth: text === "" ? implicitHeight : row.implicitWidth + Theme.spacing.md * 2

    radius: Theme.dims.radius
    color: hot ? hotFill : idleFill
    border.width: Theme.dims.borderWidth
    border.color: flat ? "transparent" : (hot ? accentColor : Colors.borderDefault)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.xs

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.hot ? root.hotText : root.idleText
            font.family: Theme.font.family
            font.bold: true
            font.pixelSize: Theme.font.sizeNormal
        }

        Text {
            visible: root.text !== ""
            text: root.text.toUpperCase()
            color: root.hot ? root.hotText : root.idleText
            font.family: Theme.font.family
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
