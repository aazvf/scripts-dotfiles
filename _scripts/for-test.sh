#!/bin/bash









MY_NAMESERVERS="8.8.8.8
8.8.4.4"

PRIMARY_NAMESERVER=(${MY_NAMESERVERS[@]});
PRIMARY_NAMESERVER=${PRIMARY_NAMESERVER[0]};


echo $PRIMARY_NAMESERVER;
#echo "${STRINGTEST[0]}"


exit;

VPN_IP="46.166.190.221
46.166.137.240
46.166.190.205
185.107.44.23
109.201.152.242
109.201.154.176
46.166.188.209
46.166.190.214
185.107.44.26
85.159.236.214
109.201.152.14
46.166.190.219
46.166.190.131
209.222.18.222
209.222.18.218
85.159.236.219"

TEST=$(host nl.privateinternetaccess.com | awk '/has address/ { print $4 }');

function vpnIps {
	dig 209.222.18.222 +short nl.privateinternetaccess.com
}


for i in $(vpnIps);
do
    echo hey $i;
done;
