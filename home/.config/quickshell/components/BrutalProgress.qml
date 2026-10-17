import QtQuick
import qs.config

// Horizontal bar filled from 0 to 1
Rectangle {
    id: root

    property real value: 0
    property bool dimmed: false
    property bool bordered: true
    property bool animated: false
    property color accentColor: Colors.accent

    readonly property real frac: Math.max(0, Math.min(1, value))
    readonly property int inset: bordered ? border.width : 0

    implicitHeight: bordered ? Theme.dims.sliderTrack : Theme.dims.progressHeight
    radius: Theme.dims.radius
    color: Colors.bgBase
    border.color: Colors.borderDefault
    border.width: bordered ? Theme.dims.borderWidth : 0

    Rectangle {
        x: root.inset
        y: root.inset
        height: root.height - root.inset * 2
        width: (root.width - root.inset * 2) * root.frac
        color: root.dimmed ? Colors.borderDefault : root.accentColor

        Behavior on width {
            enabled: root.animated
            NumberAnimation {
                duration: Theme.anim.fast
            }
        }
    }
}
