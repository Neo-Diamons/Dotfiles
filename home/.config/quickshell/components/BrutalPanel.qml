import QtQuick
import QtQuick.Layouts
import qs.config

// Bordered column container with a hard shadow
Item {
    id: root

    property color borderColor: Colors.borderFocused
    property color fillColor: Colors.bgSurface
    property int borderWidth: Theme.dims.borderWidthActive
    property int shadowOffset: Theme.shadow.lg

    default property alias content: column.data

    implicitWidth: frame.implicitWidth + shadowOffset
    implicitHeight: frame.implicitHeight + shadowOffset

    Rectangle {
        x: root.shadowOffset
        y: root.shadowOffset
        width: frame.width
        height: frame.height
        color: Theme.shadow.color
    }

    Rectangle {
        id: frame
        width: root.width - root.shadowOffset
        height: root.height - root.shadowOffset
        implicitWidth: column.implicitWidth + root.borderWidth * 2
        implicitHeight: column.implicitHeight + root.borderWidth * 2

        radius: Theme.dims.radius
        color: root.fillColor
        border.color: root.borderColor
        border.width: root.borderWidth

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: root.borderWidth
            spacing: 0
        }
    }
}
