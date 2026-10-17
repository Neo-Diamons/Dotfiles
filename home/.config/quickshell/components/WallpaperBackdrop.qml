import QtQuick
import QtQuick.Effects
import qs.config

Item {
    Rectangle {
        anchors.fill: parent
        color: Colors.bgBase
    }

    Image {
        id: image
        anchors.fill: parent
        visible: false
        source: Colors.wallpaper ? "file://" + Colors.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(parent.width, parent.height)
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        visible: image.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 48
        brightness: -0.4
    }
}
