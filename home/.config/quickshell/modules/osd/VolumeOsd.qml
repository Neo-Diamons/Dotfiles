import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services
import qs.utils

// Volume / microphone OSD, shown on any change
PanelWindow { // qmllint disable uncreatable-type
    id: root

    property bool shown: false
    property bool showMic: false
    property bool armed: false   // PipeWire reports values on startup / device switch

    readonly property real level: showMic ? Audio.micVolume : Audio.volume
    readonly property bool isMuted: showMic ? Audio.micMuted : Audio.muted

    function show(isMic) {
        if (!armed || Audio.panelOpen)
            return;
        showMic = isMic;
        shown = true;
        hideTimer.restart();
    }

    function rearm() {
        armed = false;
        armTimer.restart();
    }

    Component.onCompleted: rearm()

    Connections {
        target: Audio
        function onVolumeChanged() {
            root.show(false);
        }
        function onMutedChanged() {
            root.show(false);
        }
        function onMicMutedChanged() {
            root.show(true);
        }
        function onSinkChanged() {
            root.rearm();
        }
        function onSourceChanged() {
            root.rearm();
        }
    }

    Timer {
        id: armTimer
        interval: 1000
        onTriggered: root.armed = true
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
                color: root.isMuted ? Colors.bgBase : Colors.accent
                border.color: root.isMuted ? Colors.borderDefault : Colors.accent
                border.width: Theme.dims.borderWidthActive

                BrutalText {
                    anchors.centerIn: parent
                    text: root.showMic ? Audio.micIcon(root.isMuted) : Audio.volumeIcon(root.level, root.isMuted)
                    color: root.isMuted ? Colors.textMuted : Colors.bgBase
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
                        text: (root.showMic ? "Microphone" : "Volume").toUpperCase() + (root.isMuted ? " · MUTED" : "")
                        color: root.isMuted ? Colors.textMuted : Colors.textPrimary
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
                    dimmed: root.isMuted
                    animated: true
                }
            }
        }
    }
}
