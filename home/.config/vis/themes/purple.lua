local lexers = vis.lexers or require('lexer')

local colors = {
    bg         = '#1e1a29',
    fg         = '#e0def4',
    selection  = '#3e355b',
    comment    = '#6e6a86',
    keyword    = '#c4a7e7',
    builtin    = '#eb6f92',
    string     = '#9ccfd8',
    number     = '#ea9a97',
    identifier = '#e0def4',
    operator   = '#b4637a',
    status_bg  = '#2a2438',
    status_fg  = '#c4a7e7',
}

local theme = {
    color = colors,
    styles = {
        [lexers.DEFAULT]       = 'fore:' .. colors.fg .. ',back:' .. colors.bg,
        [lexers.WHITESPACE]    = '',
        [lexers.COMMENT]       = 'fore:' .. colors.comment .. ',italics',
        [lexers.KEYWORD]       = 'fore:' .. colors.keyword .. ',bold',
        [lexers.IDENTIFIER]    = 'fore:' .. colors.identifier,
        [lexers.STRING]        = 'fore:' .. colors.string,
        [lexers.NUMBER]        = 'fore:' .. colors.number,
        [lexers.CONSTANT]      = 'fore:' .. colors.builtin,
        [lexers.VARIABLE]      = 'fore:' .. colors.fg,
        [lexers.TYPE]          = 'fore:' .. colors.keyword,
        [lexers.FUNCTION]      = 'fore:' .. colors.keyword,
        [lexers.CLASS]         = 'fore:' .. colors.keyword .. ',bold',
        [lexers.OPERATOR]      = 'fore:' .. colors.operator,
        [lexers.PREPROCESSOR]  = 'fore:' .. colors.keyword,
        [lexers.ERROR]         = 'fore:#eb6f92,reverse',

        -- Vis UI Elements
        ['cursor']             = 'reverse',
        ['cursor-line']        = 'back:#262035',
        ['selection']          = 'back:' .. colors.selection,
        ['line-number']        = 'fore:#56526e,back:' .. colors.bg,
        ['line-number-cursor'] = 'fore:' .. colors.keyword .. ',bold',
        ['status']             = 'fore:' .. colors.status_fg .. ',back:' .. colors.status_bg,
        ['status-focused']     = 'fore:black,back:magenta,bold',
    },
}

return theme
