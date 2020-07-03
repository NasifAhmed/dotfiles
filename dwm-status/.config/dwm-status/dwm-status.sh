#!/usr/local/bin/bash
#/*
# * ----------------------------------------------------------------------------
# * "THE BEER-WARE LICENSE" (Revision 42):
# * <plasmoduck@gmail.com> wrote this file.  As long as you retain this notice you
# * can do whatever you want with this stuff. If we meet some day, and you think
# * this stuff is worth it, you can buy me a beer in return.   Plasmoduck
# * ----------------------------------------------------------------------------
# */


dwm_spotify () {
    if ps -C spotify > /dev/null; then
        ARTIST=$(playerctl -p spotify metadata artist)
        TRACK=$(playerctl -p spotify metadata title)
        DURATION=$(playerctl -p spotify metadata mpris:length | sed 's/.\{6\}$//')
        STATUS=$(playerctl -p spotify status)

        if [ "$IDENTIFIER" = "unicode" ]; then
            if [ "$STATUS" = "Playing" ]; then
                STATUS="▶"
            else
                STATUS="⏸"
            fi
        else
            if [ "$STATUS" = "Playing" ]; then
                STATUS="PLA"
            else
                STATUS="PAU"
            fi
        fi

        printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
        printf "%0d:%02d" $((DURATION%3600/60)) $((DURATION%60))
        printf "%s\n" "$SEP2"
    fi
}


#playing () {
#         mpc -h /usr/home/cjg/.mpd/socket | awk 'NR==1 {song = $0} NR==2 {if ($1 == "[playing]") p=1; len=$(NF-1); sub(/.*\//, "", len)} END {printf("%s (%s) %s\n", p?"":"", len, song)}'
#     }

# covid19 () {
#        curl https://corona-stats.online/bangladesh\?format\=json | python3 -c 'import sys,json;data=json.load(sys.stdin)["data"][0];print("", data["cases"],"","", "", data["deaths"])'
#    }

memory (){
        free -h | awk '/Mem:/ {print $7}'
    }

drive (){
        df -h | grep '/$' | awk '{print $5}'
    }

cpu_temp (){
        sensors | awk '/Tctl:/ {print $2}'
    }

volume (){
        pamixer --get-volume
    }

print_date (){
        date "+%b %d (%a), %I:%M:%S %p"
    }

#weather() {
#         LOCATION=Dhaka
#
#         printf "%s" "$SEP1"
#         if [ "$IDENTIFIER" = "unicode" ]; then
#            printf "%s" "$(curl -s wttr.in/$LOCATION?format=1)"
#         else
#            printf "%s" "$(curl -s wttr.in/$LOCATION?format=1 | grep -o "[0-9].*")"
#         fi
#         printf "%s\n" "$SEP2"
#    }

                                                         
while true
do
    xsetroot -name "$(dwm_spotify)  $(memory)    $(drive)    $(cpu_temp)    $(volume)%    $(print_date)"
    sleep 1s
done
