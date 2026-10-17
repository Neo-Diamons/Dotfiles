pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import qs.components
import qs.config

// Polkit password prompt, outside clicks are ignored
Scope {
    id: root

    readonly property var flow: agent.flow // qmllint disable unresolved-type
    readonly property var identity: flow ? flow.selectedIdentity : null

    function identityName(id) {
        return id ? (id.displayName || id.name || "") : "";
    }

    function submit() {
        if (!root.flow || !root.flow.isResponseRequired)
            return;
        root.flow.submit(password.text);
        password.text = "";
    }

    function cancel() {
        if (root.flow)
            root.flow.cancelAuthenticationRequest();
    }

    PolkitAgent {
        id: agent
    }

    Connections {
        target: root.flow
        ignoreUnknownSignals: true

        function onAuthenticationFailed() {
            password.text = "";
            shake.restart();
        }
    }

    onFlowChanged: {
        password.text = "";
        if (flow)
            password.focusInput();
    }

    BrutalModal {
        open: root.flow !== null
        exclusiveFocus: true
        closeOnOutsideClick: false
        frame: dialog
        layerName: "quickshell-polkit"
        onCloseRequested: root.cancel()

        BrutalPanel {
            id: dialog
            anchors.centerIn: parent
            width: Theme.dims.polkitWidth + shadowOffset

            transform: Translate {
                id: shift
            }

            SequentialAnimation {
                id: shake
                loops: Theme.anim.shakeLoops
                NumberAnimation {
                    target: shift
                    property: "x"
                    to: -Theme.spacing.sm
                    duration: Theme.anim.press
                }
                NumberAnimation {
                    target: shift
                    property: "x"
                    to: Theme.spacing.sm
                    duration: Theme.anim.press
                }
                NumberAnimation {
                    target: shift
                    property: "x"
                    to: 0
                    duration: Theme.anim.press
                }
            }

            BrutalHeader {
                title: "Authentication required"
                closable: true
                onCloseClicked: root.cancel()
            }

            BrutalDivider {}

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: Theme.spacing.md
                spacing: Theme.spacing.sm

                BrutalText {
                    Layout.fillWidth: true
                    text: root.flow ? root.flow.message : ""
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                BrutalText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: root.flow ? root.flow.actionId : ""
                    color: Colors.textMuted
                    font.pixelSize: Theme.font.sizeSmall
                    elide: Text.ElideMiddle
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacing.xs
                    spacing: Theme.spacing.sm

                    BrutalBadge {
                        text: "USER"
                    }

                    BrutalText {
                        visible: !picker.visible
                        Layout.fillWidth: true
                        text: root.identityName(root.identity)
                        elide: Text.ElideRight
                    }

                    Flow {
                        id: picker
                        visible: root.flow !== null && root.flow.identities.length > 1
                        Layout.fillWidth: true
                        spacing: Theme.spacing.xs

                        Repeater {
                            model: root.flow ? root.flow.identities : []

                            BrutalButton {
                                required property var modelData
                                text: root.identityName(modelData)
                                active: modelData === root.identity
                                onClicked: {
                                    root.flow.selectedIdentity = modelData;
                                    password.focusInput();
                                }
                            }
                        }
                    }
                }

                BrutalInput {
                    id: password
                    Layout.fillWidth: true
                    focus: true
                    enabled: root.flow !== null && root.flow.isResponseRequired
                    password: root.flow ? !root.flow.responseVisible : true
                    placeholder: root.flow && root.flow.inputPrompt ? root.flow.inputPrompt.replace(/:\s*$/, "").toUpperCase() : "PASSWORD"
                    onAccepted: root.submit()
                }

                BrutalText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: {
                        if (!root.flow)
                            return "";
                        if (root.flow.supplementaryMessage)
                            return root.flow.supplementaryMessage;
                        return root.flow.failed ? "Wrong password, try again" : "";
                    }
                    color: root.flow && (root.flow.supplementaryIsError || root.flow.failed) ? Colors.textAccent : Colors.textMuted
                    font.bold: true
                    font.pixelSize: Theme.font.sizeSmall
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacing.xs
                    spacing: Theme.spacing.sm

                    Item {
                        Layout.fillWidth: true
                    }

                    BrutalButton {
                        text: "Cancel"
                        onClicked: root.cancel()
                    }

                    BrutalButton {
                        text: "Authenticate"
                        active: true
                        opacity: password.enabled ? 1.0 : Theme.dimOpacity
                        onClicked: root.submit()
                    }
                }
            }

            BrutalDivider {}

            BrutalHintBar {
                text: "ENTER AUTHENTICATE   ESC CANCEL"
            }
        }
    }
}
