#!/bin/sh

dir=/var/lib/quickshell-greeter
colors="$HOME/.config/quickshell/config/Colors.qml"

[ -w "$dir" ] && [ -f "$colors" ] || exit 0

wallpaper=$(sed -n 's/^ *readonly property string wallpaper: "\(.*\)"$/\1/p' "$colors")
[ -f "$wallpaper" ] || exit 0

target="$dir/wallpaper.${wallpaper##*.}"
theme="$dir/theme.json"
changed=

if ! cmp -s "$wallpaper" "$target"; then
    cp "$wallpaper" "$target.tmp" && chmod 644 "$target.tmp" && mv -f "$target.tmp" "$target" || exit 0
    changed=1
fi

awk -v wallpaper="$target" '
    /^ *readonly property color [A-Za-z0-9_]+: "#[0-9A-Fa-f]+"$/ {
        name = $4
        sub(/:$/, "", name)
        split($0, parts, "\"")
        colors = colors (colors == "" ? "" : ",") "\"" name "\":\"" parts[2] "\""
    }
    END { printf "{\"wallpaper\":\"%s\",\"colors\":{%s}}\n", wallpaper, colors }
' "$colors" > "$theme.tmp" || { rm -f "$theme.tmp"; exit 0; }

if ! cmp -s "$theme.tmp" "$theme"; then
    chmod 644 "$theme.tmp" && mv -f "$theme.tmp" "$theme" || exit 0
    changed=1
else
    rm -f "$theme.tmp"
fi

rm -f "$dir/Colors.qml"
for old in "$dir"/wallpaper.*; do
    [ "$old" = "$target" ] || rm -f "$old"
done

[ -z "$changed" ] || echo synced
exit 0
