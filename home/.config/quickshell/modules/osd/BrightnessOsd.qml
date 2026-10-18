import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services
import qs.utils

// Brightness OSD and handler of the brightness keys (`qs ipc call brightness increase` / `decrease`)
PanelWindow { // qmllint disable uncreatable-type
    id: root

    property bool shown: false

    readonly property real level: Brightness.level

    function icon(l) {
        return l < 0.34 ? "󰃝" : l < 0.67 ? "󰃟" : "󰃠";
    }

    Connections {
        target: Brightness
        function onUpdated() {
            root.shown = true;
            hideTimer.restart();
        }
    }

    IpcHandler {
        target: "brightness"

        function increase(): void {
            Brightness.increase();
        }
        function decrease(): void {
            Brightness.decrease();
        }
    }

    Timer {
        id: hideTimer
        interval: Config.osdTimeout
        onTriggered: root.shown = false
    }

    screen: ScreenUtils.focusedScreen
    visible: shown
    color: "transparent"

    anchors.bottom: true
    margins.bottom: Theme.dims.osdBottomMargin // qmllint disable missing-property

    implicitWidth: Theme.dims.osdWidth + Theme.shadow.lg
    implicitHeight: panel.implicitHeight

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    BrutalPanel {
        id: panel
        width: root.implicitWidth
        shadowOffset: Theme.shadow.lg

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.sm
            spacing: Theme.spacing.sm

            Rectangle {
                implicitWidth: Theme.dims.controlHeight
                implicitHeight: Theme.dims.controlHeight
                color: Colors.accent
                border.color: Colors.accent
                border.width: Theme.dims.borderWidthActive

                BrutalText {
                    anchors.centerIn: parent
                    text: root.icon(root.level)
                    color: Colors.bgBase
                    font.pixelSize: Theme.dims.iconSmall
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xs

                RowLayout {
                    Layout.fillWidth: true

                    BrutalText {
                        Layout.fillWidth: true
                        text: "BRIGHTNESS"
                        color: Colors.textPrimary
                        font.bold: true
                        font.pixelSize: Theme.font.sizeSmall
                    }

                    BrutalText {
                        text: Math.round(root.level * 100) + "%"
                        color: Colors.textMuted
                        font.bold: true
                        font.pixelSize: Theme.font.sizeSmall
                    }
                }

                BrutalProgress {
                    Layout.fillWidth: true
                    value: root.level
                    animated: true
                }
            }
        }
    }
}
