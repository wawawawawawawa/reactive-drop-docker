#!/bin/bash

# vars
SLEEP_TIME=2

# wait for initialization
sleep $SLEEP_TIME

# line
echo '******************************************************************************'
echo '* Starting Reactive Drop server                                              *'
echo '******************************************************************************'

# run steam self update
/usr/games/steamcmd +runscript /usr/local/templates/steam.selfupdate

# run updates
echo '******************************************************************************'
echo ' * Downloading game and updates. Take a coffee, this may take some time..    *'
echo '******************************************************************************'
/usr/games/steamcmd +runscript /usr/local/templates/install.server

# copy over template
cp -a /root/template/* /root/reactivedrop/

# get the ip address
#ip=$(wget -q -O- "https://api.ipify.org/")

# bind to the internal container id
ip=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -d ' ' -f 2 | head -n 1)

# gui/console
export DISPLAY=:0
export WINEARCH="win32"
export WINEDEBUG="-all"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"
#export WINEDEBUG="+synchronous,+loaddll,+seh,+msgbox,+fixme"

function write_server_config()
{
    file=$1

    # load the server.cfg file
    echo "exec server.cfg" > $file

    # look for other settings for this server
    for vars in $(set | grep "^rd\_server\_${nr}\_"); do
        var=$(echo "${vars}" | cut -d '_' -f 4- | cut -d '=' -f 1)
        value=$(echo "${vars}" | cut -d '=' -f 2- | sed "s/\\\\'/\#/g" | sed "s/'//g" | sed "s/#/'/g")

        # write the var the the server config file
        echo "${var} ${value}" >> $file
    done
}

function write_sourcemod_admins_simple()
{
    file="reactivedrop/addons/sourcemod/configs/admins_simple.ini"

    if [[ "$sourcemod_admin_steamid" != "" ]]; then
        echo "\"$sourcemod_admin_steamid\" \"z\"" > $file
        echo "" > $file
    fi

}

function write_sourcemod_sourcebans_config()
{
    file="reactivedrop/addons/sourcemod/configs/databases.cfg"

    if [[ "${sourcebans_host}" != "" ]]; then
        sed -i'' "s/#sourcebans_host#/${sourcebans_host}/g" $file
        sed -i'' "s/#sourcebans_port#/${sourcebans_port}/g" $file
        sed -i'' "s/#sourcebans_user#/${sourcebans_user}/g" $file
        sed -i'' "s/#sourcebans_password#/${sourcebans_password}/g" $file
        sed -i'' "s/#sourcebans_database#/${sourcebans_database}/g" $file
    fi
}

function write_sourcebans_serverid()
{
    file=$1
    nr=$2

    id=$(set | grep "rd_sourcebans_${nr}_id")
    if [[ "$id" != "" ]]; then
        sed -i'' "s/\-1/${nr}/g" $file
    fi
}

# run a persistent wine server during initialization
/usr/bin/wineserver -k -p 60

# set ifs
IFS=$'\n'

# link workshop content
/usr/local/bin/link-workshop.sh

# remove nextmap if present
find /root/ -type f -name 'nextmap.smx' -delete
find /root/reactivedrop/reactivedrop/save -type f -name '*.campaignsave' -delete
find /root/reactivedrop/reactivedrop -type f -name '*.log' -delete

# get defined servers
servers=$(set | grep "^rd\_server\_[0-9]\{1,\}\_port=[0-9]\{4,5\}$")

# switch to reactive drop folder
cd /root/reactivedrop/

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

            # write some configs
            write_server_config "${file}"
            write_sourcemod_admins_simple
            write_sourcemod_sourcebans_config

            # create a copy of the sourcemod folder
            smbase="addons/sourcemod_${nr}"
            cp -a reactivedrop/addons/sourcemod reactivedrop/$smbase

            # sourcebans
            write_sourcebans_serverid "reactivedrop/${smbase}/configs/sourcebans/sourcebans.cfg" $nr

            # check if the env does exist
            echo "Starting server #${nr}"

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
                +exec $config \
                +sm_basepath $smbase \
                +ip "${ip}" ${srcds_params}

            # wait a bit before attempting to start the next server
            sleep $SLEEP_TIME
         fi
    done

    sleep $SLEEP_TIME
done
