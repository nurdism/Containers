#!/bin/bash
sleep 5

#FastDL Functions
fastdl_search() {

	SOUND="$1/sound"
	RESOURCE="$1/resource"
	PARTICLES="$1/particles"
	MODELS="$1/models"
	MATERIALS="$1/materials"
	MAPS="$1/maps"

	if [ ! -d "$2" ]; then
		mkdir "$2"
	fi

	if [[ -d "${SOUND}" ]]; then
		if [ ! -d "$2/sound" ]; then
			mkdir "$2/sound"
		fi
		fastdl_add "${SOUND}" "$2/sound"
	fi

	if [[ -d "${RESOURCE}" ]]; then
		if [ ! -d "$2/resource" ]; then
			mkdir "$2/resource"
		fi
		fastdl_add "${RESOURCE}" "$2/resource"
	fi

	if [[ -d "${PARTICLES}" ]]; then
		if [ ! -d "$2/particles" ]; then
			mkdir "$2/particles"
		fi
		fastdl_add "${PARTICLES}" "$2/particles"
	fi

	if [[ -d "${MODELS}" ]]; then
		if [ ! -d "$2/models" ]; then
			mkdir "$2/models"
		fi
		fastdl_add "${MODELS}" "$2/models"
	fi

	if [[ -d "$MATERIALS" ]]; then
		if [ ! -d "$2/materials" ]; then
			mkdir "$2/materials"
		fi
		fastdl_add "$MATERIALS" "$2/materials"
	fi

	if [[ -d "$MAPS" ]]; then
		if [ ! -d "$2/maps" ]; then
			mkdir "$2/maps"
		fi
		fastdl_add "$MAPS" "$2/maps"
	fi

}

fastdl_add() {

    echo "Checking for content in: ${1}"

	for FOLDER in $1/*; do
		find "${FOLDER}" -type f | while read FILE; do
			MOVEF=$(echo $FILE | sed "s|$1|$2|g")
			MOVED=$(dirname "${MOVEF}")
			if [ ! -d "${MOVED}" ]; then
				mkdir -p "${MOVED}"
			fi
			BZ2="${MOVEF}.bz2"
			if [[ ! -f $BZ2 ]]; then
				echo "Adding: ${FILE} -> ${MOVEF}"
				cp "${FILE}" "${MOVEF}"
			fi
		done
    done
}

#Install the Server
if [[ ! -f /home/container/srcds_run ]] || [[ ${UPDATE} == "1" ]]; then
	if [[ -f /home/container/steam.txt ]]; then
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +runscript /home/container/steam.txt
	else
		/home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} validate +quit
	fi
fi

#steamclient.so fix
if [[ ! -L /home/container/.steam/sdk32/steamclient.so ]]; then
	mkdir -p /home/container/.steam/sdk32
	cd /home/container/.steam/sdk32
	ln -s ../../steamcmd/linux32/steamclient.so steamclient.so
fi

# Adding Fastdl Support
if [[ ${FASTDL} == "1" ]]; then
    MAPS="/home/container/garrysmod/maps"
    ADDONS="/home/container/garrysmod/addons"
    GAMEMODES="/home/container/garrysmod/gamemodes"
    FASTDL="/home/container/fastdl"

    echo "Setting up Fast DL content! ( Can take a few minutes to complete! )"

    fastdl_add "$MAPS" "$FASTDL/maps"

    find "${ADDONS}" -maxdepth 1 -type d| while read FOLDER; do
        if [[ $ADDONS != $FOLDER ]]; then
            fastdl_search "$FOLDER" "$FASTDL"
        fi
    done

    find "${GAMEMODES}" -maxdepth 1 -type d| while read FOLDER; do
        if [[ $GAMEMODES != $FOLDER ]]; then
            fastdl_search "$FOLDER/content" "$FASTDL"
        fi
    done

    find "${FASTDL}" -type f \( ! -iname "*.bz2" \) | while read FILE_NAME; do
        BZ2="${FILE_NAME}.bz2"
        if [[ ! -f "${BZ2}" ]]; then
            echo "Archiving: ${FILE_NAME}"
            bzip2 "${FILE_NAME}"
        fi
    done
fi

cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

#Check port allocation
if  [ ${FASTDL} != "1" ] && [ -z "${ALLOC_0__PORT}" ] && [ "${ALLOC_0__PORT}" != "${FASTDL_PORT}" ]; then
    echo "---=== Please add fastdl port to the server as an additional allocation, or you will be unable to use fastdl. ===---"
    sleep 10
    exit 1
fi

node /wrapper.js ${FASTDL_PORT} ${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi
