#!/bin/bash
sleep 5

if [ -z "${ALLOC_0__PORT}" ] || [ "$((ALLOC_0__PORT-1))" != "${SERVER_PORT}" ]; then
    echo "---=== Please add port $((SERVER_PORT+1)) to the server as an additional allocation, or you will be unable to connect. ===---"
    sleep 10
    exit 1
fi

#Update the Server
if  [[ ! -f /home/container/RocketLauncher.exe ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi

	curl -sSL -o rocket.zip https://ci.rocketmod.net/job/Rocket.Unturned%20Linux/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip
    unzip -o -q rocket.zip
    rm rocket.zip
fi

if [[ ! -f /home/container/.steam/sdk32/steamclient.so ]]; then
	mkdir -p /home/container/.steam/sdk32
	cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so
fi

cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container ${MODIFIED_STARTUP}"

export MONO_IOMAP=all

if [ ! -z "$ULIMIT" ]; then
	ulimit -n ${ULIMIT}
fi

# Run the Server
${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
