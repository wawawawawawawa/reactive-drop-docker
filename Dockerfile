FROM solarkennedy/wine-x11-novnc-docker

# agree with license
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# install dependencies
RUN apt-get update
RUN apt-get -y install steamcmd

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

# link reactive drop for easier usage within scripts
RUN ln -s /root/.steam/SteamApps/common/Alien\ Swarm\ Reactive\ Drop /root/reactivedrop

# install winetricks
RUN apt-get -y install vim less aptitude
#RUN apt-get -y install winetricks
RUN apt-get -y install software-properties-common

# get gpg key
RUN wget -q -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

# go multiarch
RUN dpkg --add-architecture i386
RUN apt update

# upgrade wine
RUN apt -y remove wine32
RUN apt -y install libsdl2-2.0-0 libsdl2-2.0-0:i386
RUN wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/i386/libfaudio0_19.05-0~cosmic_i386.deb
RUN wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/amd64/libfaudio0_19.05-0~cosmic_amd64.deb
RUN dpkg -i libfaudio*.deb
RUN apt install -y --install-recommends winehq-stable:i386

# set to a specific directx mode
#RUN winetricks -q win7 corefonts

# cleanup
#RUN apt-get -qq -y autoremove \
#    && apt-get -qq -y clean \
#    && apt-get -qq -y autoclean \
#    && find /var/lib/apt/lists -type f -delete \
#    && unset PACKAGES

# copy files
COPY /docker /

