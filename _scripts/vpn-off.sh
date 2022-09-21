#!/bin/bash

# Your VPN name on Network Manager, to list all connections you can use: nmcli con
VPN_NAME="PIA"
# List of apps you want to kill before disconnecting from the VPN, if you don't kill them, they will leak traffic
KILL_APPS="transmission-gtk vpn-on.sh nmcli"

# Killing apps
killall $KILL_APPS

# VPN disconnect
nmcli con down id $VPN_NAME

sudo ufw disable
sudo iptables -F
sudo iptables -X
sudo ufw enable

# Reset Firewall to defaults
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
