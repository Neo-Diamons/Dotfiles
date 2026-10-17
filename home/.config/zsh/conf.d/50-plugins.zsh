# Plugins (turbo: loaded after the first prompt)
zinit wait lucid for \
    OMZP::git \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
        zsh-users/zsh-history-substring-search \
    atinit"zicompinit -C; zicdreplay" \
        zsh-users/zsh-syntax-highlighting
