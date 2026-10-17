import QtQuick
import qs.config

// Horizontal 0–1 slider, set by drag, click or wheel
Item {
    id: root

    property real value: 0
    property real wheelStep: 0.05
    property bool dimmed: false
    property color accentColor: Colors.accent

    readonly property real frac: Math.max(0, Math.min(1, value))

    signal moved(real value)

    implicitHeight: thumb.height

    BrutalProgress {
        id: track
        anchors.verticalCenter: thumb.verticalCenter
        width: root.width - thumb.shadowOffset
        value: width > 0 ? (thumb.x + Theme.dims.sliderThumb / 2) / width : 0
        dimmed: root.dimmed
        accentColor: root.accentColor
    }

    BrutalSurface {
        id: thumb
        width: Theme.dims.sliderThumb + shadowOffset
        height: Theme.dims.sliderThumb + shadowOffset
        x: (root.width - width) * root.frac
        pressed: area.pressed
        fillColor: Colors.textPrimary
        borderColor: root.dimmed ? Colors.borderDefault : root.accentColor
        borderWidth: Theme.dims.borderWidthActive
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function setFrom(px) {
            root.moved(Math.max(0, Math.min(1, px / track.width)));
        }

        onPressed: mouse => setFrom(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                setFrom(mouse.x);
        }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? root.wheelStep : -root.wheelStep))))
    }
}
