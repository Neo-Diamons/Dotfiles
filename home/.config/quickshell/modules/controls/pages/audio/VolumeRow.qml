import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

// Mute tile, volume slider and percentage
RowLayout {
    id: root

    property string icon: ""
    property real value: 0
    property bool muted: false

    signal muteToggled
    signal moved(real value)

    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    BrutalTile {
        size: Theme.dims.controlHeight
        text: root.icon
        dimmed: root.muted
        onLeftClicked: root.muteToggled()
    }

    BrutalSlider {
        id: slider
        Layout.fillWidth: true
        value: root.value
        dimmed: root.muted
        onMoved: v => root.moved(v)
    }

    BrutalText {
        Layout.preferredWidth: Theme.dims.valueLabelWidth
        horizontalAlignment: Text.AlignRight
        text: Math.round(slider.frac * 100) + "%"
        color: Colors.textMuted
        font.pixelSize: Theme.font.sizeSmall
        font.bold: true
    }
}
