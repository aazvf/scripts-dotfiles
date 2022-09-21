#! /bin/bash

result=$(cat /home/aaron/NOTES | dmenu -i -l 10)


if [[ $result ]]; then 
	echo "$result" |  xclip -selection clipboard
fi




