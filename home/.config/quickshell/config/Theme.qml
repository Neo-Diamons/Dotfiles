pragma Singleton
import QtQuick

// Sizes, spacing, fonts and motion
QtObject {
    id: root

    // Geometry
    readonly property var dims: QtObject {
        readonly property int radius: 0
        readonly property int borderWidth: 1
        readonly property int borderWidthActive: 2
        readonly property real iconFallbackScale: 0.45

        // Bar
        readonly property int barWidth: 44
        readonly property int tileBoxSize: 32
        readonly property int iconSmall: 18
        readonly property int badgeDot: 6
        readonly property int badgeHeight: 20

        // Settings popup
        readonly property int settingsWidth: 340
        readonly property int headerStrip: 24
        readonly property int controlHeight: 28
        readonly property int rowHeight: 30
        readonly property int valueLabelWidth: 36
        readonly property int switchWidth: 34
        readonly property int switchHeight: 18
        readonly property int sliderTrack: 8
        readonly property int sliderThumb: 14
        readonly property int progressHeight: 4
        readonly property real trailingMaxRatio: 0.5

        // Media player
        readonly property int coverSize: 48

        // Clock popup / calendar
        readonly property int calendarWidth: 280
        readonly property int calendarCell: 30

        // Launcher
        readonly property int launcherWidth: 480
        readonly property int launcherMaxHeight: 520
        readonly property int launcherItemHeight: 38
        readonly property int launcherIconSize: 26
        readonly property int iconBoxPadding: 3

        // Wallpaper menu
        readonly property int themeMenuMaxWidth: 1400
        readonly property int themeMenuMaxHeight: 800
        readonly property int wallpaperCardMaxWidth: 420
        readonly property int footerHeight: 32

        // Tray menu
        readonly property int trayMenuWidth: 240
        readonly property int trayMenuItemHeight: 28
        readonly property int checkSize: 12
        readonly property int traySeparatorHeight: 1

        // Notifications
        readonly property int notifWidth: 360
        readonly property int notifIconSize: 32
        readonly property int notifCenterWidth: 380
        readonly property int notifHistoryLines: 4

        // On-screen display
        readonly property int osdWidth: 300
        readonly property int osdBottomMargin: 48

        // Polkit password dialog
        readonly property int polkitWidth: 420
    }

    // Shadow
    readonly property var shadow: QtObject {
        readonly property color color: "#000000"
        readonly property int sm: 3
        readonly property int md: 6
        readonly property int lg: 8
    }

    // Motion
    readonly property var anim: QtObject {
        readonly property int press: 60
        readonly property int fast: 120
        readonly property int slide: 250
        readonly property int shakeLoops: 2
    }

    // Wallpaper carousel
    readonly property var wallpaper: QtObject {
        readonly property real widthRatio: 0.9
        readonly property real heightRatio: 0.75
        readonly property real cardRatio: 0.3
        readonly property real cardOverlap: 0.85
        readonly property real sideCards: 4.5
        readonly property real minScale: 0.6
        readonly property real scaleStep: 0.15
        readonly property real minOpacity: 0.35
        readonly property real opacityStep: 0.25
        readonly property int loadInterval: 60 // ms between two covers starting to load
        readonly property int coverWidth: 420 // px, size of the cached covers (the card image area)
        readonly property int coverHeight: 600
    }

    // Opacity for "off" / muted content
    readonly property real dimOpacity: 0.45

    // Spacing
    readonly property var spacing: QtObject {
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
    }

    // Typography
    readonly property var font: QtObject {
        readonly property string family: "monospace"
        readonly property int sizeSmall: 11
        readonly property int sizeNormal: 13
        readonly property int sizeLarge: 16
        readonly property int sizeClock: 12
        readonly property int sizeHuge: 28
    }
}
