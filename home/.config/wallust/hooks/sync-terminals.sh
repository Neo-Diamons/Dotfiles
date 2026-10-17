#!/bin/sh
# Push foot's dark palette to every open terminal (OSC 4), so running
# terminals, tmux and vis recolour without a restart.

colors="$HOME/.config/foot/colors.ini"

palette=$(awk -F= '
  /^\[/ { dark = ($0 == "[colors-dark]"); next }
  dark && $1 ~ /^regular[0-7]$/ { printf "\033]4;%d;#%s\033\\", substr($1, 8), $2 }
  dark && $1 ~ /^bright[0-7]$/  { printf "\033]4;%d;#%s\033\\", 8 + substr($1, 7), $2 }
' "$colors")

for tty in /dev/pts/[0-9]*; do
  [ -O "$tty" ] && printf '%s' "$palette" > "$tty" 2>/dev/null
done
exit 0
