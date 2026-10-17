#!/bin/sh

wall_dir="$HOME/Pictures/Wallpapers"
wallpaper=$(find "$wall_dir" -type f -iname '*.jxl' | shuf -n 1)

if [ -n "$wallpaper" ]; then
    wallust run "$wallpaper"
fi

exec hyprpaper
