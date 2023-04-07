#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget logrotate apt-transport-https ca-certificates curl gnupg lsb-release
}

dislble_ufw(){
    systemctl disable ufw.service && systemctl stop ufw.service
}

optimize_network(){
    wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/optimize_network.sh && chmod a+x ./optimize_network.sh && ./optimize_network.sh
}

pre_config && wait && optimize_network && wait && rm -rf $SCRIPT_NAME && wait && echo "redis is installed"
