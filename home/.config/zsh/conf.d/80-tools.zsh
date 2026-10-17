# Tools & keybindings

# --- Tool integrations ---
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v atuin  &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh   # Ctrl-T, Alt-C

# Ctrl-R: atuin replaces fzf's history widget
bindkey -r '^R' 2>/dev/null
command -v atuin &>/dev/null && bindkey '^R' atuin-search

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
