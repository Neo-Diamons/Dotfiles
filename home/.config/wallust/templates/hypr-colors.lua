return {
    background      = "{{background}}",
    foreground      = "{{foreground}}",

    active_border   = "rgba({{color5 | strip}}ff)",
    inactive_border = "rgba({{background | lighten(0.10) | strip}}ff)",
    shadow          = "rgba({{background | strip}}ee)",
    group_active    = "rgba({{color5 | strip}}ff)",
    group_inactive  = "rgba({{background | lighten(0.06) | strip}}ff)",
}
