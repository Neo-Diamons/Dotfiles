require("vis")

local _comment = require("plugins/vis-commentary")
local lsp = require("plugins/vis-lspc")
vis.ftdetect.filetypes.bash = {
    ext = { '%.sh$', '%.bash$', '%.zsh$', '%.zshrc$', '^%.?zshrc$' },
}
vis.ftdetect.filetypes.qml = {
    ext = { '%.qml$' }
}
lsp.highlight_diagnostics = false
lsp.ls_map.lua = {
    name = 'lua-language-server',
    cmd = 'lua-language-server',
    settings = {
        Lua = { diagnostics = { globals = { 'vis' } }, telemetry = { enable = false } },
    },
    formatting_options = { tabSize = 2, insertSpaces = true },
}
lsp.ls_map.qml = {
    name = 'qmlls',
    cmd = 'qmlls6',
    formatting_options = { tabSize = 4, insertSpaces = true },
}

require("status")

vis.events.subscribe(vis.events.INIT, function()
    vis:command("set theme purple")
end)
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command("set tabwidth 4")
    vis:command("set numbers true")
end)

local show_numbers = true

vis:map(vis.modes.NORMAL, "<C-n>", function()
    show_numbers = not show_numbers
    vis:command("set numbers " .. tostring(show_numbers))
    vis:redraw()
end, "Toggle line numbers")
