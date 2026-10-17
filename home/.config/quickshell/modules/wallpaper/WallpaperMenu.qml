pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.components
import qs.config

// Wallpaper carousel, applying one updates the theme through wallust (`qs ipc call theme`)
Scope {
    id: root

    property bool isOpen: false

    // Covers load outward from the center, one more distance step every `loadInterval`
    property int loadRank: 0

    onIsOpenChanged: {
        if (isOpen) {
            coversTried = false;
            loadRank = 0;
            loadTimer.restart();
        } else {
            loadTimer.stop();
            listProc.running = true;
        }
    }

    Timer {
        id: loadTimer

        interval: Theme.wallpaper.loadInterval
        repeat: true
        onTriggered: {
            root.loadRank++;
            if (root.loadRank >= Math.ceil(Theme.wallpaper.sideCards))
                stop();
        }
    }

    function toggle() {
        root.isOpen = !root.isOpen;
    }

    function open() {
        root.isOpen = true;
    }

    function close() {
        root.isOpen = false;
    }

    IpcHandler {
        target: "theme"

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

    property list<string> wallpapers: []
    property list<string> covers: []
    property bool coversTried: false
    property int cursor: 0

    readonly property int count: wallpapers.length
    readonly property int selectedIndex: count > 0 ? ((cursor % count) + count) % count : 0

    function setWallpaper(path) {
        setProc.command = ["python3", Quickshell.shellDir + "/scripts/wallpapers.py", "set", path];
        setProc.running = true;
        root.close();
    }

    function wrap(i) {
        return count > 0 ? ((i % count) + count) % count : 0;
    }

    function move(step) {
        cursor += step;
    }

    Process {
        id: listProc

        running: true
        command: {
            const cmd = ["python3", Quickshell.shellDir + "/scripts/wallpapers.py", "list", Config.wallpaperFolder];
            if (Config.wallpaperCoverCache)
                cmd.push("--covers", Theme.wallpaper.coverWidth + "x" + Theme.wallpaper.coverHeight);
            return cmd;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const result = JSON.parse(text);
                if (JSON.stringify(root.wallpapers) !== JSON.stringify(result["wallpapers"]))
                    root.wallpapers = result["wallpapers"];
                root.covers = result["covers"];

                if (!root.isOpen)
                    root.cursor = Math.max(0, result["currentIndex"]);

                if (result["missingCovers"] > 0 && !root.coversTried) {
                    root.coversTried = true;
                    coversProc.running = true;
                }
            }
        }
    }

    Process {
        id: coversProc

        command: ["python3", Quickshell.shellDir + "/scripts/wallpapers.py", "covers", Config.wallpaperFolder, Theme.wallpaper.coverWidth + "x" + Theme.wallpaper.coverHeight]
        onRunningChanged: {
            if (!running)
                listProc.running = true;
        }
    }

    Process {
        id: setProc

        onRunningChanged: {
            if (!running)
                listProc.running = true;
        }
    }

    BrutalModal {
        open: root.isOpen
        frame: view
        layerName: "quickshell-wallpapers"
        onCloseRequested: root.close()

        Item {
            anchors.fill: parent
            focus: true

            Keys.onLeftPressed: root.move(-1)
            Keys.onRightPressed: root.move(1)
            Keys.onReturnPressed: root.setWallpaper(root.wallpapers[root.selectedIndex])

            BrutalSurface {
                id: view
                anchors.centerIn: parent

                width: Math.min(parent.width * Theme.wallpaper.widthRatio, Theme.dims.themeMenuMaxWidth) + shadowOffset
                height: Math.min(parent.height * Theme.wallpaper.heightRatio, Theme.dims.themeMenuMaxHeight) + shadowOffset

                shadowOffset: Theme.shadow.lg
                fillColor: Colors.bgSurface
                borderColor: Colors.borderFocused
                borderWidth: Theme.dims.borderWidthActive
                clipContent: true

                Item {
                    id: stage
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.xl
                    anchors.bottomMargin: Theme.spacing.xl + footer.height

                    property real position: root.cursor
                    Behavior on position {
                        NumberAnimation {
                            duration: Theme.anim.slide
                            easing.type: Easing.OutCubic
                        }
                    }

                    readonly property real cardWidth: Math.min(width * Theme.wallpaper.cardRatio, Theme.dims.wallpaperCardMaxWidth)
                    readonly property real step: cardWidth * Theme.wallpaper.cardOverlap

                    WheelHandler {
                        onWheel: event => root.move(event.angleDelta.y > 0 ? -1 : 1)
                    }
                    Repeater {
                        model: root.wallpapers

                        delegate: Item {
                            id: slot

                            required property string modelData
                            required property int index

                            // Shortest signed distance from the center, measured around the ring
                            readonly property real offset: {
                                const n = root.count;
                                let d = (((index - stage.position) % n) + n) % n;
                                if (d > n / 2)
                                    d -= n;
                                return d;
                            }
                            readonly property bool isSelected: index === root.selectedIndex

                            // Load order: center, then both neighbours together, then the next pair…
                            readonly property int rank: Math.abs(Math.round(offset))
                            readonly property bool nearby: root.isOpen && Math.abs(offset) <= Theme.wallpaper.sideCards + 1

                            visible: Math.abs(offset) <= Theme.wallpaper.sideCards

                            width: stage.cardWidth
                            height: stage.height
                            x: (stage.width - width) / 2 + offset * stage.step
                            z: -Math.abs(offset)
                            scale: Math.max(Theme.wallpaper.minScale, 1.0 - Math.abs(offset) * Theme.wallpaper.scaleStep)
                            opacity: Math.max(Theme.wallpaper.minOpacity, 1.0 - Math.abs(offset) * Theme.wallpaper.opacityStep)

                            BrutalSurface {
                                id: card
                                anchors.fill: parent
                                shadowOffset: Theme.shadow.lg
                                fillColor: Colors.bgOverlay
                                borderColor: slot.isSelected ? Colors.borderActive : Colors.borderDefault
                                borderWidth: slot.isSelected ? Theme.dims.borderWidthActive : Theme.dims.borderWidth

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: card.borderWidth
                                    anchors.bottomMargin: label.height

                                    fillMode: Image.PreserveAspectCrop

                                    source: (root.isOpen && Math.abs(slot.offset) <= Theme.wallpaper.sideCards && slot.rank <= root.loadRank)
                                            ? "file://" + (root.covers.length === root.count ? root.covers[slot.index] : slot.modelData)
                                            : ""

                                    cache: false
                                    asynchronous: true
                                    sourceSize.width: stage.cardWidth
                                    sourceSize.height: stage.height
                                }

                                Rectangle {
                                    id: label
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: card.borderWidth
                                    height: Theme.dims.footerHeight
                                    color: slot.isSelected ? Colors.accent : Colors.bgOverlay

                                    BrutalDivider {
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        implicitHeight: Theme.dims.borderWidth
                                        color: Colors.borderDefault
                                    }

                                    BrutalText {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spacing.sm
                                        anchors.rightMargin: Theme.spacing.sm
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideMiddle
                                        text: slot.modelData.split("/").pop().toUpperCase()
                                        color: slot.isSelected ? Colors.bgBase : Colors.textPrimary
                                        font.bold: true
                                        font.pixelSize: Theme.font.sizeSmall
                                    }
                                }
                            }

                            TapHandler {
                                onTapped: {
                                    if (slot.isSelected) {
                                        root.setWallpaper(slot.modelData);
                                    } else {
                                        root.cursor += Math.round(slot.offset);
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    id: footer
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: view.borderWidth

                    BrutalDivider {
                        width: parent.width
                    }

                    BrutalHintBar {
                        width: parent.width
                        centered: true
                        text: "← → SELECT ENTER APPLY ESC CLOSE"
                    }
                }
            }
        }
    }
}
