_run_startup_fetch() {
  add-zsh-hook -d precmd _run_startup_fetch

  [[ -n "$ZED_TERM" ]] && return
  [[ -n "$TMUX" && -n "$(tmux show-options -qv @greeted)" ]] && return
  _is_vt && return
  (( LINES >= 30 && COLUMNS >= 60 )) || return
  command -v fastfetch &>/dev/null || return
  [[ -n "$TMUX" ]] && tmux set-option -q @greeted 1

  local info_w=50 gap=3
  local max_logo_w=$(( COLUMNS - info_w - gap ))
  local dir="$HOME/.config/fastfetch/ascii"
  local -a fitting
  local f

  clear
  if (( max_logo_w > 10 )) && [[ -d $dir ]]; then
    for f in "$dir"/*(.N); do
      (( $(wc -L < "$f") <= max_logo_w && $(wc -l < "$f") < LINES - 2 )) && fitting+=("$f")
    done
  fi

  if (( ${#fitting} )); then
    fastfetch --logo "${fitting[RANDOM % ${#fitting} + 1]}"
  else
    fastfetch --logo none
  fi
}
add-zsh-hook precmd _run_startup_fetch
