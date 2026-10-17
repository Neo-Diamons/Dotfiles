pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Drives and their filesystems from lsblk, refreshed on udisks events; actions through udisksctl
Singleton {
    id: root

    property var volumes: []
    property bool showInternal: false
    property string busyDevice: ""
    property string error: ""
    property bool refreshAgain: false

    readonly property var shown: volumes.filter(v => v.removable || showInternal)
    readonly property int mountedCount: volumes.filter(v => v.removable && v.mountpoint !== "").length
    readonly property string summary: mountedCount > 0 ? mountedCount + " mounted" : (volumes.some(v => v.removable) ? "not mounted" : "none")

    readonly property list<string> systemMounts: ["/", "/boot", "/boot/efi", "/efi", "/home", "/usr", "/var"]

    function formatSize(bytes) {
        const units = ["B", "KB", "MB", "GB", "TB"];
        let size = bytes || 0;
        let unit = 0;
        while (size >= 1024 && unit < units.length - 1) {
            size /= 1024;
            unit++;
        }
        return (size >= 10 || unit === 0 ? Math.round(size) : size.toFixed(1)) + " " + units[unit];
    }

    function parse(text) {
        const mounts = d => (d.mountpoints ?? []).filter(m => m && m !== "[SWAP]");
        const out = [];
        for (const disk of JSON.parse(text).blockdevices ?? []) {
            if ((disk.type !== "disk" && disk.type !== "loop") || disk.name.startsWith("zram"))
                continue;
            const members = [disk, ...(disk.children ?? [])];
            const isSystem = members.some(d => mounts(d).some(m => root.systemMounts.includes(m)));
            const removable = disk.rm || disk.hotplug || disk.tran === "usb" || disk.type === "loop";
            const parts = (disk.children ?? []).filter(c => c.type === "part");
            for (const p of parts.length > 0 ? parts : [disk]) {
                if (!p.fstype || p.fstype === "swap")
                    continue;
                const points = mounts(p).sort((a, b) => a.length - b.length);
                out.push({
                    device: p.path,
                    disk: disk.path,
                    loop: disk.type === "loop",
                    name: p.label || (disk.model ?? "").trim() || p.name,
                    deviceName: p.name,
                    size: p.size,
                    fstype: p.fstype,
                    locked: p.fstype === "crypto_LUKS",
                    mountpoint: points[0] ?? "",
                    used: p.fsused ?? -1,
                    avail: p.fsavail ?? -1,
                    removable: removable,
                    system: isSystem
                });
            }
        }
        volumes = out;
    }

    function refresh() {
        if (list.running)
            refreshAgain = true;
        else
            list.running = true;
    }

    function run(device, command) {
        error = "";
        busyDevice = device;
        action.command = command;
        action.running = true;
    }

    function mount(v) {
        run(v.device, ["udisksctl", "mount", "-b", v.device]);
    }

    function unmount(v) {
        run(v.device, ["udisksctl", "unmount", "-b", v.device]);
    }

    // Unmount every mounted filesystem of the drive, then power it off (or detach an image)
    function eject(v) {
        const mounted = volumes.filter(o => o.disk === v.disk && o.mountpoint !== "").map(o => o.device);
        const detach = v.loop ? "udisksctl loop-delete -b \"$disk\"" : "udisksctl power-off -b \"$disk\"";
        run(v.device, ["sh", "-c", `disk=$1; shift; for d in "$@"; do udisksctl unmount -b "$d" || exit 1; done; ${detach}`, "sh", v.disk, ...mounted]);
    }

    function open(v) {
        Quickshell.execDetached([...Config.fileManager.split(" "), v.mountpoint]);
    }

    Process {
        id: list
        running: true
        command: ["lsblk", "-J", "-b", "-o", "NAME,PATH,TYPE,LABEL,SIZE,FSTYPE,MOUNTPOINTS,FSAVAIL,FSUSED,RM,HOTPLUG,TRAN,MODEL"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
        onRunningChanged: {
            if (!running && root.refreshAgain) {
                root.refreshAgain = false;
                running = true;
            }
        }
    }

    Process {
        id: action
        stderr: StdioCollector {
            onStreamFinished: root.error = text.trim()
        }
        onRunningChanged: {
            if (!running) {
                root.busyDevice = "";
                root.refresh();
            }
        }
    }

    Process {
        running: true
        command: ["udisksctl", "monitor"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: root.refresh()
    }
}
