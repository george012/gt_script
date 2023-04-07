#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

pre_config(){
    sudo apt update && wait && sudo apt install -y curl gnupg2 ca-certificates lsb-release
}

install_nginx(){
    curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl enable nginx
}

pre_config && wait && install_nginx && wait && echo "Nginx install Complated" && wait && rm -rf $SCRIPT_NAME