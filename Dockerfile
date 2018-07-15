# ----------------------------------
# Wine Dockerfile for Space engeneers
# Environment: ubuntu:14.04 + Wine
# Minimum Panel Version: 0.7.6
# ----------------------------------
FROM        ubuntu:14.04

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>

ENV         DEBIAN_FRONTEND noninteractive
ENV         HOME /home/container
ENV         WINEARCH win32
ENV         WINEPREFIX /home/container/.wine64

            # We want the 32 bits version of wine allowing winetricks.
RUN         dpkg --add-architecture i386 && \

            # Set the time zone.
            echo "America/New_York" > /etc/timezone && \
            dpkg-reconfigure -f noninteractive tzdata && \

            # Updating and upgrading a bit.
            apt update && \
            apt upgrade -y && \
            # We need software-properties-common to add ppas.
            apt-get install -y --no-install-recommends software-properties-common && \

            # Add the wine PPA.
            add-apt-repository ppa:ubuntu-wine/ppa && \
            apt-get update && \

            # Installation of win, winetricks and temporary xvfb to install winetricks tricks during docker build.
            apt-get install -y --no-install-recommends wine1.7 winetricks xvfb && \

            # Installation of winbind to stop ntlm error messages.
            apt-get install -y --no-install-recommends winbind && \

            # Installation of winetricks tricks as wine user.
            su -p -l root -c winecfg && \
            su -p -l root -c 'xvfb-run -a winetricks -q corefonts' && \
            su -p -l root -c 'xvfb-run -a winetricks -q dotnet20' && \
            su -p -l root -c 'xvfb-run -a winetricks -q dotnet40' && \
            su -p -l root -c 'xvfb-run -a winetricks -q xna40' && \
            su -p -l root -c 'xvfb-run -a winetricks d3dx9' && \
            su -p -l root -c 'xvfb-run -a winetricks -q directplay' && \

            # Installation of git, build tools and sigmap.
            apt-get install -y --no-install-recommends build-essential git-core && \
            git clone https://github.com/marjacob/sigmap.git && \
            (cd sigmap && exec make) && \
            install sigmap/bin/sigmap /usr/local/bin/sigmap && \
            rm -rf sigmap/ && \

            # Cleaning up.
            apt-get autoremove -y --purge build-essential git-core && \
            apt-get autoremove -y --purge software-properties-common && \
            apt-get autoremove -y --purge xvfb && \
            apt-get autoremove -y --purge && \
            apt-get clean -y && \
            rm -rf /home/root/.cache && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER        container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/usr/local/bin/sigmap", "-m 15:2", "/entrypoint.sh"]
