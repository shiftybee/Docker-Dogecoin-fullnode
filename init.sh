#!/bin/bash

##Update packages
apt update && apt upgrade -y
##Check if binaries are already installed
if [ ! -f ~/litecoin-bin/bin/litecoind ]; then
    cd ~
    ##Check if the archive exists
    if [ ! -d ~/litecoin-0.14.2 ]; then
        echo Binaries not found. Installing necessary packages
        apt install -y wget curl ca-certificates
        echo Downloading binaries
        wget https://download.litecoin.org/litecoin-0.14.2/linux/litecoin-0.14.2-x86_64-linux-gnu.tar.gz -O litecoin.tar.gz
        ##Extract archives
        echo Extracting litecoind
        tar -xvf litecoin.tar.gz
        rm litecoin.tar.gz
    fi
    ##Rename folder appropriately
    mv litecoin-0.14.2 litecoin-bin
    ##Add litecoind commands to PATH
    echo 'export PATH=$PATH:~/litecoin-bin/bin/' > ~/.bashrc
    source ~/.bashrc 
fi

##Check if configuration file exists
if [ ! -f ~/.litecoin/litecoin.conf ]; then
        mkdir ~/.litecoin
        echo rpcuser=litecoinrpc > ~/.litecoin/litecoin.conf
        PWord=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`
        echo rpcpassword=$PWord >> ~/.litecoin/litecoin.conf
fi
##Remove debug.log weekly. It gets pretty big over time
find ~/.litecoin/debug.log -mtime +7 -type f -delete
##Start litecoind daemon
echo Running litecoind in the background
~/litecoin-bin/bin/litecoind -daemon
echo Run \" tail -f ~/.litecoin/debug.log \" to watch the download status.
sleep 10
##Download status is now visible when running docker logs CONTAINER
tail -f ~/.litecoin/debug.log