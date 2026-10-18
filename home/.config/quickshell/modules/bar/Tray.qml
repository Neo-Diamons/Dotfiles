pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.components
import qs.config
import qs.services

// System tray icons: left click activates, middle click secondary action, right click opens the menu
ColumnLayout {
    id: root
    spacing: Theme.spacing.xs
    Layout.alignment: Qt.AlignHCenter

    property var screen

    TrayMenu {
        id: trayMenu
        screen: root.screen
    }

    Repeater {
        model: SystemTray.items

        BrutalTile {
            id: trayBox
            required property var modelData

            Layout.alignment: Qt.AlignHCenter
            selected: trayMenu.open && trayMenu.menu === modelData.menu

            onLeftClicked: modelData.activate()
            onMiddleClicked: modelData.secondaryActivate()
            onRightClicked: {
                if (modelData.hasMenu)
                    trayMenu.show(modelData.menu, modelData.tooltipTitle || modelData.title || modelData.id, trayBox);
                else
                    modelData.secondaryActivate();
            }

            // "image://icon/steam_tray_mono?path=..." -> "steam_tray_mono"
            readonly property string iconName: {
                const m = (trayBox.modelData.icon || "").match(/^image:\/\/icon\/([^?]+)/);
                return m ? m[1] : "";
            }

            readonly property string themedIcon: TrayIcons.icons[TrayIcons.key(trayBox.modelData, trayBox.iconName)] ?? ""

            Component.onCompleted: TrayIcons.request(trayBox.modelData, trayBox.iconName)
            onIconNameChanged: TrayIcons.request(trayBox.modelData, trayBox.iconName)

            Image {
                anchors.centerIn: parent
                width: Theme.dims.iconSmall
                height: Theme.dims.iconSmall
                sourceSize.width: Theme.dims.iconSmall
                sourceSize.height: Theme.dims.iconSmall
                source: trayBox.themedIcon || trayBox.modelData.icon || ""
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
