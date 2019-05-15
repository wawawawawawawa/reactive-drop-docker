#!/bin/bash

workshopdir="/root/.steam/SteamApps/workshop/content/563560"
addonfolder="/root/reactivedrop/reactivedrop/addons"

cd $workshopdir
for addon in $(find . -type f -name 'addon.vpk'); do

    ident=$(basename $(dirname "${addon}"))
    source="${workshopdir}/${addon}"
    target="${addonfolder}/${ident}.vpk"

    echo "linking ${source} > ${target}"
    ln -sf $source $target
done
