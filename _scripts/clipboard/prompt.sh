#! /bin/bash

clipboard_file="$HOME/.clipboard"

# result=$(cat "$clipboard_file" | dmenu -i -l 10)
result=$(cat "$clipboard_file" | rofi -dmenu -width 50 -columns 2 -padding 10 -seperator-style solid -hide-scrollbar -click-to-exit -p "clipboard" )


if [[ $result ]]; then 
	echo -n "$result"  |  xclip -selection clipboard;
    clipboard=$(grep -v "$result" $clipboard_file);
    echo "$result" > $clipboard_file;
    echo "$clipboard" >> $clipboard_file;
fi


