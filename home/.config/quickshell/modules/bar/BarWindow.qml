import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config

// Vertical bar on the right edge: workspaces, privacy markers, tray, settings cog and clock
PanelWindow { // qmllint disable uncreatable-type
    id: barWindow

    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: Theme.dims.barWidth
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Auto

    Rectangle {
        anchors.fill: parent
        radius: Theme.dims.radius
        color: Colors.bgSurface

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: Theme.spacing.sm
            anchors.bottomMargin: Theme.spacing.sm
            spacing: Theme.spacing.md

            Workspaces {}

            Item {
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                spacing: Theme.spacing.xs

                Privacy {
                    Layout.alignment: Qt.AlignHCenter
                }

                Tray {
                    screen: barWindow.screen
                    Layout.alignment: Qt.AlignHCenter
                }

                SettingsButton {
                    screen: barWindow.screen
                    Layout.alignment: Qt.AlignHCenter
                }

                Clock {
                    screen: barWindow.screen
                    Layout.topMargin: Theme.spacing.sm
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
