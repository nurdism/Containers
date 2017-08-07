# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Unity
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM        ubuntu:14.04

MAINTAINER  Nerdism, <nerd@nerdism.net>
ENV         DEBIAN_FRONTEND noninteractive

RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y lib32gcc1 lib32stdc++6 curl unzip mono-runtime libmono2.0-cil libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386 libc6-dev-i386 libgcc-4.8-dev:i386 \
            && useradd -m -d /home/container container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]