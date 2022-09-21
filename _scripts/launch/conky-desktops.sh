#!/bin/bash


kill $(cat /tmp/conky-desktops-pid) && exit;

#echo $$ > /tmp/conky-desktops-pid;


php /home/aaron/_scripts/desktops.php

#timeout 25s conky -q -c /home/aaron/.config/conky/desktops.conf &


## Get the pid of the sleep command and store in tmp file
## after 10 seconds, if the pid in the file matches the variable then kill it
## this prevents killing another pid launched later 
( cmdpid=$BASHPID; echo $BASHPID > /tmp/conky-desktops-pid; (sleep 20; if [ "$cmdpid" == "$(cat /tmp/conky-desktops-pid)" ]; then kill $(cat /tmp/conky-desktops-pid); fi ) & exec conky -q -c /home/aaron/.config/conky/desktops.conf )





#( cmdpid=$BASHPID; (sleep 10; kill $cmdpid) & exec conky -q -c /home/aaron/.config/conky/desktops.conf )

