FROM ubuntu:16.04

MAINTAINER Isaac A., <isaac@isaacs.site>

RUN apt update && \
    apt upgrade -y && \
    apt install -y lib32gcc1 lib32stdc++6 unzip curl mono-runtime libmono2.0-cil libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386 libc6-dev-i386 libgcc-4.8-dev:i386 && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt install -y nodejs && \
    mkdir /node_modules && \
    npm install --prefix / ws && \
    useradd -d /home/container -m container

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
COPY ./utility.js /utility.js
COPY ./wrapper.js /wrapper.js

CMD ["/bin/bash", "/entrypoint.sh"]
