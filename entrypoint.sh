#!/bin/bash
cd /home/container

sleep 1

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

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
