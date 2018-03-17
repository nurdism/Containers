#!/bin/bash
sleep 2

cd /home/container

# Download FiveM Server Files
wget https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/507-1006eacd1951849fd9c9e25a3b813132389d794b/fx.tar.xz
tar xf fx.tar.xz
rm fx.tar.xz

# Clone server data
git clone https://github.com/citizenfx/cfx-server-data.git server-data

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "${MODIFIED_STARTUP}"

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Run the Server
${MODIFIED_STARTUP}