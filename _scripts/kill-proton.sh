#! /bin/bash
wineserver -k
find $HOME/.PlayOnLinux/wineprefix/* -maxdepth 0 -exec /bin/bash -c 'export WINEPREFIX="{}"; /usr/bin/wineserver -k' \;
PFX=$(lsof | grep compatdata | grep 'pfx$' | awk '{print $NF}')
WINEPREFIX=$PFX wineserver -k
exit 0


