#! /bin/bash

clipboard_file="$HOME/.clipboard"

contents=$(xclip -o -selection clipboard)

echo "$contents" >> $clipboard_file

