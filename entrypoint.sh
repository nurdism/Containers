#!/bin/bash
sleep 2

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Source Server
if [ ${FORCE_UPDATE} == "true" ]; then
	if [ ! -z ${SRCDS_APPID} ]; then
		if [ ! -z ${SRCDS_BETAID} ]; then
			if [ ! -z ${SRCDS_BETAPASS} ]; then
				./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} -betapassword ${SRCDS_BETAPASS} validate +quit
			else
				./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} validate +quit
			fi
		else
			if [ -f ./steam.txt ]; then
				./steamcmd/steamcmd.sh +runscript /home/container/steam.txt
			else
				./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${SRCDS_APPID} validate +quit
			fi
		fi    
	fi
fi

if [[ -f /home/container/preflight.sh ]]; then
	/home/container/preflight.sh
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "~/server: ${MODIFIED_STARTUP}"

cd /home/container

# $NSS_WRAPPER_PASSWD and $NSS_WRAPPER_GROUP have been set by the Dockerfile
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}
export LD_PRELOAD=/libnss_wrapper.so

# Run the Server
${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
