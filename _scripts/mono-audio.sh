#!/bin/bash

echo "Look for alsa_output.pci-0000_00_1f.3.analog-stereo and paste in master=";
echo "------------------------------------";
pacmd list-sinks | grep name:
echo "------------------------------------";
echo "pacmd load-module module-remap-sink sink_name=mono master= channels=2 channel_map=mono,mono"

