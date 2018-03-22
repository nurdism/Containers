# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------

FROM        frolvlad/alpine-glibc

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>

RUN         apk update \
            && apk upgrade \
            && apk add --no-cache curl ca-certificates openssl libstdc++ git tar xz curl openssh \
            && apk add libc++ --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/ash", "/entrypoint.sh"]