#!/bin/bash

SLEEP_TIME=15

running="-1"
while [[ "$running" != "" ]]; do
    # wait a bit
    sleep $SLEEP_TIME

    # check if steamcmd is already running
    running=$(pidof steamcmd)
done

# if not running, start workshop download
echo '******************************************************************************'
echo ' * Downloading workshop content. Take another coffee, this might take time.. *'
echo '******************************************************************************'
/usr/games/steamcmd +runscript /usr/local/templates/install.workshop

# write new workshop.cfg file based on the steamcmd version we just run
# reactive drop will pick it up after the next map change then
/usr/local/bin/workshop-config.sh

# do this only once every 6 hours
echo "Next workshop update check will be in 6 hours.."
sleep 21600