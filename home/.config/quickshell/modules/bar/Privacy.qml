import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.config

// Bar markers while the microphone or the screen / camera is captured
ColumnLayout {
    id: root
    spacing: Theme.spacing.xs

    readonly property var nodes: Pipewire.nodes.values // qmllint disable missing-property

    function prop(n, key) {
        return n.properties ? (n.properties[key] || "") : "";
    }

    // Ignore peak meters and desktop-audio capture
    readonly property var micUsers: nodes.filter(n => n.type === PwNodeType.AudioInStream && prop(n, "stream.monitor") !== "true" && prop(n, "stream.capture.sink") !== "true")

    readonly property var videoUsers: nodes.filter(n => prop(n, "media.class") === "Stream/Input/Video" || prop(n, "node.name").startsWith("xdph"))

    visible: micUsers.length > 0 || videoUsers.length > 0

    BrutalTile {
        visible: root.micUsers.length > 0
        Layout.alignment: Qt.AlignHCenter
        selected: true
        text: "󰍬"
        textSize: Theme.dims.iconSmall
    }

    BrutalTile {
        visible: root.videoUsers.length > 0
        Layout.alignment: Qt.AlignHCenter
        selected: true
        text: "󰍹"
        textSize: Theme.dims.iconSmall
    }
}
