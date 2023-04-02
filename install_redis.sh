#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget logrotate apt-transport-https ca-certificates curl gnupg lsb-release
}

install_redis(){
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
    && wait \
    && echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list \
    && wait \
    && sudo apt update \
    && wait \
    && sudo apt-get -y install redis
}

pre_config && wait && install_redis && wait && rm -rf $SCRIPT_NAME && wait && echo "redis is installed"
