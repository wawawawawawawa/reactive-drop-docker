#!/bin/bash

# vars
SLEEP_TIME=60

# check if other processes are running
running="-1"

while [[ "$running" != "" ]]; do
    # wait for servers to be started
    sleep $SLEEP_TIME

    # detect if steamcmd is already running
    running=$(pidof steamcmd)

    if [[ "$running" != "" ]]; then
        echo "Steam game installation is still running, waiting.."
    fi
done

# update
echo ''
echo '******************************************************************************'
echo ' * Downloading workshop contents in background..                             *'
echo '******************************************************************************'
/usr/games/steamcmd +runscript /usr/local/templates/install.workshop
/usr/local/bin/link-workshop.sh

# only check once every 4 hours
sleep 14400