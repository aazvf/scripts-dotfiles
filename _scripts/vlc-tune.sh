#!/bin/bash


CURRENT_TUNE=$(wmctrl -l | grep "N/A " | grep -v "nineteen")

echo ${CURRENT_TUNE:22:-19};

#0x00c00005 5 N/A Azeriff X 6 day of august X Anastasia Lazariuc - Spring is Back 2 Town - VLC media player
