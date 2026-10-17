pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// MPRIS players and the active one
Singleton {
    id: root

    readonly property var players: Mpris.players.values

    property var selected: null
    readonly property var active: selected && players.includes(selected) ? selected : (players.find(p => p.isPlaying) ?? players[0] ?? null)

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds || 0));
        const m = Math.floor(s / 60);
        const h = Math.floor(m / 60);
        const pad = n => String(n).padStart(2, "0");
        return h > 0 ? `${h}:${pad(m % 60)}:${pad(s % 60)}` : `${m}:${pad(s % 60)}`;
    }
}
