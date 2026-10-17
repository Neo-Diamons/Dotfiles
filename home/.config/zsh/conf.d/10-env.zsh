# Environment
typeset -U path PATH # de-duplicate PATH entries
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)

_is_vt() { [[ $TERM == linux* || $TTY == /dev/tty[0-9]* ]] }

export EDITOR=vis
export MANROFFOPT="-c"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# CUDA (disabled)
#path=(/opt/cuda/bin $path)
#export LD_LIBRARY_PATH=/opt/cuda/lib64:/opt/cuda/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
