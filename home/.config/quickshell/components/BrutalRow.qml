import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config

// List / menu row with icon, label and trailing status, flat until hovered
//   highlighted → raised with an accent border (the active device, the connected network)
//   selected    → solid accent block (the keyboard cursor in the launcher)
BrutalSurface {
    id: root

    property string icon: ""
    property string iconSource: ""
    property string text: ""
    property string trailing: ""
    property bool highlighted: false
    property bool selected: false
    property bool iconFramed: false
    property int iconSize: Theme.dims.iconSmall
    property string iconFallback: ""
    property bool checkable: false
    property bool radio: false
    property bool checked: false
    property bool hasChildren: false
    property int rowHeight: Theme.dims.rowHeight

    readonly property bool hovered: area.containsMouse

    readonly property string resolvedIcon: {
        let s = root.iconSource || "";
        if (!s || s.startsWith("image://"))
            return s;
        s = s.replace(/^file:\/\//, "");
        return s.startsWith("/") ? "file://" + s : (Quickshell.iconPath(s, true) || "");
    }

    signal clicked

    Layout.fillWidth: true
    implicitHeight: rowHeight + shadowOffset
    opacity: enabled ? 1.0 : Theme.dimOpacity

    readonly property color textColor: selected ? Colors.bgBase : Colors.textPrimary

    flat: !highlighted && !selected && !hovered
    pressed: area.pressed
    fillColor: selected ? Colors.accent : (hovered ? Colors.bgHover : (highlighted ? Colors.bgOverlay : "transparent"))
    borderColor: selected || highlighted ? Colors.accent : (hovered ? Colors.borderDefault : "transparent")
    borderWidth: selected || highlighted ? Theme.dims.borderWidthActive : Theme.dims.borderWidth

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.xs
        spacing: Theme.spacing.sm

        Rectangle {
            visible: root.checkable
            implicitWidth: Theme.dims.checkSize
            implicitHeight: Theme.dims.checkSize
            color: Colors.bgBase
            border.color: root.checked ? Colors.accent : Colors.borderDefault
            border.width: Theme.dims.borderWidthActive

            Rectangle {
                anchors.fill: parent
                anchors.margins: root.radio ? Theme.dims.borderWidthActive * 2 : Theme.dims.borderWidthActive
                visible: root.checked
                color: Colors.accent
            }
        }

        BrutalIcon {
            visible: root.iconFramed
            size: root.iconSize
            padding: Theme.dims.iconBoxPadding
            source: root.iconSource
            fallback: root.iconFallback
            fillColor: root.selected ? Colors.bgBase : Colors.bgOverlay
            borderColor: root.selected ? Colors.bgBase : Colors.borderDefault
            fallbackColor: root.selected ? Colors.accent : Colors.textMuted
        }

        IconImage {
            visible: !root.iconFramed && root.resolvedIcon !== "" && status === Image.Ready
            implicitSize: root.iconSize
            source: root.iconFramed ? "" : root.resolvedIcon
        }

        BrutalText {
            visible: !root.iconFramed && root.icon !== "" && root.resolvedIcon === ""
            text: root.icon
            color: root.selected ? Colors.bgBase : (root.highlighted ? Colors.textAccent : Colors.textPrimary)
        }

        BrutalText {
            Layout.fillWidth: true
            text: root.text
            color: root.textColor
            font.bold: root.highlighted || root.selected
            elide: Text.ElideRight
        }

        BrutalBadge {
            visible: root.trailing !== "" && root.highlighted
            text: root.trailing.toUpperCase()
        }

        BrutalText {
            visible: root.trailing !== "" && !root.highlighted
            Layout.maximumWidth: root.width * Theme.dims.trailingMaxRatio
            text: root.trailing
            color: root.selected ? Colors.bgBase : Colors.textMuted
            font.pixelSize: Theme.font.sizeSmall
            elide: Text.ElideRight
        }

        BrutalText {
            visible: root.hasChildren
            text: "›"
            color: root.selected ? Colors.bgBase : (root.hovered ? Colors.textAccent : Colors.textMuted)
            font.bold: true
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
