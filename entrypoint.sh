#!/bin/bash
sleep 5

# steamclient.so fix
if [[ ! -f /home/container/.steam/sdk32/steamclient.so ]]; then
	mkdir -p /home/container/.steam/sdk32
	cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so
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
