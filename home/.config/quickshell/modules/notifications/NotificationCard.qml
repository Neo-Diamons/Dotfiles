pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.components
import qs.config

// Notification popup with actions, inline reply and auto-dismiss timer
BrutalPanel {
    id: card
    required property var modelData

    readonly property bool critical: card.modelData.urgency === NotificationUrgency.Critical
    readonly property color accentColor: critical ? Colors.urgent : Colors.accent

    property real progress: 1.0

    readonly property var defaultAction: modelData.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: modelData.actions.filter(a => a.identifier !== "default")

    readonly property bool held: hover.hovered || reply.input.activeFocus || reply.text !== ""

    function activate() {
        if (defaultAction)
            defaultAction.invoke();
        else
            modelData.dismiss();
    }

    function sendReply() {
        if (reply.text.trim() === "")
            return;
        modelData.sendInlineReply(reply.text);
        modelData.dismiss();
    }

    width: Theme.dims.notifWidth
    shadowOffset: Theme.shadow.md
    borderColor: accentColor

    NumberAnimation on progress {
        id: countdown
        from: 1.0
        to: 0.0
        duration: Config.notifTimeout
        running: !card.critical
        onFinished: card.modelData.dismiss()
    }

    onHeldChanged: {
        if (!countdown.running)
            return;
        if (held)
            countdown.pause();
        else
            countdown.resume();
    }

    HoverHandler {
        id: hover
    }

    BrutalHeader {
        title: card.modelData.appName || "System"
        accentColor: card.accentColor
        closable: true
        onCloseClicked: card.modelData.dismiss()
    }

    BrutalDivider {
        color: card.accentColor
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + Theme.spacing.sm * 2

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.activate()
        }

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.spacing.sm
            spacing: Theme.spacing.sm

            BrutalIcon {
                Layout.alignment: Qt.AlignTop
                source: card.modelData.image || card.modelData.appIcon || ""
                fallback: card.modelData.appName ? card.modelData.appName.charAt(0).toUpperCase() : "󰂚"
                fallbackColor: card.accentColor
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xxs

                BrutalText {
                    Layout.fillWidth: true
                    text: card.modelData.summary || ""
                    color: Colors.textPrimary
                    font.bold: true
                    font.pixelSize: Theme.font.sizeNormal
                    wrapMode: Text.Wrap
                }

                BrutalText {
                    Layout.fillWidth: true
                    text: card.modelData.body || ""
                    color: Colors.textSubtle
                    font.pixelSize: Theme.font.sizeSmall
                    wrapMode: Text.Wrap
                    visible: text.length > 0
                }
            }
        }
    }

    Flow {
        visible: card.buttons.length > 0
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing.sm
        Layout.rightMargin: Theme.spacing.sm
        Layout.bottomMargin: Theme.spacing.sm
        spacing: Theme.spacing.xs

        Repeater {
            model: card.buttons

            BrutalButton {
                required property var modelData
                text: modelData.text || modelData.identifier
                accentColor: card.accentColor
                // Non-resident ones close themselves after an action
                onClicked: modelData.invoke()
            }
        }
    }

    RowLayout {
        visible: card.modelData.hasInlineReply
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing.sm
        Layout.rightMargin: Theme.spacing.sm
        Layout.bottomMargin: Theme.spacing.sm
        spacing: Theme.spacing.xs

        BrutalInput {
            id: reply
            Layout.fillWidth: true
            placeholder: (card.modelData.inlineReplyPlaceholder || "Reply").toUpperCase()
            onAccepted: card.sendReply()
            Keys.onEscapePressed: {
                reply.text = "";
                reply.input.focus = false;
            }
        }

        BrutalButton {
            Layout.alignment: Qt.AlignTop
            text: "Send"
            accentColor: card.accentColor
            onClicked: card.sendReply()
        }
    }

    BrutalProgress {
        visible: !card.critical
        Layout.fillWidth: true
        bordered: false
        value: card.progress
        accentColor: card.accentColor
    }
}
