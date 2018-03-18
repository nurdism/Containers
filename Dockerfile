FROM ubuntu:16.04

MAINTAINER nerdism, http://github.com/nerdism
ENV        DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y lib32gcc1 lib32stdc++6 unzip curl xz-utils git

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]