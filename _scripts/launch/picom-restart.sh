#!/bin/bash


killall picom;

sleep 5;

/home/aaron/git/picom/build/src/picom \
--config /home/aaron/.config/picom.conf \
--glx-fshader-win "$(cat /home/aaron/.config/picom-shaders/shader.glsl)" &







