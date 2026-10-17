pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.config

// Session menu: lock, log out, suspend, reboot, shut down (`qs ipc call power`)
Scope {
    id: root

    property bool isOpen: false
    property int selectedIndex: 0
    property int pendingIndex: -1
    property int remaining: 0

    readonly property var actions: [
        {
            label: "Lock",
            icon: "",
            key: Qt.Key_L,
            hint: "L",
            command: ["qs", "ipc", "call", "lock", "lock"]
        },
        {
            label: "Log out",
            icon: "",
            key: Qt.Key_E,
            hint: "E",
            command: ["sh", "-c", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"]
        },
        {
            label: "Suspend",
            icon: "",
            key: Qt.Key_S,
            hint: "S",
            command: ["systemctl", "suspend"]
        },
        {
            label: "Reboot",
            icon: "",
            key: Qt.Key_R,
            hint: "R",
            command: ["systemctl", "reboot"]
        },
        {
            label: "Shut down",
            icon: "",
            key: Qt.Key_P,
            hint: "P",
            command: ["systemctl", "poweroff"],
            delay: 30
        }
    ]

    function toggle() {
        root.isOpen = !root.isOpen;
        if (root.isOpen)
            root.selectedIndex = 0;
    }

    function close() {
        countdown.stop();
        root.pendingIndex = -1;
        root.isOpen = false;
    }

    function execute(index) {
        const action = root.actions[index];
        root.close();
        Quickshell.execDetached(action.command);
    }

    function run(index) {
        if (root.pendingIndex >= 0) {
            if (index === root.pendingIndex)
                root.execute(index);
            return;
        }
        const action = root.actions[index];
        if (!action.delay) {
            root.execute(index);
            return;
        }
        root.selectedIndex = index;
        root.pendingIndex = index;
        root.remaining = action.delay;
        countdown.restart();
    }

    Timer {
        id: countdown

        interval: 1000
        repeat: true
        onTriggered: {
            root.remaining--;
            if (root.remaining <= 0)
                root.execute(root.pendingIndex);
        }
    }

    function move(step) {
        if (root.pendingIndex >= 0)
            return;
        root.selectedIndex = (root.selectedIndex + step + root.actions.length) % root.actions.length;
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            if (!root.isOpen)
                root.toggle();
        }
        function close(): void {
            root.close();
        }
    }

    BrutalModal {
        open: root.isOpen
        exclusiveFocus: true
        frame: panel
        layerName: "quickshell-power"
        onCloseRequested: root.close()

        Item {
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down || event.key === Qt.Key_J || event.key === Qt.Key_Tab) {
                    root.move(1);
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K || event.key === Qt.Key_Backtab) {
                    root.move(-1);
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.run(root.selectedIndex);
                } else {
                    const index = root.actions.findIndex(a => a.key === event.key);
                    if (index < 0)
                        return;
                    root.run(index);
                }
                event.accepted = true;
            }

            BrutalPanel {
                id: panel
                anchors.centerIn: parent
                width: Theme.dims.launcherWidth * 0.6 + shadowOffset

                BrutalHeader {
                    title: "Session"
                    closable: true
                    onCloseClicked: root.close()
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: Theme.spacing.sm
                    spacing: Theme.spacing.xxs

                    Repeater {
                        model: root.actions

                        BrutalRow {
                            required property var modelData
                            required property int index

                            selected: root.selectedIndex === index
                            icon: modelData.icon
                            text: modelData.label
                            trailing: root.pendingIndex === index ? root.remaining + "s" : modelData.hint
                            highlighted: root.pendingIndex === index

                            onClicked: root.run(index)
                        }
                    }
                }

                BrutalHintBar {
                    text: root.pendingIndex >= 0 ? "ENTER NOW · ESC CANCEL" : "↑↓ MOVE · ENTER SELECT · ESC CLOSE"
                    centered: true
                }
            }
        }
    }
}
