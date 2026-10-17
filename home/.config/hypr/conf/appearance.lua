package.loaded["colors"] = nil
local colors = require("colors")

hl.config({
    general = {
        gaps_in          = 0,
        gaps_out         = 0,
        border_size      = 2,

        col              = {
            active_border   = colors.active_border,
            inactive_border = colors.inactive_border,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = colors.shadow,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },

    xwayland = { force_zero_scaling = true },

    dwindle = { preserve_split = true },

    master = { new_status = "master" },

    scrolling = { fullscreen_on_one_column = true },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        disable_autoreload       = true,
    },
})
