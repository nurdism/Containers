#!/bin/bash
sleep 5

#Check port allocation
if [ -z "${ALLOC_0__PORT}" ] || [ "$((ALLOC_0__PORT-1))" != "${SERVER_PORT}" ]; then
    echo "---=== Please add port $((SERVER_PORT+1)) to the server as an additional allocation, or you will be unable to connect. ===---"
    sleep 10
    exit 1
fi

#Update the server
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

# steamclient.so fix
if [[ ! -f /home/container/.steam/sdk32/steamclient.so ]]; then
	mkdir -p /home/container/.steam/sdk32
	cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so
fi

# steamclient.so fix
if [[ ! -L /home/container/Unturned_Data/Plugins/x86/steamclient.so ]]; then
    cd /home/container/Unturned_Data/Plugins/x86/
    rm -f steamclient.so
    ln -s ../../../steamcmd/linux32/steamclient.so steamclient.so
fi

# steamclient.so fix
if [[ ! -L /home/container/Unturned_Headless_Data/Plugins/x86/steamclient.so ]]; then
    cd /home/container/Unturned_Headless_Data/Plugins/x86/
    rm -f steamclient.so
    ln -s ../../../steamcmd/linux32/steamclient.so steamclient.so
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
