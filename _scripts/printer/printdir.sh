#!/bin/bash


inputdir=${1};

out=${2};


echo $dir;


files=$(ls -1v $inputdir/*);


function printtext () {
    echo $1 > /dev/usb/$out;
}

function newline () {
    printtext "";
}

function hr () {
    #printtext "=============================";
    #printtext "+++++++++++++++++++++++++++++";
    #printtext "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";
    #printtext "////////////////////////////////";
    printtext "################################";
}



function seperate () {
    newline;
    hr;
    newline;
}

for file in $files; do
    text=$(cat $file);
    
    if [ "${#text}" -gt 1 ]; then
        #seperate;
        printtext $file;
        printtext "$text";
        #seperate;
        #newline;
    else
        echo "empty file"
    fi
    

done;

