#!/bin/bash

sleep 0.1;

gnome-screenshot -a;

mv ~/Pictures/Screenshot* ~/Screenshots/
rename 's/\ /\./g' ~/Screenshots/Screenshot*.png
rename 's/Screenshot\.from\.//g' ~/Screenshots/Screenshot*.png

