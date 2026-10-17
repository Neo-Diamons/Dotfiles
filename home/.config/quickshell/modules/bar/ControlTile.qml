import qs.components
import qs.config

// Bar tile showing a glyph, dimmed when inactive
BrutalTile {
    property string icon: ""
    property bool active: true

    text: icon
    textSize: Theme.dims.iconSmall
    dimmed: !active
}
