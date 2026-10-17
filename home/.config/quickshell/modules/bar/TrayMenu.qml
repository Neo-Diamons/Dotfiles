pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config

// Tray item context menu, submenus open in place with a Back row
BrutalPopup {
    id: root

    property var menu: null
    property string appTitle: ""
    property var submenus: []

    readonly property var current: submenus.length > 0 ? submenus[submenus.length - 1] : menu

    function show(handle, name, item) {
        if (handle === menu && (open || justClosedFrom(item))) {
            toggle(item);
            return;
        }
        submenus = [];
        menu = handle;
        appTitle = name;
        popup(item);
    }

    title: submenus.length > 0 ? submenus[submenus.length - 1].text : appTitle
    layerName: "quickshell-traymenu"
    panelWidth: Theme.dims.trayMenuWidth
    contentMargins: Theme.spacing.xs
    contentSpacing: 0

    onOpenChanged: {
        if (!open)
            submenus = [];
    }

    QsMenuOpener {
        id: opener
        menu: root.current
    }

    BrutalRow {
        visible: root.submenus.length > 0
        rowHeight: Theme.dims.trayMenuItemHeight
        icon: "‹"
        text: "Back"
        onClicked: root.submenus = root.submenus.slice(0, -1)
    }

    Repeater {
        model: opener.children

        Item {
            id: entry
            required property var modelData

            Layout.fillWidth: true
            implicitHeight: modelData.isSeparator ? separator.implicitHeight + Theme.spacing.xs * 2 : row.implicitHeight

            BrutalDivider {
                id: separator
                visible: entry.modelData.isSeparator
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.shadow.sm
                implicitHeight: Theme.dims.traySeparatorHeight
                color: Colors.borderDefault
            }

            BrutalRow {
                id: row
                visible: !entry.modelData.isSeparator
                width: parent.width
                rowHeight: Theme.dims.trayMenuItemHeight
                enabled: entry.modelData.enabled
                text: entry.modelData.text
                iconSource: entry.modelData.icon
                checkable: entry.modelData.buttonType !== QsMenuButtonType.None
                radio: entry.modelData.buttonType === QsMenuButtonType.RadioButton
                checked: entry.modelData.checkState === Qt.Checked
                hasChildren: entry.modelData.hasChildren

                onClicked: {
                    if (entry.modelData.hasChildren) {
                        root.submenus = root.submenus.concat([entry.modelData]);
                    } else {
                        entry.modelData.triggered();
                        root.closeRequested();
                    }
                }
            }
        }
    }
}
