# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Mono
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM mono:latest

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>

ENV         DEBIAN_FRONTEND noninteractive

RUN         apt update && \
            apt upgrade -y && \
            useradd -d /home/container -m container

USER        container
ENV         HOME=/home/container USER=container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
