#!/bin/ash

sleep 1

echo "Setting up CitizenFX Server"

if [[ ! -d cfx-server-data ]]; then
    echo "Downloading CitizenFX server data"
    cd /home/container
    git clone https://github.com/citizenfx/cfx-server-data.git cfx-server-data
else
    if [[ ${UPDATE} == "1" ]]; then
        echo "Updating CitizenFX server data"
        cd /home/container/cfx-server-data
        git fetch origin master
        git reset --hard FETCH_HEAD
    fi
fi

if [[ ! -d cfx-server ]] || [[ ${UPDATE} == "1" ]]; then
    echo "Downloading CitizenFX server"
    cd /home/container
    wget https://m-84g4dtu6fd76.runkit.sh/?q=linux -O fx.tar.xz
    tar xf fx.tar.xz alpine/opt/
    mv -f alpine/opt/cfx-server/ ./
    chmod +x ./cfx-server/FXServer
    rm -rf fx.tar.xz alpine/
fi

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
