#!/bin/bash
pico2wave -w=say.wav "$1"
aplay ./say.wav
rm ./say.wav

