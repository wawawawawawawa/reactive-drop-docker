FROM solarkennedy/wine-x11-novnc-docker

# agree with license
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# go multiarch
RUN dpkg --add-architecture i386
RUN apt update

# use a volume mount for both steam game and steam locations
VOLUME /root/.steam/
VOLUME /root/Steam/

# install needed utilities
RUN apt-get -y install vim less aptitude procps unzip software-properties-common steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386

# get gpg key of wine repository
RUN wget -q -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

# install some dependencies not in bionic
RUN wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/amd64/libfaudio0_19.05-0~cosmic_amd64.deb \
    && dpkg -i libfaudio0_19.05-0~cosmic_amd64.deb \
    && rm -f libfaudio0_19.05-0~cosmic_amd64.deb

RUN wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/i386/libfaudio0_19.05-0~cosmic_i386.deb \
    && dpkg -i libfaudio0_19.05-0~cosmic_i386.deb \
    && rm -f libfaudio0_19.05-0~cosmic_i386.deb

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
RUN mkdir -p /root/template/reactivedrop/

# metamod
RUN wget -q https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git970-windows.zip -O /tmp/metamod.zip \
    && cd /root/template/reactivedrop \
    && unzip -x /tmp/metamod.zip \
    && rm -f /tmp/metamod.zip

# sourcemod
RUN wget -q https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6281-windows.zip -O /tmp/sourcemod.zip \
    && cd /root/template/reactivedrop \
    && unzip -x /tmp/sourcemod.zip

# sourcebans
RUN wget -q https://github.com/sbpp/sourcebans-pp/releases/download/1.6.3/sourcebans-pp-1.6.3.plugin-only.zip -O /tmp/sourcebans.zip \
    && cd /tmp \
    && unzip -x /tmp/sourcebans.zip \
    && cp -a /tmp/sourcebans-pp-1.6.3.plugin-only/addons /root/template/reactivedrop/

# copy files
COPY etc/ /etc/
COPY bin/ /usr/local/bin/
COPY templates /usr/local/templates
COPY reactivedrop/ /root/template/reactivedrop/
