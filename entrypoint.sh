#!/bin/bash
sleep 2

cd /home/container

#Install/Update the Server
if [[ ! -f RustDedicated ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f steam.txt ]]; then
		./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

# Update/Install OxideMod
if [[ ${OXIDE} == "1" ]]; then
    echo "Updating/Installing OxideMod..."
    curl -sSL ${OXIDE_ZIP} > oxide.zip
    unzip -o -q oxide.zip
    rm oxide.zip
    echo "Done updating OxideMod!"
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Fix for Rust not starting
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"

#Error
if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi