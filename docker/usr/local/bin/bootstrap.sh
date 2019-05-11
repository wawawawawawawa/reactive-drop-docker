#!/bin/bash
set

# vars
MAXPLAYERS=8
PORT="${1:-27015}"

# get the ip address
#IP=$(wget -q -O- "https://api.ipify.org/")
IP=$(ifconfig | grep inet  | grep -v 127.0.0.1 | head -n 1  | awk '{ print $2; }')
#IP="127.0.0.1"

# gui/console
export DISPLAY=:0
export WINEARCH="win32"
#export WINEDEBUG="+synchronous,+loaddll,+seh,+msgbox,+fixme"
export WINEDEBUG="-all"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"

# run a persistent wine server during initialization
/usr/bin/wineserver -k -p 60

# switch to reactive drop folder
cd /root/reactivedrop/

# start srcds
#winedbg --command "quit" \
wine start \
        ./srcds.exe \
        -console \
        -game reactivedrop \
        +ip $IP \
        -port $PORT \
        -maxplayers $MAXPLAYERS \
        -threads 1 \
        +exec server.cfg

running="-1"
while [[ "$running" != "" ]]; do
    sleep 5
    running=$(pidof wineserver)
done