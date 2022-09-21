#!/bin/zsh

CMC=$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=300")


totalsum=0;

function cmcget () {
    local a b c e f;
    b='.[] | select(.name == "';
    c='") .price_usd';
    f='") .rank';
    a=$b$1$c;
    c=$(echo $CMC | jq -r "$a");
    #d=$(echo $CMC | jq -r "$b$1$f");
    holding=$(($2*$c));
    
    printf "%-24s" "$1";
    printf "%-24s" "$c";
    #printf "%-24s\n" "$d";
    printf '%.0f\n' $holding;
    
    totalsum=$(($totalsum+$holding));


}

cmcget "Bitcoin" 1;


#echo "--------------------------------";

totalsum=$(printf '%.0f' $totalsum);
gbpsum=$(printf '%.0f' $(($totalsum*0.75)));

    printf "%-24s" "Total";
    printf "%-24s" "\$$totalsum";
    printf "%-24s\n" "£$gbpsum";


#curl -s https://api.coinmarketcap.com/v1/ticker/ | jq -r '.[] | select(.name == "Bitcoin") .price_usd'

