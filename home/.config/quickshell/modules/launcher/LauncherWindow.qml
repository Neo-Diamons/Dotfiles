pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.config

// App launcher: search, paged list, keyboard navigation (`qs ipc call launcher`)
Scope {
    id: launcherScope

    property bool isOpen: false
    property var allApps: []
    property var searchMatches: []
    property int selectedIndex: 0

    readonly property int pageSize: Config.launcherPageSize
    property int currentPage: 0
    readonly property int totalPages: Math.max(1, Math.ceil(searchMatches.length / pageSize))

    readonly property string terminal: Config.terminal

    readonly property var filteredApps: {
        var start = currentPage * pageSize;
        return searchMatches.slice(start, start + pageSize);
    }

    function toggle() {
        launcherScope.isOpen = !launcherScope.isOpen;
        if (launcherScope.isOpen) {
            searchInput.text = "";
            launcherScope.updateFilter("");
            searchInput.focusInput();
        }
    }

    function hide() {
        launcherScope.isOpen = false;
    }

    function launchApp(app) {
        if (!app)
            return;

        var execCmd = app.exec.replace(/%[a-zA-Z]/g, "").trim();
        if (app.terminal)
            execCmd = `${terminal} -e ${execCmd}`;

        Quickshell.execDetached(["sh", "-c", execCmd]);

        launcherScope.hide();
    }

    function updateFilter(query) {
        var q = (query || "").toLowerCase().trim();
        if (q === "") {
            launcherScope.searchMatches = launcherScope.allApps;
        } else {
            launcherScope.searchMatches = launcherScope.allApps.filter(app => {
                return (app.name && app.name.toLowerCase().includes(q)) || (app.exec && app.exec.toLowerCase().includes(q));
            });
        }
        launcherScope.currentPage = 0;
        launcherScope.selectedIndex = 0;
    }

    function nextPage() {
        if (currentPage < totalPages - 1) {
            currentPage++;
            selectedIndex = 0;
        }
    }

    function prevPage() {
        if (currentPage > 0) {
            currentPage--;
            selectedIndex = 0;
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherScope.toggle();
        }
        function open(): void {
            if (!launcherScope.isOpen)
                launcherScope.toggle();
        }
        function close(): void {
            launcherScope.hide();
        }
    }

    Process {
        id: indexProc
        running: true
        command: ["python3", Quickshell.shellDir + "/scripts/applications.py", "list"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    launcherScope.allApps = JSON.parse(data.trim());
                    launcherScope.updateFilter("");
                } catch (err) {
                    console.error("Failed to parse app JSON:", err);
                }
            }
        }
    }

    BrutalModal {
        open: launcherScope.isOpen
        exclusiveFocus: true
        frame: mainBox
        layerName: "quickshell-launcher"
        onCloseRequested: launcherScope.hide()

        BrutalPanel {
            id: mainBox
            anchors.centerIn: parent
            width: Theme.dims.launcherWidth + shadowOffset

            BrutalInput {
                id: searchInput
                Layout.fillWidth: true
                focus: true
                framed: false
                prompt: ">"
                placeholder: "SEARCH APPS"
                fieldHeight: Theme.dims.launcherItemHeight + Theme.spacing.sm

                onTextChanged: launcherScope.updateFilter(text)

                onAccepted: {
                    if (launcherScope.filteredApps.length > 0)
                        launcherScope.launchApp(launcherScope.filteredApps[launcherScope.selectedIndex]);
                }

                // Unused keys bubble up here; Escape reaches the modal
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) {
                        if (launcherScope.filteredApps.length > 0) {
                            if (launcherScope.selectedIndex + 1 < launcherScope.filteredApps.length) {
                                launcherScope.selectedIndex++;
                            } else if (launcherScope.currentPage + 1 < launcherScope.totalPages) {
                                launcherScope.nextPage();
                            } else {
                                launcherScope.currentPage = 0;
                                launcherScope.selectedIndex = 0;
                            }
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        if (launcherScope.filteredApps.length > 0) {
                            if (launcherScope.selectedIndex > 0) {
                                launcherScope.selectedIndex--;
                            } else if (launcherScope.currentPage > 0) {
                                launcherScope.currentPage--;
                                launcherScope.selectedIndex = launcherScope.filteredApps.length - 1;
                            } else {
                                launcherScope.currentPage = launcherScope.totalPages - 1;
                                launcherScope.selectedIndex = launcherScope.filteredApps.length - 1;
                            }
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageDown) {
                        launcherScope.nextPage();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageUp) {
                        launcherScope.prevPage();
                        event.accepted = true;
                    }
                }
            }

            BrutalDivider {}

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: (Theme.dims.launcherItemHeight + Theme.shadow.sm) * launcherScope.pageSize + Theme.spacing.xxs * (launcherScope.pageSize - 1) + Theme.spacing.sm * 2

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.spacing.sm
                    spacing: Theme.spacing.xxs

                    Repeater {
                        model: launcherScope.filteredApps

                        BrutalRow {
                            required property var modelData
                            required property int index

                            rowHeight: Theme.dims.launcherItemHeight
                            selected: launcherScope.selectedIndex === index
                            iconFramed: true
                            iconSize: Theme.dims.launcherIconSize
                            iconSource: modelData.iconFile
                            iconFallback: modelData.name ? modelData.name.charAt(0).toUpperCase() : "󰘔"
                            text: modelData.name

                            onClicked: {
                                launcherScope.selectedIndex = index;
                                launcherScope.launchApp(modelData);
                            }
                        }
                    }
                }
            }

            BrutalDivider {}

            BrutalHintBar {
                text: "↑↓ SELECT   ENTER RUN   ESC CLOSE"

                BrutalBadge {
                    visible: launcherScope.totalPages > 1
                    text: `${launcherScope.currentPage + 1}/${launcherScope.totalPages}`
                }
            }
        }
    }
}
