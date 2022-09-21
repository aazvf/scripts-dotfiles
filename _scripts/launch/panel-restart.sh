#!/bin/bash


killall trayer;
killall conky;
killall picom

sleep 6;

trayer --edge bottom --align left --widthtype pixel --width 137 --heighttype pixel --height 24 --SetDockType true  --tint "B5DA76"  --SetPartialStrut false --expand true --padding 5 --transparent true --alpha 50 --margin 0 --monitor 1 &

conky -q -c /home/aaron/.config/conky/conky-bottom.conf &

/home/aaron/_scripts/launch/picom.sh




