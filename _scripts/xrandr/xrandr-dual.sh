#!/bin/bash
#xrandr --output DVI-D-0 --off --output DisplayPort-0 --auto --mode 1920x1080 --rate 60.00 --primary --output HDMI-A-0 --auto --right-of DisplayPort-0




#xrandr --output DisplayPort-0 --auto --primary --mode 1920x1080 --rate 60.00 --output DVI-D-0 --auto --mode 1920x1080 --rate 60.00 --above DisplayPort-0 --output HDMI-A-0 --auto --right-of DisplayPort-0


# old version
#xrandr --output DisplayPort-0 --auto --primary --mode 1920x1080 --rate 60.00 --output HDMI-A-0 --auto --right-of DisplayPort-0 --output DVI-D-0 --off




xrandr \
--output DVI-D-0 --primary --mode 1920x1080 --rate 60.00 --brightness 1 \
--output DisplayPort-0 --off \
--output HDMI-A-0 --mode 1920x1080 --rate 60.00 --brightness 1 --right-of DVI-D-0 
