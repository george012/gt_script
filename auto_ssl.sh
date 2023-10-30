#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

INPUT_DOMAIN=""
INPUT_EMAIL=""
AUTO_REFRESH_TIME="10:10:10"
ACME_HOME="$HOME/.acme.sh"
NGINX_WEB_ROOT=/nginx_web
FULLCHAIN_NAME=fullchain.cer
PRIVATE_NAME=private.key


pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget curl gnupg lsb-release
}

nginx_is_runing(){
    if pgrep nginx >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

is_valid_domain() {
    local domain="$1"
    if [[ $domain =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

is_valid_email() {
    local email="$1"
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

input_domain(){
    while true; do
        echo "====Please Input Domain===="
        read -p "Please Input(请输入): " input_string
        
        if is_valid_domain "$input_string"; then
            INPUT_DOMAIN="$input_string"
            break
        else
            echo "Invalid Domain"
        fi
    done
}

input_email(){
    while true; do
        echo "====Please Input Email===="
        read -p "Please Input(请输入): " input_string
        if is_valid_email "$input_string"; then
            INPUT_EMAIL="$input_string"
            break
        else
            echo "Invalid Email"
        fi
    done
}

create_nginx_vhost(){
cat << EOF | sudo tee /etc/nginx/conf.d/$INPUT_DOMAIN.conf
server {
    listen 80;
    server_name $INPUT_DOMAIN;
    root $NGINX_WEB_ROOT/$INPUT_DOMAIN/web_root;
    index index.php index.html index.htm;
    error_page 400 401 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 500 501 502 503 504 =200 /404.html;
    
    location ~ /(\.git(/|$)|backup(/|$)|\.DS_Store|\.gitignore) {
        deny all;
    }
}
EOF

systemctl reload nginx
echo "Nginx virtual host configuration for $INPUT_DOMAIN has been created."
}

install_acme(){
    curl https://get.acme.sh | sh -s email=$INPUT_EMAIL
}

request_cert(){
    mkdir -p $NGINX_WEB_ROOT/$INPUT_DOMAIN/cert
    mkdir -p $NGINX_WEB_ROOT/$INPUT_DOMAIN/web_root
    mkdir -p $NGINX_WEB_ROOT/$INPUT_DOMAIN/logs
    $ACME_HOME/acme.sh --issue -d $INPUT_DOMAIN --webroot $NGINX_WEB_ROOT/$INPUT_DOMAIN/web_root/
}

install_cert(){
$ACME_HOME/acme.sh --install-cert -d $INPUT_DOMAIN \
--key-file       $NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$PRIVATE_NAME  \
--fullchain-file $NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$FULLCHAIN_NAME \
--reloadcmd     "service nginx force-reload"
}

create_acme_service(){
rm -rf /etc/systemd/system/acme-$INPUT_DOMAIN.service
cat << EOF | sudo tee /etc/systemd/system/acme-$INPUT_DOMAIN.service
[Unit]
Description=Run acme.sh to renew SSL certificates for $INPUT_DOMAIN
After=network.target

[Service]
Type=oneshot
ExecStart=$ACME_HOME/acme.sh --cron --home $ACME_HOME --domain $INPUT_DOMAIN

[Install]
WantedBy=multi-user.target
EOF
}

create_acme_service_timer(){
rm -rf /etc/systemd/system/acme-$INPUT_DOMAIN.timer
cat << EOF | sudo tee /etc/systemd/system/acme-$INPUT_DOMAIN.timer
[Unit]
Description=Timer for acme.sh service for $INPUT_DOMAIN

[Timer]
OnCalendar=*-*-* $AUTO_REFRESH_TIME
Unit=acme-$INPUT_DOMAIN.service
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

enable_service(){
    sudo systemctl daemon-reload
    sudo systemctl enable --now acme-$INPUT_DOMAIN.timer
    sudo systemctl enable --now acme-$INPUT_DOMAIN.service
    sudo systemctl start --now acme-$INPUT_DOMAIN.service
}

onkey_install(){
    if nginx_is_runing; then
        input_domain \
        && input_email \
        && create_nginx_vhost \
        && wait \
        && install_acme \
        && wait \
        && request_cert \
        && wait \
        && install_cert \
        && wait \
        && create_acme_service \
        && wait \
        && create_acme_service_timer \
        && enable_service

        return 0
    else
        echo "nginx not runing"
        return 1
    fi
}

steps_install(){
    if nginx_is_runing; then
        create_nginx_vhost \
        && wait \
        && install_acme \
        && wait \
        && request_cert \
        && wait \
        && install_cert \
        && wait \
        && create_acme_service \
        && wait \
        && create_acme_service_timer \
        && enable_service

        return 0
    else
        echo "nginx not runing"
        return 1
    fi
}


handle_input(){
    inputs=$1
    pre_config
    if [[ -z "${inputs// }" ]]; then
        if onkey_install; then
            echo "$INPUT_DOMAIN auto ssl service installed"
            echo "$INPUT_DOMAIN private-key at [$NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$PRIVATE_NAME]"
            echo "$INPUT_DOMAIN fullchain-key at [$NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$FULLCHAIN_NAME]"
            return 0
        else
            echo "$INPUT_DOMAIN auto ssl service installation failed"
            return 1
        fi
    else
        echo -----------------
        echo domain=$INPUT_DOMAIN
        echo domain=$INPUT_EMAIL
        echo -----------------
        parmas02=$2
        parmas03=$3
        parmas04=$4
        parmas05=$5
        parmas06=$6
         if [[ -z "${inputs// }" ]] || [[ -z "${parmas02// }" ]] || [[ -z "${parmas03// }" ]] || [[ -z "${parmas04// }" ]] || [[ -z "${parmas05// }" ]] || [[ -z "${parmas06// }" ]]; then
            echo "parmas error Simple With [./auto_ssl.sh -webroot /testberoot -domain www.test.com -email testtest@gmail.com]"
            return 1
         fi

        if [[ $1 == "-webroot" ]]; then
            NGINX_WEB_ROOT=$2
        else
            echo "parmas error [-webroot]"
            return 1
        fi

        if [[ $3 == "-domain" ]]; then
            INPUT_DOMAIN=$4
        else
            echo "parmas error [-domain]"
            return 1
        fi

        if [[ $5 == "-email" ]]; then
            INPUT_EMAIL=$6
        else
            echo "parmas error [-email]"
            return 1
        fi


        if steps_install; then
            echo "$INPUT_DOMAIN auto ssl service installed"
            echo "$INPUT_DOMAIN private-key at [$NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$PRIVATE_NAME]"
            echo "$INPUT_DOMAIN fullchain-key at [$NGINX_WEB_ROOT/$INPUT_DOMAIN/cert/$FULLCHAIN_NAME]"
            return 0
        else
            echo "$INPUT_DOMAIN auto ssl service installation failed"
            return 1
        fi
    fi
}

handle_input "$@" && wait && rm -rf $SCRIPT_NAME