#!/bin/bash
sleep 5

if [[ ! -f /home/container/7DaysToDie.x86 ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

cd /home/container

# Replace startup variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container ${MODIFIED_STARTUP}"

# Mono tweaks
export MONO_IOMAP=all
if [ ! -z "$ULIMIT" ]; then
	ulimit -n ${ULIMIT}
fi

# Run the Server
node /wrapper.js ${MODIFIED_STARTUP}

#Error
if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
