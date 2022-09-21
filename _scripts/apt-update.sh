#!/bin/bash

sudo apt update;

sudo apt upgrade -y;

sudo apt autoremove -y;

sudo rm /usr/lib/firefox/browser/features/*.xpi
