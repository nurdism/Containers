#!/bin/ash

sleep 1

echo "Setting up CitizenFX Server"

cd /home/container

if [[ ! -d .git ]]; then
    echo "Downloading CitizenFX server data"
    git init
    git remote add origin https://github.com/citizenfx/cfx-server-data.git
    git fetch origin master
    git checkout -t origin/master
else
    if [[ ${UPDATE} == "1" ]]; then
        echo "Updating CitizenFX server data"
        git fetch origin master
        git reset --hard FETCH_HEAD
    fi
fi

if [[ ! -d cfx-server ]] || [[ ${UPDATE} == "1" ]]; then
    echo "Downloading CitizenFX server"
    SEARCH="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
    LATEST=$(curl $SEARCH | grep '<a href' | tail -1 | awk -F[\>\<] '{print $3}')
    wget ${SEARCH}${LATEST}fx.tar.xz -O fx.tar.xz
    tar xf fx.tar.xz alpine/opt/
    mv -f alpine/opt/cfx-server/ ./
    chmod +x ./cfx-server/FXServer
    rm -rf fx.tar.xz alpine/
fi

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
