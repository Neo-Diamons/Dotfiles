local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local state_file = io.open(state_dir .. "/powersave/active")

local active = false
if state_file then
    active = state_file:read("*l") == "1"
    state_file:close()
end

if active then
    hl.config({
        animations = { enabled = false },
        decoration = {
            blur   = { enabled = false },
            shadow = { enabled = false },
        },
    })

    -- Monitor modes can't be listed from the config: a script caps them to 60 Hz once the reload is done
    hl.exec_cmd("python3 " .. os.getenv("HOME") .. "/.config/quickshell/scripts/powersave.py refresh")
end

return { active = active }
