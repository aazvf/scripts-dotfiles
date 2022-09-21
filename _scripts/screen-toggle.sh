#!/bin/bash

# turn screens off/on
# (ɔ) alex cabal

screenOffLockFile=/tmp/screen-off-lock

if [ -f $screenOffLockFile ];
then
    rm $screenOffLockFile
    notify-send "Screen on." -i /usr/share/icons/gnome/48x48/devices/display.png
    sleep 2;
    /home/aaron/_scripts/launch/picom.sh
else
    touch $screenOffLockFile
    killall picom;
    sleep .5
    while [ -f  $screenOffLockFile ]
    do
        xset dpms force off
        sleep 2
    done
    xset dpms force on
fi


