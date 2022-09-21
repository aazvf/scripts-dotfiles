#!/bin/bash



# DisplayPort-0 -> dp -> top left

# DVI-D-0 -> hdmi -> bottom left

# HDMI-A-0 -> hdmi -> bottom right


#xrandr --output DisplayPort-0 --primary --mode 1920x1080 --rate 60.00 --brightness 1 --output HDMI-A-0 --mode 1920x1080 --rate 60.00 --brightness 1 --right-of DisplayPort-0 --output DVI-D-0 --auto --mode 1920x1080 --rate 60.00 --brightness 1 --above DisplayPort-0


xrandr \
--output DVI-D-0 --primary --mode 1920x1080 --rate 60.00 --brightness 1 \
--output DisplayPort-0 --mode 3840x2160 --rate 60.00 --brightness 1 --above DVI-D-0 \
--output HDMI-A-0 --mode 1920x1080 --rate 60.00 --brightness 1 --right-of DVI-D-0 


#xrandr \
#--output DVI-D-0 --primary --mode 1920x1080 --rate 60.00 --brightness 1 \
#--output DisplayPort-0 --off \
#--output HDMI-A-0 --mode 1920x1080 --rate 60.00 --brightness 1 --right-of DVI-D-0 


/home/aaron/_scripts/background.sh


