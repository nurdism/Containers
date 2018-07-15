# ----------------------------------
# Wine Dockerfile for Steam Servers
# Environment: ubuntu:18.04 + Wine
# Minimum Panel Version: 0.7.6
# ----------------------------------
FROM        ubuntu:18.04

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>

# Install Dependencies
RUN         dpkg --add-architecture i386 && \
            apt update && \
            apt upgrade -y && \
            apt install -y software-properties-common && \
            apt update && \

            apt install -y --install-recommends wine64 winetricks xvfb lib32gcc1 libntlm0 wget winbind && \

            su -p -l root -c winecfg && \
            su -p -l root -c 'xvfb-run -a winetricks -q corefonts' && \
            su -p -l root -c 'xvfb-run -a winetricks -q dotnet20' && \
            su -p -l root -c 'xvfb-run -a winetricks -q dotnet40' && \
            su -p -l root -c 'xvfb-run -a winetricks -q xna40' && \
            su -p -l root -c 'xvfb-run -a winetricks d3dx9' && \
            su -p -l root -c 'xvfb-run -a winetricks -q directplay' && \

            apt-get autoremove -y --purge software-properties-common && \
            apt-get autoremove -y --purge xvfb && \
            apt-get autoremove -y --purge && \
            apt-get clean -y && \

            useradd -d /home/container -m container && \
            cd /home/container

USER        container

ENV         HOME /home/container
ENV         WINEARCH win64
ENV         WINEPREFIX /home/container/.wine64
ENV         WINEDEBUG -all

WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]