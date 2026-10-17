require("vis")

local MODAL_STYLE = 51
local MODAL_STYLE_INVERTED = 52

local MODES = {
    [vis.modes.NORMAL] = "NORMAL",
    [vis.modes.INSERT] = "INSERT",
    [vis.modes.VISUAL] = "VISUAL",
    [vis.modes.REPLACE] = "REPLACE",
    [vis.modes.VISUAL_LINE] = "VISUAL_LINE",
    [vis.modes.OPERATOR_PENDING] = "OPERATOR_PENDING",
}

local STYLES = {
    [vis.modes.NORMAL] = {
        REGULAR  = "fore:black,back:magenta,bold", -- terminal palette, follows wallust
        INVERTED = "fore:magenta,back:black",
    },
    [vis.modes.INSERT] = {
        REGULAR  = "fore:#191724,back:#9ccfd8,bold", -- Rose Pine Foam
        INVERTED = "fore:#9ccfd8,back:#191724",
    },
    [vis.modes.VISUAL] = {
        REGULAR  = "fore:#191724,back:#c4a7e7,bold", -- Rose Pine Iris
        INVERTED = "fore:#c4a7e7,back:#191724",
    },
    [vis.modes.REPLACE] = {
        REGULAR  = "fore:#191724,back:#eb6f92,bold", -- Rose Pine Love
        INVERTED = "fore:#eb6f92,back:#191724",
    },
    [vis.modes.VISUAL_LINE] = {
        REGULAR  = "fore:#191724,back:#c4a7e7,bold", -- Rose Pine Iris
        INVERTED = "fore:#c4a7e7,back:#191724",
    },
    [vis.modes.OPERATOR_PENDING] = {
        REGULAR  = "fore:#191724,back:#ebbcba,bold", -- Rose Pine Rose
        INVERTED = "fore:#ebbcba,back:#191724",
    },
    UNFOCUSED = {
        REGULAR  = "fore:#e0def4,back:#26233a", -- Soft text on dark surface
        INVERTED = "fore:#e0def4,back:#191724",
    },
}

vis.events.subscribe(vis.events.WIN_STATUS, function(win)
    if not win or not win.file then return end

    -- Left
    local modified = win.file.modified and "* " or ""
    local filename = win.file.name and " " .. win.file.name .. " " or " [No Name] "

    local current_mode = vis.mode or vis.modes.NORMAL
    local vmode = " " .. MODES[current_mode] .. " "

    local recording = vis.recording and " @ RECORDING" or ""
    local status_left = vmode .. filename .. modified .. recording

    -- Right
    local cursors = 0
    for _ in win:selections_iterator() do cursors = cursors + 1 end

    local sel_size = 0
    if win.selection and win.selection.range then
        local r_start = win.selection.range.start or 0
        local r_finish = win.selection.range.finish or 0
        sel_size = r_finish - r_start
    end

    local selection_size = "SELECTION_SIZE: " .. sel_size
    local cursor_amount = "CURSORS: " .. cursors

    local line = win.selection and win.selection.line or 1
    local col = win.selection and win.selection.col or 1
    local cursor_pos = line .. ":" .. col
    local status_right = selection_size .. " | " .. cursor_amount .. " | " .. cursor_pos .. " "

    -- Status bar
    win:status(status_left, status_right)

    -- Colors
    if vis.ui and vis.ui.style_define then
        local m_style = STYLES[current_mode] or STYLES[vis.modes.NORMAL]
        if win ~= vis.win and STYLES.UNFOCUSED then
            m_style = STYLES.UNFOCUSED
        end
        vis.ui:style_define(MODAL_STYLE, m_style.REGULAR)
        vis.ui:style_define(MODAL_STYLE_INVERTED, m_style.INVERTED)
    end

    local w = win.width or 0
    local y = (win.height or 0) - 1
    if w <= 0 or y < 0 then return end

    local mode_len = string.len(vmode)
    local file_len = string.len(filename) + string.len(modified)

    -- Paint the ENTIRE width of the bar with the solid mode color (removes the white gap completely)
    for i = 0, w - 1 do
        win:style_pos(MODAL_STYLE, i, y)
    end


    -- Overwrite only the filename section with the inverted color
    for i = mode_len, mode_len + file_len - 1 do
        if i < w then
            win:style_pos(MODAL_STYLE_INVERTED, i, y)
        end
    end
end)
