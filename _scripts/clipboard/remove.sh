#! /bin/bash

clipboard_file="$HOME/.clipboard"

result=$(cat "$clipboard_file" | rofi -dmenu -width 90 -columns 2 -padding 10 -seperator-style solid -hide-scrollbar -click-to-exit -p "purge clipboard" )


if [[ $result ]]; then 
    clipboard=$(grep -v "$result" $clipboard_file);
    echo "$clipboard" > $clipboard_file;
fi




