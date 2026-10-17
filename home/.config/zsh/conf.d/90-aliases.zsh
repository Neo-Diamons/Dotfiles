# Aliases
_icons='--icons '
_is_vt && _icons=''

alias ls="eza ${_icons}--group-directories-first"
alias ll="eza -l  ${_icons}--group-directories-first --git"
alias la="eza -la ${_icons}--group-directories-first --git"
alias tree="eza --tree ${_icons}--level=2 --git-ignore"
unset _icons

alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias feh='feh --auto-zoom --scale-down --image-bg black'
