import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

// Power saver on the battery page: Auto follows the power source, On / Off force it
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    SectionHeader {
        icon: "󰌪"
        title: "Power saver"
        status: PowerSaver.active ? "on" : "off"
    }

    BrutalText {
        Layout.fillWidth: true
        text: "No blur, shadows or animations, 60 Hz, no turbo, power-saver profile."
        color: Colors.textMuted
        font.pixelSize: Theme.font.sizeSmall
        wrapMode: Text.Wrap
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        Repeater {
            model: ["auto", "on", "off"]

            BrutalButton {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                active: PowerSaver.mode === modelData
                onClicked: PowerSaver.setMode(modelData)
            }
        }
    }
}
