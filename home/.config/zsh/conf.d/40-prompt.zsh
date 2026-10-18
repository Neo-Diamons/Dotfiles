# Prompt
unsetopt PROMPT_SP

if _is_vt || [[ $TERM == eterm-color ]]; then
  PROMPT='%(?.%F{2}.%F{1})%n@%m%f %F{4}%~%f %# '
else
  eval "$(starship init zsh)"

  _sync_window_size() {
    add-zsh-hook -d precmd _sync_window_size
    local -a size=($(tmux display-message -p -t $TMUX_PANE '#{pane_height} #{pane_width}' 2>/dev/null))
    (( $#size == 2 )) && stty rows $size[1] cols $size[2]
  }
  [[ -n $TMUX ]] && add-zsh-hook precmd _sync_window_size

  _transient_prompt_accept_line() {
    local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
    PROMPT='%(?.%F{2}.%F{1})%B❯%b%f '
    RPROMPT=''
    zle reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt
    zle .accept-line
  }
  zle -N _transient_prompt_accept_line
  bindkey '^M' _transient_prompt_accept_line
fi
