#!/bin/bash


#xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --auto --mode 1920x1080 --right-of HDMI-1

# new curved monitor upside down
# xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --auto --right-of HDMI-1 --rotate inverted

# 4k monitor on left of curved
#xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 2560x1440 --rate 59.95 --primary --output DP-1 --auto --right-of HDMI-1



xrandr --output eDP-1 --off --output HDMI-1 --auto --mode 1920x1080 --rate 60.00 --primary --output DP-1 --auto --right-of HDMI-1


