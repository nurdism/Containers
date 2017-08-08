#!/bin/bash
sleep 5

#Install the Server
if [[ ! -f /home/container/srcds_run ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

if [[ ! -L /home/container/.steam/sdk32/steamclient.so ]]; then
	mkdir -p /home/container/.steam/sdk32
	cd /home/container/.steam/sdk32
	ln -s ../../steamcmd/linux32/steamclient.so steamclient.so
fi

if [[ -f /home/container/preflight.sh ]]; then
	/home/container/preflight.sh
fi

cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

#Check port allocation
if [ -z "${ALLOC_0__PORT}" ] || [ "${ALLOC_0__PORT}" != "${FDL_PORT}" ]; then
    echo "---=== Please add fastdl port to the server as an additional allocation, or you will be unable to use fastdl. ===---"
    sleep 10
    exit 1
fi

node ./wrapper.js ${FDL_PORT} ${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
