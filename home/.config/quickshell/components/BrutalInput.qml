import QtQuick
import qs.config

// Single-line text field
//   framed: false → flat fill, no border / shadow (e.g. inside a header)
//   prompt        → accent block with a glyph on the left
BrutalSurface {
    id: root

    property alias text: input.text
    property alias input: input
    property string placeholder: ""
    property string prompt: ""
    property bool password: false
    property bool framed: true
    property int fieldHeight: Theme.dims.controlHeight
    property int fontSize: Theme.font.sizeNormal

    signal accepted

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: fieldHeight + shadowOffset
    shadowOffset: framed ? Theme.shadow.sm : 0
    fillColor: framed ? Colors.bgBase : Colors.bgOverlay
    borderColor: !framed ? "transparent" : (input.activeFocus ? Colors.accent : Colors.borderDefault)
    borderWidth: framed ? Theme.dims.borderWidthActive : 0

    Rectangle {
        id: promptBlock
        visible: root.prompt !== ""
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: visible ? height : 0
        color: Colors.accent

        BrutalText {
            anchors.centerIn: parent
            text: root.prompt
            color: Colors.bgBase
            font.bold: true
            font.pixelSize: Theme.font.sizeLarge
        }
    }

    TextInput {
        id: input
        anchors.left: promptBlock.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.prompt !== "" ? Theme.spacing.md : Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        verticalAlignment: TextInput.AlignVCenter
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        color: Colors.textPrimary
        selectionColor: Colors.accent
        selectedTextColor: Colors.bgBase
        font.family: Theme.font.family
        font.bold: !root.framed
        font.pixelSize: root.fontSize
        clip: true
        onAccepted: root.accepted()

        BrutalText {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: input.text === ""
            text: root.placeholder
            color: Colors.textMuted
            font.bold: true
            font.pixelSize: root.framed ? Theme.font.sizeSmall : root.fontSize
            elide: Text.ElideRight
        }
    }
}
