#! /bin/sh
export EDITOR="vim"
export BROWSER="brave"
export TERMINAL="alacritty"



dwm &
dunst &
picom &

feh --bg-scale ~/Wallpapers/night.png
xautolock -time 10 -locker slock

sh ~/.scripts/startup.sh &
sh ~/.config/dwm-status/dwm-status.sh
