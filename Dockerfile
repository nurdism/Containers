# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Unity
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM        ubuntu:16.04

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>
ENV         DEBIAN_FRONTEND noninteractive
# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y tar curl unzip gcc g++ lib32gcc1 lib32tinfo5 lib32z1 libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 \
                                  lib32stdc++6 \
                                  mono-runtime mono-reference-assemblies-2.0 \
                                  libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386 \
                                  libc6-dev-i386 libgcc-4.8-dev:i386 \
            && useradd -m -d /home/container container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]