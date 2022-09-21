#!/bin/bash


A=1

for i in {1..9}
do
    A=$(($i%2))
    echo $A | tee '/sys/class/leds/input37::capslock/brightness' > /dev/null 2>&1
    sleep 0.1
done


#sleep 0.1
#echo 1 | tee '/sys/class/leds/input18::capslock/brightness' > /dev/null 2>&1
#sleep 0.1
#echo 0 | tee '/sys/class/leds/input18::capslock/brightness' > /dev/null 2>&1

