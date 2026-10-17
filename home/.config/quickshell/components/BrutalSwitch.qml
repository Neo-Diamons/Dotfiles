import QtQuick
import qs.config

// On/off toggle with a square knob
Rectangle {
    id: root

    property bool checked: false
    property color accentColor: Colors.accent

    signal toggled

    readonly property int inset: Theme.dims.borderWidthActive * 2

    implicitWidth: Theme.dims.switchWidth
    implicitHeight: Theme.dims.switchHeight
    radius: Theme.dims.radius
    color: checked ? accentColor : Colors.bgBase
    border.color: checked || area.containsMouse ? accentColor : Colors.borderDefault
    border.width: Theme.dims.borderWidthActive

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.fast
        }
    }

    Rectangle {
        width: height
        height: parent.height - root.inset * 2
        y: root.inset
        x: root.checked ? parent.width - width - root.inset : root.inset
        color: root.checked ? Colors.bgBase : Colors.textMuted

        Behavior on x {
            NumberAnimation {
                duration: Theme.anim.fast
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
