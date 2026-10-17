import QtQuick
import qs.config

// Box with a hard shadow that sinks when pressed, shadow space always reserved
Item {
    id: root

    property color fillColor: Colors.bgOverlay
    property color borderColor: Colors.borderDefault
    property int borderWidth: Theme.dims.borderWidth
    property int shadowOffset: Theme.shadow.sm
    property bool flat: false
    property bool pressed: false

    readonly property int depth: flat ? 0 : shadowOffset

    property alias clipContent: face.clip

    default property alias content: face.data

    Rectangle {
        visible: root.depth > 0
        x: root.depth
        y: root.depth
        width: face.width
        height: face.height
        color: Theme.shadow.color
    }

    Rectangle {
        id: face
        x: root.pressed ? root.depth : 0
        y: root.pressed ? root.depth : 0
        width: root.width - root.shadowOffset
        height: root.height - root.shadowOffset

        radius: Theme.dims.radius
        color: root.fillColor
        border.color: root.borderColor
        border.width: root.borderWidth

        Behavior on x {
            NumberAnimation {
                duration: Theme.anim.press
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: Theme.anim.press
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.anim.fast
            }
        }
    }
}
