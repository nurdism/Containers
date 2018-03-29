# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Mono
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM alpine:edge

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>

RUN         echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
            && apk add --update mono@testing mono-dev@testing \
            && apk add --no-cache openssl curl sqlite mono@testing mono-dev@testing \
            && adduser -D -h /home/container container

USER        container
ENV         HOME=/home/container USER=container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/ash", "/entrypoint.sh"]
