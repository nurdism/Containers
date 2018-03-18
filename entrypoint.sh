#!/bin/bash
sleep 2

cd /home/container

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Clone server data
if [[ ! -d server-data ]]; then
	git clone https://github.com/citizenfx/cfx-server-data.git server-data
    echo "Init data"
else
    if [[ ${UPDATE} == "1" ]]; then
        echo "Updating data"
        git fetch origin master
        git reset --hard FETCH_HEAD
        chown -R ${USER_ID}:${USER_ID} /srv/daemon-data/lps_f91ffd0f/data/garrysmod/addons
        echo "Done Updating"
    fi
fi

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}