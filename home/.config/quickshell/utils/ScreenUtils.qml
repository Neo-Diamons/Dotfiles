pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Focused screen, bar screens and the primary screen for popups
Singleton {
    id: root

    readonly property var focusedScreen: {
        const name = Hyprland.focusedMonitor?.name;
        if (name) {
            const found = Quickshell.screens.find(s => s.name === name);
            if (found)
                return found;
        }
        return Quickshell.screens[0] ?? null;
    }

    readonly property var barScreens: {
        const all = Quickshell.screens;
        if (Config.barScreens.length === 0)
            return all;
        const wanted = Config.barScreens.map(n => all.find(s => s.name === n)).filter(s => s !== undefined);
        return wanted.length > 0 ? wanted : all.slice(0, 1);
    }

    readonly property var primaryScreen: barScreens[0] ?? null
}
