import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config

// Framed icon from a URL, path or theme name, with a text fallback
Rectangle {
    id: root

    property string source: ""

    property string fallback: "󰘔"
    property int size: Theme.dims.notifIconSize
    property int padding: Theme.spacing.xs

    property color fillColor: Colors.bgBase
    property color borderColor: Colors.borderDefault
    property color fallbackColor: Colors.accent

    implicitWidth: size
    implicitHeight: size
    radius: Theme.dims.radius
    color: fillColor
    border.color: borderColor
    border.width: Theme.dims.borderWidth

    readonly property string resolved: {
        let s = root.source || "";
        if (!s)
            return "";

        if (s.startsWith("image://"))
            return s;

        s = s.replace(/^file:\/\//, "");
        if (s.startsWith("/"))
            return "file://" + s;

        return Quickshell.iconPath(s, true) || "";
    }

    IconImage {
        id: img
        anchors.centerIn: parent
        width: parent.width - root.padding * 2
        height: parent.height - root.padding * 2
        source: root.resolved
    }

    Text {
        anchors.centerIn: parent
        visible: img.status !== Image.Ready
        text: root.fallback
        color: root.fallbackColor
        font.family: Theme.font.family
        font.bold: true
        font.pixelSize: Math.round(root.size * Theme.dims.iconFallbackScale)
    }
}
