# Colours: syntax highlighting + fzf (palette-following)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES=(
  default               'none'
  unknown-token         'fg=1'
  reserved-word         'fg=5'
  alias                 'fg=2'
  builtin               'fg=2'
  function              'fg=2'
  command               'fg=2'
  precommand            'fg=2,underline'
  arg0                  'fg=2'
  commandseparator      'fg=5'
  redirection           'fg=5'
  path                  'underline'
  globbing              'fg=4'
  assign                'fg=4'
  single-hyphen-option  'fg=6'
  double-hyphen-option  'fg=6'
  single-quoted-argument 'fg=3'
  double-quoted-argument 'fg=3'
  dollar-quoted-argument 'fg=3'
  back-quoted-argument  'fg=5'
  comment               'fg=8'
)

# fzf: `16` = terminal ANSI palette; bg -1 = transparent
_fd_excludes='--exclude .git --exclude .venv --exclude node_modules --exclude .direnv --exclude __pycache__ --exclude .mypy_cache'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $_fd_excludes"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $_fd_excludes"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=16,bg:-1,bg+:-1,gutter:-1,hl:4,hl+:4,info:3,prompt:4,pointer:1,marker:2,border:8'
unset _fd_excludes
