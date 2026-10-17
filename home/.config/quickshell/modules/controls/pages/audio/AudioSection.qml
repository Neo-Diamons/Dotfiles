pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.config
import qs.services

// Audio page: output volume and device, per-app volume, microphone
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    SectionHeader {
        icon: Audio.volumeIcon(Audio.volume, Audio.muted)
        title: "Output"
        status: Audio.sink ? Audio.nodeName(Audio.sink) : "No output device"
    }

    VolumeRow {
        icon: Audio.volumeIcon(Audio.volume, Audio.muted)
        muted: Audio.muted
        value: Audio.volume
        onMuteToggled: Audio.toggleMute()
        onMoved: v => Audio.setVolume(v)
    }

    Repeater {
        model: Audio.sinks

        BrutalRow {
            required property var modelData
            icon: ""
            text: Audio.nodeName(modelData)
            highlighted: modelData === Audio.sink
            onClicked: Pipewire.preferredDefaultAudioSink = modelData
        }
    }

    BrutalDivider {
        visible: Audio.streams.length > 0
    }

    SectionHeader {
        visible: Audio.streams.length > 0
        icon: "󰀻"
        title: "Apps"
        status: Audio.streams.length + (Audio.streams.length === 1 ? " stream" : " streams")
    }

    Repeater {
        model: Audio.streams

        ColumnLayout {
            id: stream
            required property var modelData

            readonly property bool ready: modelData.audio !== null
            readonly property real volume: ready ? modelData.audio.volume : 0
            readonly property bool muted: ready ? modelData.audio.muted : true

            Layout.fillWidth: true
            spacing: Theme.spacing.xxs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                BrutalText {
                    text: Audio.streamName(stream.modelData)
                    font.bold: true
                    font.pixelSize: Theme.font.sizeSmall
                    elide: Text.ElideRight
                    Layout.maximumWidth: stream.width * Theme.dims.trailingMaxRatio
                }

                BrutalText {
                    Layout.fillWidth: true
                    text: Audio.streamDetail(stream.modelData)
                    color: Colors.textMuted
                    font.pixelSize: Theme.font.sizeSmall
                    elide: Text.ElideRight
                }
            }

            VolumeRow {
                icon: Audio.volumeIcon(stream.volume, stream.muted)
                muted: stream.muted
                value: stream.volume
                onMuteToggled: {
                    if (stream.ready)
                        stream.modelData.audio.muted = !stream.muted;
                }
                onMoved: v => Audio.setStreamVolume(stream.modelData, v)
            }
        }
    }

    BrutalDivider {}

    SectionHeader {
        icon: Audio.micIcon(Audio.micMuted)
        title: "Input"
        status: Audio.source ? Audio.nodeName(Audio.source) : "No input device"
    }

    VolumeRow {
        icon: Audio.micIcon(Audio.micMuted)
        muted: Audio.micMuted
        value: Audio.micVolume
        onMuteToggled: Audio.toggleMicMute()
        onMoved: v => Audio.setMicVolume(v)
    }
}
