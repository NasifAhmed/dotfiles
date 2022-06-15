#!/bin/bash
#/*
# * ----------------------------------------------------------------------------
# * "THE BEER-WARE LICENSE" (Revision 42):
# * <plasmoduck@gmail.com> wrote this file.  As long as you retain this notice you
# * can do whatever you want with this stuff. If we meet some day, and you think
# * this stuff is worth it, you can buy me a beer in return.   Plasmoduck
# * ----------------------------------------------------------------------------
# */

#playing () {
#         mpc -h /usr/home/cjg/.mpd/socket | awk 'NR==1 {song = $0} NR==2 {if ($1 == "[playing]") p=1; len=$(NF-1); sub(/.*\//, "", len)} END {printf("%s (%s) %s\n", p?"":"", len, song)}'
#     }

# covid19 () {
#       curl https://corona-stats.online/bangladesh\?format\=json | python3 -c 'import sys,json;data=json.load(sys.stdin)["data"][0];print("", data["cases"],"","", "", data["deaths"])'
#   }

# dwm_spotify () {
#     if ps -C spotify > /dev/null; then
#         ARTIST=$(playerctl -p spotify metadata artist)
#         TRACK=$(playerctl -p spotify metadata title)
#         DURATION=$(playerctl -p spotify metadata mpris:length | sed 's/.\{6\}$//')
#         STATUS=$(playerctl -p spotify status)
# 
#         if [ "$STATUS" = "Playing" ]; then
#             STATUS="|  "
#         else
#             STATUS="|  "
#         fi
# 
#         printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
#         printf "%0d:%02d" $((DURATION%3600/60)) $((DURATION%60))
#         printf "%s\n" "$SEP2"
#     fi
# }

memory (){
        free -h | awk '/Mem:/ NR>1 {printf $3} NR>1 {print $7}' | sed 's/i/ ~ /1' | sed 's/i//1'
    }

# drive (){
#         df -h | grep '/$' | awk '{print $5}'
#     }

cpu_temp (){
        sensors | awk '/Tctl:/ {print $2}' | sed 's/+//g'
    }

volume (){
        pamixer --get-volume
    }

print_date (){
        date "+%a - %d/%m/%y - %I:%M:%S %p"
    }

weather() {
         LOCATION=Dhaka

         printf "%s" "$SEP1"
         if [ "$IDENTIFIER" = "unicode" ]; then
            printf "%s" "$(curl -s wttr.in/$LOCATION?format=1)"
         else
            printf "%s" "$(curl -s wttr.in/$LOCATION?format=1 | grep -o "[0-9].*")"
         fi
         printf "%s\n" "$SEP2"
    }

                                                         
while true
do
    xsetroot -name "    RAM $(memory)       CPU $(cpu_temp)       VOL $(volume)%        $(print_date)  "
    sleep 1s
done &


# Add all the startup programs after this
sleep 1 
# picom -bc --vsync&
nitrogen --restore&
qbittorrent&

exec /usr/local/bin/dwm
