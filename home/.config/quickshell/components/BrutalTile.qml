import QtQuick
import qs.config

// Square clickable tile with a glyph or short text and an optional corner badge
//   selected → accent fill, raised
//   ghost    → flat outline until hovered (e.g. empty workspace)
//   dimmed   → content faded (e.g. muted / off)
BrutalSurface {
    id: root

    property string text: ""
    property int size: Theme.dims.tileBoxSize
    property int textSize: Theme.font.sizeNormal
    property bool selected: false
    property bool ghost: false
    property bool dimmed: false
    property bool badge: false
    property color accentColor: Colors.accent

    readonly property bool hovered: area.containsMouse
    readonly property bool idleGhost: ghost && !selected && !hovered

    signal leftClicked
    signal rightClicked
    signal middleClicked
    signal scrolled(int delta)

    implicitWidth: size + shadowOffset
    implicitHeight: size + shadowOffset

    flat: idleGhost
    pressed: area.pressed
    fillColor: selected ? accentColor : (idleGhost ? "transparent" : (hovered ? Colors.bgHover : Colors.bgOverlay))
    borderColor: selected || hovered ? accentColor : (idleGhost ? Colors.borderMuted : Colors.borderDefault)
    borderWidth: selected || hovered ? Theme.dims.borderWidthActive : Theme.dims.borderWidth

    Text {
        anchors.centerIn: parent
        visible: root.text !== ""
        text: root.text
        color: root.selected ? Colors.bgBase : (root.idleGhost ? Colors.textMuted : Colors.textPrimary)
        opacity: root.dimmed ? Theme.dimOpacity : 1.0
        font.family: Theme.font.family
        font.bold: true
        font.pixelSize: root.textSize
    }

    Rectangle {
        visible: root.badge
        width: Theme.dims.badgeDot
        height: Theme.dims.badgeDot
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.spacing.xs
        color: root.selected ? Colors.bgBase : root.accentColor
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.leftClicked();
            else if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
        }

        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }
}
