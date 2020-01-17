# target container
FROM mithrand0/reactive-drop-base-server

# disable cache from here
ARG build
ENV VERSION=$build
RUN echo "Packaging version: ${VERSION}" | boxes

# sm translator
COPY reactivedrop/addons/ /root/reactivedrop/reactivedrop/addons/
COPY bin/compile-sourcemod /usr/local/sbin/compile-sourcemod
RUN /usr/local/sbin/compile-sourcemod

# install anti cheat layer
COPY --from=mithrand0/reactive-drop-anticheat:latest /root/reactivedrop/reactivedrop/ /root/reactivedrop/reactivedrop/

# copy files
COPY etc/ /etc/
COPY bin/bootstrap.sh /usr/local/bin/bootstrap.sh
COPY reactivedrop/bin/ /root/reactivedrop/reactivedrop/bin/
COPY reactivedrop/cfg/ /root/reactivedrop/reactivedrop/cfg/
COPY reactivedrop/addons/sourcemod/configs/ /root/reactivedrop/reactivedrop/addons/sourcemod/configs/
COPY www/index.php /var/www/html/index.php

# cache steam client installation
VOLUME /root/prefix32/drive_c

# cache workshop folder
VOLUME /root/.steam/SteamApps/common/reactivedrop/reactivedrop/workshop

# work dir
WORKDIR /root/reactivedrop/reactivedrop

# start command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
