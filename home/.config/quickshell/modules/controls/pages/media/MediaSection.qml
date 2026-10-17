pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

// Media page: player switcher, cover, track, transport and seek bar
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    property bool panelOpen: false

    readonly property var player: Media.active

    visible: player !== null

    readonly property bool hasTimeline: player !== null && player.lengthSupported && player.length > 0

    // MPRIS doesn't push position: poll, only with a timeline
    Timer {
        interval: 1000
        repeat: true
        running: root.panelOpen && root.hasTimeline && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    SectionHeader {
        icon: ""
        title: "Media"
        status: root.player ? root.player.identity : ""
    }

    Flow {
        visible: Media.players.length > 1
        Layout.fillWidth: true
        spacing: Theme.spacing.xs

        Repeater {
            model: Media.players

            BrutalButton {
                required property var modelData
                text: modelData.identity
                active: modelData === root.player
                onClicked: Media.selected = modelData
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        BrutalSurface {
            implicitWidth: Theme.dims.coverSize + shadowOffset
            implicitHeight: Theme.dims.coverSize + shadowOffset
            fillColor: Colors.bgBase
            borderColor: Colors.accent
            borderWidth: Theme.dims.borderWidthActive

            Image {
                id: cover
                anchors.fill: parent
                anchors.margins: Theme.dims.borderWidthActive
                source: root.player ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: Theme.dims.coverSize
                sourceSize.height: Theme.dims.coverSize
                asynchronous: true
            }

            BrutalText {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                text: ""
                color: Colors.accent
                font.pixelSize: Theme.font.sizeLarge
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xxs

            BrutalText {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                font.bold: true
                elide: Text.ElideRight
            }

            BrutalText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.player ? root.player.trackArtist : ""
                color: Colors.textMuted
                font.pixelSize: Theme.font.sizeSmall
                elide: Text.ElideRight
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacing.sm

        BrutalTile {
            size: Theme.dims.controlHeight
            text: ""
            dimmed: !(root.player && root.player.canGoPrevious)
            onLeftClicked: {
                if (root.player && root.player.canGoPrevious)
                    root.player.previous();
            }
        }

        BrutalTile {
            size: Theme.dims.controlHeight
            text: root.player && root.player.isPlaying ? "" : ""
            selected: root.player !== null && root.player.isPlaying
            dimmed: !(root.player && root.player.canTogglePlaying)
            onLeftClicked: {
                if (root.player && root.player.canTogglePlaying)
                    root.player.togglePlaying();
            }
        }

        BrutalTile {
            size: Theme.dims.controlHeight
            text: ""
            dimmed: !(root.player && root.player.canGoNext)
            onLeftClicked: {
                if (root.player && root.player.canGoNext)
                    root.player.next();
            }
        }
    }

    // Browsers may stop reporting length after autoplay: "--:--" until then
    RowLayout {
        visible: root.player !== null
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        readonly property bool known: root.hasTimeline
        readonly property bool seekable: known && root.player.canSeek

        BrutalText {
            text: parent.known ? Media.formatTime(root.player.position) : "--:--"
            color: Colors.textMuted
            font.pixelSize: Theme.font.sizeSmall
        }

        BrutalSlider {
            Layout.fillWidth: true
            enabled: parent.seekable
            value: parent.known ? root.player.position / root.player.length : 0
            dimmed: !parent.seekable
            onMoved: v => root.player.position = v * root.player.length
        }

        BrutalText {
            text: parent.known ? Media.formatTime(root.player.length) : "--:--"
            color: Colors.textMuted
            font.pixelSize: Theme.font.sizeSmall
        }
    }
}
