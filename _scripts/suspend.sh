#!/bin/sh

/home/aaron/_scripts/speech/say.sh "Goodnight commander, sweet dreams";


/usr/bin/dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Suspend" boolean:true



