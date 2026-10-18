pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

Scope {
    id: root

    property bool dimmed: false

    IpcHandler {
        target: "dim"

        function on(): void {
            root.dimmed = true;
        }

        function off(): void {
            root.dimmed = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow { // qmllint disable uncreatable-type
            required property var modelData

            screen: modelData
            visible: veil.opacity > 0
            color: "transparent"
            mask: Region {}
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-dim"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                id: veil
                anchors.fill: parent
                color: "#000000"
                opacity: root.dimmed ? Config.idleDimOpacity : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.slide
                    }
                }
            }
        }
    }
}
