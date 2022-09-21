#!/bin/bash



kill $(cat /tmp/conky-help-pid) && exit;


( cmdpid=$BASHPID; echo $BASHPID > /tmp/conky-help-pid; (sleep 25; if [ "$cmdpid" == "$(cat /tmp/conky-help-pid)" ]; then kill $(cat /tmp/conky-help-pid); fi ) & exec conky -q -c /home/aaron/.config/conky/help.conf )





