#!/bin/bash
sleep 2

cd /home/container

# Clone server data
git clone https://github.com/citizenfx/cfx-server-data.git server-data

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}