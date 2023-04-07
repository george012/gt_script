#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget net-tools logrotate apt-transport-https ca-certificates curl gnupg lsb-release
}

dislble_ufw(){
    systemctl disable ufw.service && systemctl stop ufw.service
}

optimize_network(){
    wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/optimize_network.sh && chmod a+x ./optimize_network.sh && ./optimize_network.sh
}

NEW_SSH_PORT=22
input_ssh_port(){
    while true; do
        echo "====Please Input SSH Port For New===="
        read -p "Please Input(请输入): " input_string
        if [[ -z "${input_string// }" ]]; then
            INPUT_DOMAIN="$input_string"
            break
        else
            echo "Invalid Domain"
        fi
    done
}

pre_config && wait && dislble_ufw && wait && optimize_network && wait && echo "Ubuntu 20.0.4 LTS Setup End" && wait && rm -rf $SCRIPT_NAME
