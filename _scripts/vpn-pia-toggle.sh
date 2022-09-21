#!/bin/bash


# nmcli con
VPN_NAME="PIA"

# The VPN connection domain
VPN_ENDPOINT="nl.privateinternetaccess.com"

# iwconfig
NW_DEVICE="wlp1s0"

# Local Network Range
LOCAL_NW="192.168.0.0/16"

# Nameservers from `systemd-resolve --status`
# These are explicitly blocked while connected. I imagine it could help prevent dns leaks.
MY_NAMESERVERS="8.8.8.8
8.8.4.4"

# Nameservers used while on VPN, these are explicitly allowed, but probably not actually required.
VPN_NAMESERVERS="209.222.18.222
209.222.18.218"

# VPN Tunnel device
NW_TUN="tun0"

# List of apps you want to kill before disconnecting from the VPN, if you don't kill them, they will leak traffic
KILL_APPS="transmission-gtk"


# Reset firewall and block all connections
function denyAll {
	sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default deny outgoing
}

# Allow our default servers
function allowDns {
	for i in $MY_NAMESERVERS;
	do
	    sudo ufw delete deny out from any to $i
	    sudo ufw allow out on $NW_DEVICE from any to $i
	done;
}

# Deny our default nameservers
function denyDns {
	for i in $MY_NAMESERVERS;
	do
	    sudo ufw delete allow out on $NW_DEVICE from any to $i
	    sudo ufw insert 1 deny out from any to $i
	done;
}

# Allow the VPN DNS servers
function allowVpnDns {
	for i in $VPN_NAMESERVERS;
	do
	    sudo ufw allow out on $NW_DEVICE from any to $i
	done;
}

# Allow connections to VPN IP addresses
function allowVpnIps {
	for i in $(dig +short $VPN_ENDPOINT);
    do
        sudo ufw allow out on $NW_DEVICE from any to $i
    done;
}

# Allow all through the tun0 tunnel.
function allowVPNTunnel {
	sudo ufw allow out on $NW_TUN from any to any
}

# Allow local network connections
function allowLocal {
	sudo ufw allow out on $NW_DEVICE from any to $LOCAL_NW
    sudo ufw allow in on $NW_DEVICE from $LOCAL_NW to any
}

# Start/Enable VPN connection via network-manager
function connectToVpn {
	nmcli con up id $VPN_NAME
}

# Stop/Disable VPN connection via network-manager
function disconnectVpn {
	nmcli con down id $VPN_NAME 
}

# Monitor the connection
function monitor {
	
	notify-send -i changes-prevent "VPN" "Connecting..."
	connectToVpn;
	denyDns;
    notify-send -i checkmark "VPN" "Connected"
    
    # Wait for VPN connection to drop.
    nmcli connection monitor $NW_TUN 
    
    notify-send -i dialog-error "VPN" "Lost Connection..."
    disconnectVpn;
    allowVpnIps;
    notify-send -i time-admin "VPN" "Sleeping..."
    sleep 5 
    
    allowDns;
    monitor
    
}

# Enable VPN and killswitch
function startupVpnKillswitch {
	notify-send -i flag-green "VPN" "Starting KILLSWITCH"

    denyAll;
    allowDns;
    allowVpnDns;
    allowVpnIps;
    allowVPNTunnel;
    allowLocal;

    sudo ufw enable;
    monitor;
}

# Disable VPN and killswitch
function shutdownVpnKillswitch {
	notify-send -i flag-red "VPN" "EXITING VPN"
	# Killing apps
    killall $KILL_APPS

    # VPN disconnect
    disconnectVpn;

    # Restart Firewall
    sudo ufw disable
    sudo iptables -F
    sudo iptables -X

    # Reset Firewall to defaults
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
}



# The following pid file and if statement figure out whether to toggle the VPN on or off.

pidfile=/tmp/vpn-toggle.pid

trap "rm -f -- '$pidfile'" EXIT


if [ -e $pidfile ]
then
    kill $(cat $pidfile)
    killall nmcli;
    shutdownVpnKillswitch;
    rm -f -- '$pidfile'
else
    echo $$ > "$pidfile"
    startupVpnKillswitch;
fi


