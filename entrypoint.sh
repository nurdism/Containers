#!/bin/bash
sleep 5

cd /home/container

#Install the Server
if [[ ! -f /home/container/srcds_run ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
