#!/bin/bash

killall redshift-gtk 2> /dev/null;
killall redshift 2> /dev/null;

export REDSHIFT_TEMPERATURE=6250:3400
export REDSHIFT_LOCATION=51.5:-0.13
export REDSHIFT_GAMMA=1.2:1.2:1.2

#redshift -m randr -l manual -t $REDSHIFT_TEMPERATURE -l $REDSHIFT_LOCATION -g $REDSHIFT_GAMMA &

redshift-gtk -x -t $REDSHIFT_TEMPERATURE -l $REDSHIFT_LOCATION -g $REDSHIFT_GAMMA &
#redshift -x -t $REDSHIFT_TEMPERATURE -l $REDSHIFT_LOCATION -g $REDSHIFT_GAMMA &



