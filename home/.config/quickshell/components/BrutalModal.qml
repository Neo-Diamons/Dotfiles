import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils

// Full-screen overlay centring its content on the focused screen, closes on Escape or outside click
PanelWindow { // qmllint disable uncreatable-type
    id: root

    property bool open: false
    property bool exclusiveFocus: false
    property Item frame: null
    property bool closeOnOutsideClick: true
    property string layerName: "quickshell-modal"

    default property alias content: stage.data

    signal closeRequested

    visible: open
    screen: ScreenUtils.focusedScreen
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: root.layerName
    WlrLayershell.keyboardFocus: !open ? WlrKeyboardFocus.None : (exclusiveFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)

    MouseArea {
        id: outside
        anchors.fill: parent
        onClicked: mouse => {
            if (!root.closeOnOutsideClick)
                return;
            if (root.frame && root.frame.contains(root.frame.mapFromItem(outside, mouse.x, mouse.y)))
                return;
            root.closeRequested();
        }
    }

    FocusScope {
        id: stage
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.closeRequested()
    }
}
