# Tools & keybindings

# --- Tool integrations ---
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# --- fzf ---
_fd_skip=(
  .git .venv .direnv .cache .local/share .var .steam .claude .ansible
  .cargo .rustup .npm .fnm node_modules __pycache__ .mypy_cache
  site-packages lib target Games Bottles
)
_fd_excludes=${(j: :)${_fd_skip/#/--exclude }}
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $_fd_excludes"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $_fd_excludes"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=16,bg:-1,bg+:0,gutter:-1,fg+:15,hl:5,hl+:5,info:8,prompt:5,pointer:5,marker:5,border:5'
unset _fd_skip _fd_excludes

# Ctrl-R: history search
# Ctrl-T: file picker
# Alt-C: directory picker
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh

# Ctrl-F: zoxide picker
if command -v zoxide &>/dev/null; then
  _zoxide_pick() { zle -I; cdi; zle reset-prompt }
  zle -N _zoxide_pick
  bindkey '^F' _zoxide_pick
fi

# --- Keybindings ---
KEYTIMEOUT=30                       # 300ms: enough for ESC sequences / paste markers
WORDCHARS=${WORDCHARS//[\/]}        # Ctrl-W stops at path separators

# Word navigation / deletion
bindkey '^[[1;5C' forward-word      # Ctrl-Right
bindkey '^[[1;5D' backward-word     # Ctrl-Left
bindkey '^[[3;5~' kill-word         # Ctrl-Del
bindkey '^[[3;3~' kill-word         # Alt-Del

# Delete / backspace
bindkey '^[[3~'   delete-char
bindkey '^[[P'    delete-char
bindkey '^?'      backward-delete-char
bindkey '^H'      backward-delete-char

# Home / End (TTY console, xterm, rxvt)
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[1~'   beginning-of-line
bindkey '^[[4~'   end-of-line
bindkey '^[[7~'   beginning-of-line
bindkey '^[[8~'   end-of-line

# terminfo fallbacks
for _k in "${terminfo[kdch1]}:delete-char" "${terminfo[khome]}:beginning-of-line" "${terminfo[kend]}:end-of-line"; do
  [[ -n "${_k%%:*}" ]] && bindkey "${_k%%:*}" "${_k##*:}"
done
unset _k
