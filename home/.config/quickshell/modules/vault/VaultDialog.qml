pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.config

// gocryptfs vault: password prompt to unlock, create on first use, confirm before locking (`qs ipc call vault`)
Scope {
    id: root

    readonly property string cipherDir: Config.vaultCipherFolder.replace(/^~/, Quickshell.env("HOME")) // qmllint disable missing-property
    readonly property string mountDir: Config.vaultMountFolder.replace(/^~/, Quickshell.env("HOME")) // qmllint disable missing-property

    property string mode: ""
    property string error: ""
    property string pending: ""
    readonly property bool busy: init.running || mount.running || unmount.running

    function toggle() {
        if (root.mode !== "")
            root.close();
        else if (!state.running)
            state.running = true;
    }

    function close() {
        root.mode = "";
        root.pending = "";
        root.error = "";
        password.text = "";
        confirm.text = "";
    }

    function notify(text: string): void {
        Quickshell.execDetached(["notify-send", "-e", "-a", "Vault", text]);
    }

    function fail(text: string): void {
        root.error = text;
        root.pending = "";
        password.text = "";
        confirm.text = "";
        password.focusInput();
        shake.restart();
    }

    function submit() {
        if (root.busy || password.text === "")
            return;
        if (root.mode === "create" && password.text !== confirm.text) {
            root.fail("Passwords do not match");
            return;
        }
        root.error = "";
        root.pending = password.text;
        if (root.mode === "create")
            init.running = true;
        else
            mount.running = true;
    }

    function lock() {
        if (root.busy)
            return;
        root.error = "";
        unmount.running = true;
    }

    IpcHandler {
        target: "vault"

        function toggle(): void {
            root.toggle();
        }
    }

    Process {
        id: state
        command: ["sh", "-c", "if mountpoint -q \"$1\"; then echo mounted; elif [ -f \"$2/gocryptfs.conf\" ]; then echo locked; else echo new; fi", "sh", root.mountDir, root.cipherDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                root.mode = out === "mounted" ? "lock" : (out === "locked" ? "unlock" : "create");
                if (root.mode !== "lock")
                    Qt.callLater(password.focusInput);
            }
        }
    }

    Process {
        id: init
        stdinEnabled: true
        command: ["sh", "-c", "mkdir -p \"$1\" && exec gocryptfs -q -init \"$1\"", "sh", root.cipherDir]
        onStarted: write(root.pending + "\n")
        onExited: code => {
            if (code === 0)
                mount.running = true;
            else
                root.fail("Could not create the vault");
        }
    }

    Process {
        id: mount
        stdinEnabled: true
        command: ["sh", "-c", "mkdir -p \"$1\" \"$2\" && exec gocryptfs -q \"$1\" \"$2\"", "sh", root.cipherDir, root.mountDir]
        stderr: StdioCollector {
            id: mountErr
        }
        onStarted: write(root.pending + "\n")
        onExited: code => {
            root.pending = "";
            if (code === 0) {
                root.close();
                root.notify("Vault unlocked");
            } else {
                root.fail(code === 12 ? "Wrong password, try again" : (mountErr.text.trim() || "Could not unlock the vault"));
            }
        }
    }

    Process {
        id: unmount
        command: ["fusermount3", "-u", root.mountDir]
        stderr: StdioCollector {
            id: unmountErr
        }
        onExited: code => {
            if (code === 0) {
                root.close();
                root.notify("Vault locked");
            } else {
                root.fail(unmountErr.text.includes("busy") ? "Vault is in use, close its files and try again" : (unmountErr.text.trim() || "Could not lock the vault"));
            }
        }
    }

    BrutalModal {
        open: root.mode !== ""
        exclusiveFocus: true
        closeOnOutsideClick: false
        frame: dialog
        layerName: "quickshell-vault"
        onCloseRequested: root.close()

        Item {
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (root.mode === "lock" && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
                    root.lock();
                    event.accepted = true;
                }
            }

            BrutalPanel {
                id: dialog
                anchors.centerIn: parent
                width: Theme.dims.vaultWidth + shadowOffset

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
                    title: root.mode === "lock" ? "Lock vault" : (root.mode === "create" ? "Create vault" : "Unlock vault")
                    closable: true
                    onCloseClicked: root.close()
                }

                BrutalDivider {}

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: Theme.spacing.md
                    spacing: Theme.spacing.sm

                    BrutalText {
                        Layout.fillWidth: true
                        visible: root.mode === "lock"
                        text: "Unmount " + root.mountDir + "?"
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    BrutalText {
                        Layout.fillWidth: true
                        visible: root.mode === "create"
                        text: "No vault found, set a password to create " + root.cipherDir
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    BrutalInput {
                        id: password
                        Layout.fillWidth: true
                        visible: root.mode !== "lock"
                        focus: true
                        enabled: !root.busy
                        password: true
                        placeholder: "PASSWORD"
                        onAccepted: root.mode === "create" ? confirm.focusInput() : root.submit()
                    }

                    BrutalInput {
                        id: confirm
                        Layout.fillWidth: true
                        visible: root.mode === "create"
                        enabled: !root.busy
                        password: true
                        placeholder: "CONFIRM PASSWORD"
                        onAccepted: root.submit()
                    }

                    BrutalText {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: root.error
                        color: Colors.textAccent
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
                            onClicked: root.close()
                        }

                        BrutalButton {
                            text: root.mode === "lock" ? "Lock" : (root.mode === "create" ? "Create" : "Unlock")
                            active: true
                            opacity: root.busy ? Theme.dimOpacity : 1.0
                            onClicked: root.mode === "lock" ? root.lock() : root.submit()
                        }
                    }
                }

                BrutalDivider {}

                BrutalHintBar {
                    text: root.mode === "lock" ? "ENTER LOCK ESC CANCEL" : "ENTER CONFIRM ESC CANCEL"
                }
            }
        }
    }
}
