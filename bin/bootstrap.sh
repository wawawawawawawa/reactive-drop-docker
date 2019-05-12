#!/bin/bash
set

# get the ip address
ip=$(wget -q -O- "https://api.ipify.org/")
#ip="127.0.0.1"

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
            file="/root/reactivedrop/reactivedrop/cfg/${config}"

            echo "exec server.cfg" > $file

            # look for other settings for this server
            for vars in $(set | grep "^rd\_server\_${nr}\_"); do
                var=$(echo "${vars}" | cut -d '_' -f 4- | cut -d '=' -f 1)
                value=$(echo "${vars}" | cut -d '=' -f 2- | sed "s/\\\\'/\#/g" | sed "s/'//g" | sed "s/#/'/g")

                echo "${var} = ${value}" >> $file
            done

            # check if the env does exist
            wine start \
                ./srcds.exe \
                -console \
                -game reactivedrop \
                -ip $ip \
                -port $port \
                -threads 1 \
                +exec $config

         fi
    done

    sleep 10
done