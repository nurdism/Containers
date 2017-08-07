#!/bin/bash
sleep 5

#Update the Server
if [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

export MONO_IOMAP=all

if [[ -f /home/container/preflight.sh ]]; then
	/home/container/preflight.sh
fi

cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container ${MODIFIED_STARTUP}"

if if [ ! -z "$ULIMIT" ]; then
	ulimit -n ${ULIMIT}
fi

# Run the Server
${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
