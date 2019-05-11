#!/bin/bash
set -ex

# vars
MAXPLAYERS=8
PORT="${1:-27015}"

# get the exernal ip address
IP=$(wget -q -O- "https://api.ipify.org/")

# gui/console
export DISPLAY=":1"
export WINEARCH=win32

# switch to reactive drop folder
cd /root/reactivedrop

# start srcds
wine ./srcds.exe \
	-console \
	-game reactivedrop \
	+sv_lan 0 \
	+map lobby \
	-ip $IP \
	-port $PORT \
	-nomessagebox \
	-maxplayers $MAXPLAYERS \
	-nocrashdialog \
	-num_edicts 4096 \
	-threads 1