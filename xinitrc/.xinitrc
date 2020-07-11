#! /bin/sh
export EDITOR="vim"
export BROWSER="brave"
export TERMINAL="alacritty"



dwm &
dunst &
picom &
dwmblocks &

feh --bg-scale ~/dotfiles/Pictures/Wallpapers/1589700859928.png

sh ~/.scripts/startup.sh &

xautolock -time 10 -locker slock 
