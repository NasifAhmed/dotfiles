#! /bin/sh
export EDITOR="vim"
export BROWSER="brave"
export TERMINAL="alacritty"



dwm &
dunst &
picom &

feh --bg-scale ~/Wallpapers/night.png &

sh ~/.scripts/startup.sh &
sh ~/.config/dwm-status/dwm-status.sh &

xautolock -time 10 -locker slock 
