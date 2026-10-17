# Prompt
if _is_vt || [[ $TERM == eterm-color ]]; then
  PROMPT='%(?.%F{2}.%F{1})%n@%m%f %F{4}%~%f %# '
else
  eval "$(starship init zsh)"

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
