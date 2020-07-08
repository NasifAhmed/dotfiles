#! /bin/sh
export EDITOR="vim"
export BROWSER="brave"
export TERMINAL="alacritty"



dwm &
dunst &
picom &
dwmblocks &

feh --bg-scale ~/Wallpapers/night.png &

sh ~/.scripts/startup.sh &

xautolock -time 10 -locker slock 
