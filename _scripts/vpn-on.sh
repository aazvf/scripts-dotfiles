#!/bin/bash

# nmcli con
VPN_NAME="PIA"

# iwconfig
NW_DEVICE="wlp1s0"

# Local Network Range
LOCAL_NW="192.168.0.0/16"

# VPN Tunnel device
NW_TUN="tun0"


# Reset firewall and block all connections
function denyAll {
	sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default deny outgoing
}

# Allow the google DNS servers
function allowDns {
	sudo ufw delete deny out from any to 8.8.8.8
	sudo ufw delete deny out from any to 8.8.8.8
	sudo ufw allow out on $NW_DEVICE from any to 8.8.8.8
    sudo ufw allow out on $NW_DEVICE from any to 8.8.4.4
}

# Deny the google DNS servers
function denyDns {
	sudo ufw delete allow out on $NW_DEVICE from any to 8.8.8.8
	sudo ufw delete allow out on $NW_DEVICE from any to 8.8.4.4
	
	sudo ufw insert 1 deny out from any to 8.8.8.8
	sudo ufw insert 1 deny out from any to 8.8.4.4
}

# Allow the two VPN DNS servers
function allowVpnDns {
	sudo ufw allow out on $NW_DEVICE from any to 209.222.18.222
    sudo ufw allow out on $NW_DEVICE from any to 209.222.18.218
}

# Allow connections to VPN IP addresses
function allowVpnIps {
	for i in $(dig 209.222.18.222 +short nl.privateinternetaccess.com);
    do
        echo "Allowing $i";
        sudo ufw allow out on $NW_DEVICE from any to $i
    done;
}

# Allow all through the tun0 tunnel.
function allowVPNTunnel {
	sudo ufw allow out on $NW_TUN from any to any
    #sudo ufw allow in on $NW_TUN from any to any
    #sudo ufw allow out 1197/udp
}

# Allow local network connections
function allowLocal {
	sudo ufw allow out on $NW_DEVICE from any to $LOCAL_NW
    sudo ufw allow in on $NW_DEVICE from $LOCAL_NW to any
}

notify-send -i flag-green "VPN" "Starting KILLSWITCH"

denyAll;
allowDns;
allowVpnDns;
allowVpnIps;
allowVPNTunnel;
allowLocal;

sudo ufw enable;

# Start/Enable VPN
function enableVpn {
	nmcli con up id $VPN_NAME
}

# Stop/Disable VPN
function disableVpn {
	nmcli con down id $VPN_NAME 
}

# Monitor the connection
function monitor {
	
	notify-send -i changes-prevent "VPN" "Connecting..."
	enableVpn;
	denyDns;
    notify-send -i checkmark "VPN" "Connected"
    
    nmcli connection monitor $NW_TUN 
    
    notify-send -i dialog-error "VPN" "Lost Connection..."
    disableVpn;
    allowVpnIps;
    notify-send -i time-admin "VPN" "Sleeping..."
    sleep 5 
    
    allowDns;
    monitor
    
}

monitor;
