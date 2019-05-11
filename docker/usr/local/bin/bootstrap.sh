#!/bin/bash
set -ex

# vars
MAXPLAYERS=8
PORT="${1:-27015}"

# get the ip address
#IP=$(wget -q -O- "https://api.ipify.org/")
IP=$(ifconfig | grep inet  | grep -v 127.0.0.1 | head -n 1  | awk '{ print $2; }')
IP="127.0.0.1"

# gui/console
export DISPLAY=:0
export WINEARCH="win32"
export WINEDEBUG="-ALL"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"

# switch to reactive drop folder
cd /root/reactivedrop/

# start srcds
winedbg --command "quit" \
        ./srcds.exe \
        -game reactivedrop \
        -console \
        -ip $IP \
        -port $PORT \
        -maxplayers $MAXPLAYERS \
        -threads 1 \
        +exec server.cfg