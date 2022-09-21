#!/bin/bash

pidfile=/tmp/trap.pid

if [ -e $pidfile ]
then
    kill -9 $(cat $pidfile)
    shutdownVpn;
else
    startupVpn;
fi


# Could add check for existence of mypidfile here if interlock is
# needed in the shell script itself.

# Ensure PID file is removed on program exit.
trap "rm -f -- '$pidfile'" EXIT

# Create a file with current PID to indicate that process is running.
echo $$ > "$pidfile"

sleep 20
