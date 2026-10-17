pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default output / input, output devices and app streams (PipeWire)
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)

    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && n.type === PwNodeType.AudioOutStream)

    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : true

    readonly property bool micReady: source !== null && source.audio !== null
    readonly property real micVolume: micReady ? source.audio.volume : 0
    readonly property bool micMuted: micReady ? source.audio.muted : true

    property bool panelOpen: false

    function nodeName(n) {
        return n ? (n.description || n.nickname || n.name) : "";
    }

    function streamName(n) {
        const p = n.properties || {};
        return p["application.name"] || nodeName(n);
    }

    function streamDetail(n) {
        const p = n.properties || {};
        const media = p["media.name"] || "";
        return media !== streamName(n) ? media : "";
    }

    function setStreamVolume(n, v) {
        if (n.audio) {
            n.audio.muted = false;
            n.audio.volume = Math.max(0, Math.min(1, v));
        }
    }

    function setVolume(v) {
        if (ready)
            sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function changeVolume(delta) {
        if (ready) {
            sink.audio.muted = false;
            setVolume(volume + delta);
        }
    }

    function toggleMute() {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(v) {
        if (micReady)
            source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleMicMute() {
        if (micReady)
            source.audio.muted = !source.audio.muted;
    }

    function volumeIcon(vol, isMuted) {
        if (isMuted || vol <= 0)
            return "";
        return vol < 0.5 ? "" : "";
    }

    function micIcon(isMuted) {
        return isMuted ? "" : "";
    }

    // Nodes must be tracked for their audio properties to be available
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }
}
