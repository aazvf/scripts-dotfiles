#!/bin/bash


# nmcli con
VPN_NAME="mullvad_ie_all"

# The VPN connection domain
VPN_ENDPOINTS="ie-dub-001.mullvad.net
ie-dub-002.mullvad.net"

# iwconfig
NW_DEVICE="enp4s0"

# Local Network Range
LOCAL_NW="192.168.0.0/16"

# Nameservers from `systemd-resolve --status`
# These are explicitly blocked while connected. I imagine it could help prevent dns leaks.
MY_NAMESERVERS="8.8.8.8
8.8.4.4
1.1.1.1"

MY_NAMESERVER="1.1.1.1"

# Nameservers used while on VPN, these are explicitly allowed, but probably not actually required.
VPN_NAMESERVERS="10.8.0.1"

# VPN Tunnel device
NW_TUN="tun0"

# List of apps you want to kill before disconnecting from the VPN, if you don't kill them, they will leak traffic
KILL_APPS="transmission-gtk"



# Check connection to mullvad
function mullvadConnected {
    curl -s https://am.i.mullvad.net/connected
}


# Get our ip
function mullvadIp {
    curl -s https://am.i.mullvad.net/ip
}

# Get our ip
function ipinfo {
    curl -s https://ipinfo.io
}



# Set our nameservers back to normal
function setDefaultNameservers {
    sudo systemd-resolve --interface $NW_DEVICE --set-dns $MY_NAMESERVER
}

# Set our nameservers to secure vpn dns
function setVpnNameservers {
    sudo systemd-resolve --interface $NW_DEVICE --set-dns $VPN_NAMESERVERS
}


# Disable and flush firewall
function disableFlushFirewall {
    sudo ufw disable
    sudo iptables -F
    sudo iptables -X
}


# Reset firewall rules
function resetFirewallRules {
	sudo ufw --force reset
}

# Apply new firewall rules
function enableFirewall {
	sudo ufw enable
}


# Reset firewall and block all connections
function denyAll {
    resetFirewallRules;
    sudo ufw default deny incoming
    sudo ufw default deny outgoing
}


# Reset firewall to default. deny incoming allow outgoing
function allowIncoming {
    resetFirewallRules;
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
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
    for VPN_ENDPOINT in $VPN_ENDPOINTS;
    do
        echo "ENDPOINT $VPN_ENDPOINT";
        for i in $(dig +short $VPN_ENDPOINT);
        do
            echo $i;
            sudo ufw allow out on $NW_DEVICE from any to $i
        done;
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

# Start VPN service
function connectToVpn {
    
    sudo systemctl start "openvpn-client@$VPN_NAME"

}

# Stop VPN Service
function disconnectVpn {
    
    sudo systemctl stop "openvpn-client@$VPN_NAME"

}


# Enable VPN service autostart
function enableVpnService {
    
    sudo systemctl enable "openvpn-client@$VPN_NAME"
    
}

# Disable VPN service autostart
function disableVpnService {
    
    sudo systemctl disable "openvpn-client@$VPN_NAME"
    

}


# Notify alert
function alert {
    notify-send -i flag-red "VPN" "$1"    
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

    # Block all connections then allow tunnel to vpn
    denyAll;
    allowDns;
    allowVpnDns;
    allowVpnIps;
    allowVPNTunnel;
    allowLocal;
    
    # Start firewall
    enableFirewall;

	connectToVpn;
    setVpnNameservers;
	denyDns;
    
    notify-send -i checkmark "VPN" "Connected"
    
    
}

# Disable VPN and killswitch
function shutdownVpnKillswitch {
	notify-send -i flag-red "VPN" "EXITING VPN"
	# Killing apps
    killall $KILL_APPS

    # VPN disconnect
    disconnectVpn;

    # Disable firewall
    disableFlushFirewall;

    # Reset Firewall to defaults
    allowIncoming;
    enableFirewall;
    
    setDefaultNameservers;

    notify-send -i flag-red "VPN" "Disconnected"

}



if [ "$1" = "check" ]; then
    STATUS=$(mullvadConnected);
    alert "$STATUS";
    echo $STATUS
    exit;
fi

if [ "$1" = "ip" ]; then
    echo $(mullvadIp)
    exit;
fi


if [ "$1" = "ipinfo" ]; then
    echo $(ipinfo)
    exit;
fi


if [ "$1" = "start" ]; then
    connectToVpn;
    alert "Started openvpn service"
    exit;
fi

if [ "$1" = "stop" ]; then
    disconnectVpn;
    alert "Stopped openvpn service"
    exit;
fi

if [ "$1" = "enable" ]; then
    connectToVpn;
    enableVpnService;
    alert "Enabled openvpn service"
    exit;
fi

if [ "$1" = "disable" ]; then
    disconnectVpn;
    disableVpnService;
    alert "Disabled openvpn service"
    exit;
fi



# The following pid file and if statement figure out whether to toggle the VPN on or off.

pidfile=/tmp/vpn-toggle.pid

#trap "rm -f -- '$pidfile'" EXIT


if [ -e $pidfile ]
then
    kill $(cat $pidfile)
    shutdownVpnKillswitch;
    rm -f -- $pidfile
else
    echo $$ > "$pidfile"
    startupVpnKillswitch;
fi



# sudo systemd-resolve --interface wlp2s0 --set-dns 192.168.88.22 --set-domain yourdomain.local
