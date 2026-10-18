pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components
import qs.config

// Battery page: UPower batteries (laptop, mouse, headset…)
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    readonly property var devices: UPower.devices.values.filter(d => d.type !== UPowerDeviceType.LinePower && (d.isLaptopBattery || d.percentage > 0)) // qmllint disable missing-property

    visible: devices.length > 0

    function levelIcon(fraction) {
        const icons = ["", "", "", "", ""];
        return icons[Math.min(4, Math.floor(fraction * 5))];
    }

    function charging(d) {
        return d.state === UPowerDeviceState.Charging || d.state === UPowerDeviceState.PendingCharge;
    }

    function duration(seconds) {
        const m = Math.round(seconds / 60);
        return m >= 60 ? Math.floor(m / 60) + "h " + String(m % 60).padStart(2, "0") + "m" : m + "m";
    }

    // "72% · 8.4 W · 3h 12m": percentage, power draw (or charge rate) and time to empty (or full)
    function summary(d) {
        const parts = [Math.round(d.percentage * 100) + "%"];
        if (d.changeRate > 0)
            parts.push(d.changeRate.toFixed(1) + " W");
        const t = charging(d) ? d.timeToFull : d.timeToEmpty;
        if (t > 0)
            parts.push(duration(t));
        return parts.join(" · ");
    }

    SectionHeader {
        icon: ""
        title: "Battery"
        status: root.devices.length + (root.devices.length > 1 ? " devices" : " device")
    }

    Repeater {
        model: root.devices

        BrutalRow {
            required property var modelData
            icon: root.charging(modelData) ? "" : root.levelIcon(modelData.percentage)
            text: modelData.model || UPowerDeviceType.toString(modelData.type)
            trailing: root.summary(modelData)
            highlighted: root.charging(modelData)
        }
    }
}
