# target container
FROM mithrand0/reactive-drop-base-workshop

# disable cache from here
ARG build
ENV VERSION=$build
RUN echo "Packaging version: ${VERSION}" | boxes

# install needed utilities
RUN apt-get -y install vim less aptitude procps unzip software-properties-common libsdl2-2.0-0 libsdl2-2.0-0:i386

# get gpg key of wine repository
RUN wget -q -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

# install some dependencies not in bionic
RUN wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/amd64/libfaudio0_19.06-0~cosmic_amd64.deb \
    && dpkg -i libfaudio0*.deb \
    && rm -f libfaudio0*.deb

RUN wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Ubuntu_18.10_standard/i386/libfaudio0_19.06-0~cosmic_i386.deb \
    && dpkg -i libfaudio0*.deb \
    && rm -f libfaudio0*.deb

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

# metamod
RUN wget -q https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git970-windows.zip -O /tmp/metamod.zip \
    && cd /root/reactivedrop/reactivedrop \
    && unzip -x /tmp/metamod.zip \
    && rm -f /tmp/metamod.zip

# sourcemod
RUN wget -q https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6281-windows.zip -O /tmp/sourcemod.zip \
    && cd /root/reactivedrop/reactivedrop \
    && unzip -x /tmp/sourcemod.zip

# sourcebans
RUN wget -q https://github.com/sbpp/sourcebans-pp/releases/download/1.6.3/sourcebans-pp-1.6.3.plugin-only.zip -O /tmp/sourcebans.zip \
    && cd /tmp \
    && unzip -x /tmp/sourcebans.zip \
    && cp -a /tmp/sourcebans-pp-1.6.3.plugin-only/addons /root/reactivedrop/reactivedrop/

# remove nextmap.smx
RUN find /root/reactivedrop/reactivedrop -type f -name 'nextmap.smx' -delete

# winetricks
RUN cd /usr/local/bin \
    && wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks
RUN winetricks win7

# copy files
COPY etc/ /etc/
COPY bin/bootstrap.sh /usr/local/bin/bootstrap.sh
COPY bin/workshop-activate /usr/local/sbin/workshop-activate
COPY reactivedrop/ /root/reactivedrop/reactivedrop/

# install workshop content into game folder
RUN workshop-activate
