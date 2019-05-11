FROM solarkennedy/wine-x11-novnc-docker

# agree with license
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# install dependencies
RUN apt-get update
RUN apt-get -y install steamcmd
RUN apt-get -qq -y autoremove \
    && apt-get -qq -y clean \
    && apt-get -qq -y autoclean \
    && find /var/lib/apt/lists -type f -delete \
    && unset PACKAGES

# version tag
ENV VERSION=2019051100

# run steam self-update
RUN echo $VERSION > /opt/version

# install the game
RUN /usr/games/steamcmd \
    +@sSteamCmdForcePlatformType windows \
    +login anonymous \
    +app_update 563560 \
    +quit

# copy files
COPY /docker
