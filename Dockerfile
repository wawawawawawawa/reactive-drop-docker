# target container
FROM mithrand0/reactive-drop-base-game

# disable cache from here
ARG build
ENV VERSION=$build
RUN echo "Packaging version: ${VERSION}" | boxes

# refresh package lists
RUN apt update

# install needed utilities
RUN apt-get -y install vim less aptitude procps unzip software-properties-common libsdl2-2.0-0 libsdl2-2.0-0:i386

# install a web server for translation services
RUN apt-get -y install nginx-light php-fpm php-memcache memcached

# get gpg key of wine repository
RUN wget -q -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

# install some dependencies not in bionic
COPY external/ /tmp/external/
RUN dpkg -i /tmp/external/*.deb && rm -rf /tmp/external

# remove previous wine prefix, it contains outdated certificates
RUN rm -rf /root/prefix32

# upgrade wine
RUN apt install -y --install-recommends winehq-staging:i386


# cleanup, enable after we are finished
RUN apt-get -qq -y autoremove \
    && apt-get -qq -y clean \
    && apt-get -qq -y autoclean \
    && find /var/lib/apt/lists -type f -delete \
    && unset PACKAGES \
    && rm -f /tmp/*.zip

# link reactive drop for easier usage within scripts
RUN ln -sf /root/.steam/SteamApps/common/reactivedrop /root/reactivedrop

# sourcemod
COPY bin/install-sourcemod /usr/local/sbin/install-sourcemod
RUN /usr/local/sbin/install-sourcemod

# winetricks
RUN cd /usr/local/bin \
    && wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks

# copy files
COPY etc/ /etc/
COPY bin/bootstrap.sh /usr/local/bin/bootstrap.sh
COPY reactivedrop/ /root/reactivedrop/reactivedrop/
COPY www/index.php /var/www/html/index.php

# cache steam client installation
VOLUME /root/prefix32/drive_c

# cache workshop folder
VOLUME /root/.steam/SteamApps/common/reactivedrop/reactivedrop/workshop

# start command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
