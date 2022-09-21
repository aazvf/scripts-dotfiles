#!/bin/bash


killall trayer;
killall conky;

sleep 0.2;

trayer --edge top --align left --widthtype pixel --width 137 --heighttype pixel --height 24 --SetDockType true  --tint "B5DA76"  --SetPartialStrut false --expand true --padding 5 --transparent true --alpha 50 --margin 0 --monitor 1 &

conky -q -c /home/aaron/.config/conky/conky-top.conf &



