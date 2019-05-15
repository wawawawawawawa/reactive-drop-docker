#!/bin/bash

# wait for server to have started before doing this
sleep 120

# update
/usr/games/steamcmd +runscript /usr/local/templates/install.workshop
/usr/local/bin/link-workshop.sh

# only check once every 4 hours
sleep 14400