#!/bin/bash

# vars
SLEEP_TIME=10

# run updates
/usr/games/steamcmd \
    +@sSteamCmdForcePlatformType windows \
    +login anonymous \
    +app_update 563560 \
    +quit

# get the ip address
ip=$(wget -q -O- "https://api.ipify.org/")
#ip="127.0.0.1"

# gui/console
export DISPLAY=:0
export WINEARCH="win32"
export WINEDEBUG="-all"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"
#export WINEDEBUG="+synchronous,+loaddll,+seh,+msgbox,+fixme"

# run a persistent wine server during initialization
/usr/bin/wineserver -k -p 60

# switch to reactive drop folder
cd /root/reactivedrop/

# set ifs
IFS=$'\n'

# get defined servers
servers=$(set | grep "^rd\_server\_[0-9]\{1,\}\_port=[0-9]\{4,5\}$")

# loop
while [[ true ]]; do

    # iterate
    for server in $servers; do

        # get server number
        nr=$(echo "${server}" | cut -d '_' -f 3)
        port=$(echo "${server}" | cut -d '=' -f 2-)

        # check if the server is running already
        running=$(pgrep -f "${port}")

        if [[ "$running" = "" ]]; then

            # write a configuration file for this server
            config="server_${nr}.cfg"
            console="console_${nr}.log"
            file="reactivedrop/cfg/${config}"

            # load the server.cfg file
            echo "exec server.cfg" > $file

            # look for other settings for this server
            for vars in $(set | grep "^rd\_server\_${nr}\_"); do
                var=$(echo "${vars}" | cut -d '_' -f 4- | cut -d '=' -f 1)
                value=$(echo "${vars}" | cut -d '=' -f 2- | sed "s/\\\\'/\#/g" | sed "s/'//g" | sed "s/#/'/g")

                # write the var the the server config file
                echo "${var} = ${value}" >> $file
            done

            # create a copy of the sourcemod folder
            cp -a reactivedrop/addons/sourcemod reactivedrop/addons/sourcemod_$i

            # check if the env does exist
            wine start \
                ./srcds.exe \
                -console \
                -game reactivedrop \
                -port $port \
                -threads 1 \
                -nomessagebox \
            	-nocrashdialog \
                -num_edicts 4096 \
                +con_logfile $console \
                +exec $config
                +sm_basepath addons/sourcemod_$i

            # wait a bit before attempting to start the next server
            sleep $SLEEP_TIME
         fi
    done

    sleep $SLEEP_TIME
done