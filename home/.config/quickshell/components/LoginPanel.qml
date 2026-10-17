import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

BrutalPanel {
    id: root

    property string title: "Locked"
    property string user: ""
    property string message: ""
    property bool busy: false
    property string action: "Unlock"
    property bool loading: false

    signal submitted(string password)

    function focusInput() {
        password.focusInput();
    }

    function fail(text) {
        message = text;
        password.text = "";
        shake.restart();
        password.focusInput();
    }

    implicitWidth: Theme.dims.loginWidth + shadowOffset

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

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BrutalHeader {
        title: root.title
    }

    BrutalDivider {}

    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: Theme.spacing.lg
        spacing: Theme.spacing.sm

        BrutalText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            font.bold: true
            font.pixelSize: Theme.font.sizeLock
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.md
            spacing: Theme.spacing.sm
            visible: root.user !== ""

            BrutalBadge {
                text: "USER"
            }

            BrutalText {
                Layout.fillWidth: true
                text: root.user
                font.bold: true
                elide: Text.ElideRight
            }
        }

        BrutalInput {
            id: password
            Layout.fillWidth: true
            focus: true
            enabled: !root.busy && !root.loading
            password: true
            placeholder: "PASSWORD"
            onAccepted: {
                if (text === "")
                    return;
                root.message = "";
                root.submitted(text);
            }
        }

        BrutalText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.message
            color: Colors.textAccent
            font.bold: true
            font.pixelSize: Theme.font.sizeSmall
            wrapMode: Text.Wrap
        }
    }

    BrutalDivider {}

    BrutalHintBar {
        text: root.loading ? "STARTING SESSION" : (root.busy ? "CHECKING" : "ENTER " + root.action.toUpperCase())
    }
}
