import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils

// Notification history entry
BrutalSurface {
    id: root

    required property var modelData

    readonly property color accentColor: modelData.critical ? Colors.urgent : Colors.accent

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + Theme.spacing.sm * 2 + shadowOffset

    fillColor: Colors.bgOverlay
    borderColor: hover.hovered ? accentColor : (modelData.critical ? Colors.urgent : Colors.borderDefault)
    borderWidth: hover.hovered || modelData.critical ? Theme.dims.borderWidthActive : Theme.dims.borderWidth

    HoverHandler {
        id: hover
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.sm
        spacing: Theme.spacing.sm

        BrutalIcon {
            Layout.alignment: Qt.AlignTop
            source: root.modelData.image || root.modelData.appIcon
            fallback: root.modelData.appName.charAt(0).toUpperCase()
            fallbackColor: root.accentColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Theme.spacing.xxs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                BrutalText {
                    Layout.fillWidth: true
                    text: root.modelData.appName.toUpperCase()
                    color: root.accentColor
                    font.bold: true
                    font.pixelSize: Theme.font.sizeSmall
                    elide: Text.ElideRight
                }

                BrutalText {
                    text: TimeUtils.timeAgo(root.modelData.time)
                    color: Colors.textMuted
                    font.pixelSize: Theme.font.sizeSmall
                }

                BrutalTile {
                    size: Theme.dims.badgeHeight
                    shadowOffset: 0
                    ghost: true
                    text: "✕"
                    textSize: Theme.font.sizeSmall
                    onLeftClicked: Notifs.remove(root.modelData.id)
                }
            }

            BrutalText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.modelData.summary
                font.bold: true
                wrapMode: Text.Wrap
            }

            BrutalText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.modelData.body
                color: Colors.textSubtle
                font.pixelSize: Theme.font.sizeSmall
                wrapMode: Text.Wrap
                maximumLineCount: Theme.dims.notifHistoryLines
                elide: Text.ElideRight
            }
        }
    }
}
