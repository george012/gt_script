#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget logrotate apt-transport-https ca-certificates curl gnupg lsb-release
}

config_docker_install(){
    sudo mkdir -m 0755 -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

install_docker(){
    sudo apt update \
    && wait \
    && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
    && wait \
    && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}


install(){
    pre_config && wait && config_docker_install && wait && install_docker && wait && sudo systemctl enable --now docker
}

install && wait && echo "docker is installed" && wait && rm -rf $SCRIPT_NAME
