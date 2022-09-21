#!/bin/bash



CURRENT_WORKSPACES=$(wmctrl -d | grep \*) ;

echo ${CURRENT_WORKSPACES: -1}

