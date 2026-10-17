# Completion (native zsh menu)
_comp_options+=(globdots)                                   # include dotfiles
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true                          # see new binaries
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{3}%d%f'
zstyle ':completion:*:warnings'     format '%F{1}no matches%f'
