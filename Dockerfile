# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Garrys Mod
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM        ubuntu:14.04

MAINTAINER  Nerdism, <nerd@nerdism.net>
ENV         DEBIAN_FRONTEND noninteractive

RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y tar bzip2 curl gcc g++ lib32gcc1 lib32tinfo5 lib32z1 lib32stdc++6 libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 \
            && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
            && apt install -y nodejs \
            && useradd -m -d /home/container container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
COPY        ./http.js /http.js
COPY        ./wrapper.js /wrapper.js

CMD         ["/bin/bash", "/entrypoint.sh"]
