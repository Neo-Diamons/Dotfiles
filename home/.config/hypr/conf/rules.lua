hl.window_rule({
    name  = "steam-float",
    match = { class = "^steam$" },
    float = true,
})

hl.window_rule({
    name  = "steam-main-tile",
    match = { class = "^steam$", title = "^Steam$" },
    tile  = true,
})

hl.window_rule({
    name  = "steam-friends-size",
    match = { class = "^steam$", title = "^Friends List$" },
    size  = "340 720",
})

hl.window_rule({
    name             = "steam-toasts-pin",
    match            = { class = "^steam$", initial_title = "^notificationtoasts_" },
    float            = true,
    pin              = true,
    stay_focused     = true,
    no_focus         = true,
    no_initial_focus = true,
})

hl.on("window.title", function(window)
    if window.class == "app.zen_browser.zen" and window.title:find("^Extension: %(Bitwarden") and not window.floating then
        hl.timer(function()
            hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = 1, window = window }))
            hl.dispatch(hl.dsp.window.float({ action = "enable", window = window }))
            hl.dispatch(hl.dsp.window.resize({ x = 450, y = 700, relative = false, window = window }))
            hl.dispatch(hl.dsp.window.center({ window = window }))
        end, { timeout = 10, type = "oneshot" })
    end
end)
