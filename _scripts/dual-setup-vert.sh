#!/bin/bash



#xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --auto --mode 1920x1080 --right-of HDMI-1

# new curved monitor upside down
#xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --auto --mode 1920x1080 --above HDMI-1 --rotate normal


xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --mode 1920x1080R --rate 60.00 --above HDMI-1 --rotate normal






nitrogen --restore

setxkbmap -device 12 -layout us;

