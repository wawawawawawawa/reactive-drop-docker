#!/bin/bash
echo "Writing new workshop configuration file.."
grep 'workshop_download_item' /usr/local/templates/install.workshop \
    | sed 's/workshop_download_item 563560/rd_enable_workshop_item/g' \
    > /root/reactivedrop/reactivedrop/cfg/workshop.cfg

# do this only once every 6 hours
echo "All done, if there are workshop updates, they will be loaded after the next map change."
