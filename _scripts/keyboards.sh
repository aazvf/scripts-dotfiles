#!/bin/bash

DEVICE=$(xinput -list | grep key | grep "USB Keyboard" | grep -oh "12\|13");

if [ -z $DEVICE ]; then
    echo "Getting Keyboard List";
    echo "======================================";
    xinput -list | grep key | grep "Keyboard";
    echo "======================================";
    echo "Look for"
    echo " USB Keyboard                            	id=12	[slave  keyboard (3)]"
    echo "======================================";
    echo "setxkbmap -device 10 -layout us"
    exit;
fi;

echo "Setting device ID $DEVICE to US layout";
echo "setxkbmap -device $DEVICE -layout us";
setxkbmap -device $DEVICE -layout us;
echo "Done.";

#setxkbmap -device 12 -layout us


# xinput -list | grep key | grep "USB Keyboard";

#echo "look for"
#echo " USB Keyboard                            	id=12	[slave  keyboard (3)]"
#echo "setxkbmap -device 12 -layout us"

#setxkbmap -device 12 -layout us
#setxkbmap -device 15 -layout gb
