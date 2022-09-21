#!/bin/bash


function shortcut_url {
    [ $(expr $1 : $2) -eq 1 ] && goto_web_url $3 || return ;
}

function goto_web_url {
    #nohup firefox -new-instance -P kiosk -url $1 &
    #disown
	chromium-browser --app="$1";
    exit;
}

function ask_twitch {
     read -p "Username: " a;
     #livestreamer --twitch-oauth-token bn556i6oj43gh1n8ka7xmt9lu5aib2 "https://twitch.tv/$a" 720p
     goto_web_url "https://twitch.tv/$a";
}

function handle_selection {
    
    shortcut_url $1 '1\|w' https://web.whatsapp.com
    shortcut_url $1 '2\|r' https://reddit.com/.compact
    shortcut_url $1 '3\|y' https://youtube.com
    [ $(expr $1 : '4\|t') -eq 1 ] && ask_twitch ;
    [[ $1 == http* ]] && goto_web_url $1 ;
    
    echo "URLs start with http";

}

echo "Shortcuts:"
echo "1- Whatsapp";
echo "2- Reddit";
echo "3- Youtube";
echo "4- Twitch";
read -p ":" addr


handle_selection $addr;

exit;










function ask_web_url {
    read -p "Web Address: " webaddr;
    goto_web_url $webaddr;
}


choices=("Choice")
select opt in "${choices[@]}"
do

    case $opt in
        "Choice")
            choice_function;
            ;;
        *) default_function ;;
    esac
done


