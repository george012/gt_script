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

# logrotate config
function create_logrotate_config(){
sudo rm -rf /etc/logrotate.d/${INPUT_DOMAIN}

cat << EOF | sudo tee /etc/logrotate.d/${INPUT_DOMAIN}
$CORE_GETH_LOG_Dir/${INPUT_DOMAIN}.log {
    hourly
    rotate 720
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
}
EOF
}

# logrotate systemd
function create_logrotate_service(){
sudo rm -rf /etc/systemd/system/${INPUT_DOMAIN}_logrotate.service

cat << EOF | sudo tee /etc/systemd/system/${INPUT_DOMAIN}_logrotate.service
[Unit]
Description=Logrotate for ${INPUT_DOMAIN}

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate /etc/logrotate.d/${INPUT_DOMAIN}
EOF
}

# logrotate systemd timer
function create_logrotate_service_timer(){
sudo rm -rf /etc/systemd/system/${INPUT_DOMAIN}_logrotate.timer

cat << EOF | sudo tee /etc/systemd/system/${INPUT_DOMAIN}_logrotate.timer
[Unit]
Description=Run logrotate for ${INPUT_DOMAIN} every 5 minutes

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

function handle_logrotate() {
    create_logrotate_config
    create_logrotate_service
    create_logrotate_service_timer

    sudo systemctl daemon-reload
    sudo systemctl enable --now ${INPUT_DOMAIN}_logrotate.timer
    sudo systemctl enable --now ${INPUT_DOMAIN}_logrotate.service
    sudo systemctl start --now ${INPUT_DOMAIN}_logrotate.service
} 


function pre_config(){
    sudo apt update && wait && sudo apt install -y net-tools vim sysstat unzip zip wget curl gnupg lsb-release certbot cron
}

function nginx_is_runing(){
    if pgrep nginx >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function is_valid_domain() {
    local domain="$1"
    if [[ $domain =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

function is_valid_email() {
    local email="$1"
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

function input_domain(){
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

function input_email(){
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

function create_nginx_vhost(){
    local BASE_DOMAIN=no
    if [[ ${INPUT_DOMAIN} == www.* ]]; then
        # 移除www.，获得基础域名
        BASE_DOMAIN=${INPUT_DOMAIN#www.}
    fi

    # 如果 BASE_DOMAIN 有有效值，则在 server_name 中包括它
    local SERVER_NAME=${INPUT_DOMAIN}
    if [[ ${BASE_DOMAIN} != "no" ]]; then
        SERVER_NAME="${INPUT_DOMAIN} ${BASE_DOMAIN}"
    fi
NGINX_CONFIG_TEMPLATE=$(cat << EOF
server {
    listen       80;
    server_name ${SERVER_NAME};

    root $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root;

    index index.php index.html index.htm;
    error_page 400 401 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 500 501 502 503 504 =200 /404.html;

    location ~ /(\.git(/|$)|backup(/|$)|\.DS_Store|\.gitignore) {
        deny all;
    }

    access_log ${NGINX_WEB_ROOT}/${INPUT_DOMAIN}/logs/access.log;
    error_log ${NGINX_WEB_ROOT}/${INPUT_DOMAIN}/logs/error.log;
}

# server {
#     listen 80;
#     server_name ${SERVER_NAME};
    
#     # 重定向所有 HTTP 请求到 HTTPS
#     return 301 https://\$server_name\$request_uri;
# }

# server {
#     listen 443 ssl;
#     server_name ${SERVER_NAME};

#     # SSL 证书和私钥的位置
#     ssl_certificate /nginx_web/${INPUT_DOMAIN}/cert/fullchain.cer;
#     ssl_certificate_key /nginx_web/${INPUT_DOMAIN}/cert/private.key;

#     # 强化 HTTPS 设置
#     ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
#     ssl_prefer_server_ciphers on;
#     ssl_ciphers 'AEAD-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';


#     root $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root;
#     index index.php index.html index.htm;
#     error_page 400 401 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 500 501 502 503 504 =200 /404.html;
    
#     location ~ /(\.git(/|$)|backup(/|$)|\.DS_Store|\.gitignore) {
#         deny all;
#     }

#     access_log ${NGINX_WEB_ROOT}/${INPUT_DOMAIN}/logs/access.log;
#     error_log ${NGINX_WEB_ROOT}/${INPUT_DOMAIN}/logs/error.log;
# }
EOF
)

  TARGET_FILE="/etc/nginx/conf.d/$INPUT_DOMAIN.conf"
  AUTO_SSL_FILE="/etc/nginx/conf.d/$INPUT_DOMAIN.conf.autossl"
  if [[ -f $TARGET_FILE ]]; then
      echo "File $TARGET_FILE exists. Writing to $AUTO_SSL_FILE."
      echo "$NGINX_CONFIG_TEMPLATE" | sudo tee $AUTO_SSL_FILE
  else
      echo "File $TARGET_FILE does not exist. Writing to $TARGET_FILE."
      echo "$NGINX_CONFIG_TEMPLATE" | sudo tee $TARGET_FILE
  fi

    mkdir -p $NGINX_WEB_ROOT/${INPUT_DOMAIN}/cert
    mkdir -p $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root
    mkdir -p $NGINX_WEB_ROOT/${INPUT_DOMAIN}/logs

cat << EOF | sudo tee $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root/index.html
EOF

    ln -s $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root/index.html $NGINX_WEB_ROOT/${INPUT_DOMAIN}/web_root/404.html
    systemctl reload nginx
    systemctl restart nginx
    echo "Nginx virtual host configuration for ${INPUT_DOMAIN} has been created."
}

install_acme(){
    if [ -d "$HOME/.acme.sh" ]; then
        echo "acme.sh 已经安装，跳过安装步骤。"
    else
        curl https://get.acme.sh | sh -s email=$INPUT_EMAIL
    fi
}

function handleDefault {
    mkdir -p $NGINX_WEB_ROOT/default
    mkdir -p $NGINX_WEB_ROOT/default/logs
cat << EOF | sudo tee $NGINX_WEB_ROOT/default/index.html
EOF
    ln -s $NGINX_WEB_ROOT/default/index.html $NGINX_WEB_ROOT/default/404.html


cat << EOF | sudo tee /etc/nginx/conf.d/default.conf
    server {
    listen       80;

    root /nginx_web/default;

    index index.php index.html index.htm;
    error_page 400 401 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 500 501 502 503 504 =200 /404.html;

    location ~ /(\.git(/|$)|backup(/|$)|\.DS_Store|\.gitignore) {
        deny all;
    }

    access_log /nginx_web/default/logs/access.log;
    error_log /nginx_web/default/logs/error.log;
}
EOF
}

function request_cert(){
    if [[ ${INPUT_DOMAIN} == www.* ]]; then
        # 移除www.，获得基础域名
        local BASE_DOMAIN=${INPUT_DOMAIN#www.}
        # 为www和非www版本的域名发出证书
        $ACME_HOME/acme.sh --issue -d ${INPUT_DOMAIN} -d ${BASE_DOMAIN} --nginx --debug
    else
        # 只为输入的域名发出证书
        bash $ACME_HOME/acme.sh --issue -d ${INPUT_DOMAIN} --nginx --debug
    fi
}

function install_cert(){
$ACME_HOME/acme.sh --install-cert -d ${INPUT_DOMAIN} \
--key-file       $NGINX_WEB_ROOT/${INPUT_DOMAIN}/cert/$PRIVATE_NAME  \
--fullchain-file $NGINX_WEB_ROOT/${INPUT_DOMAIN}/cert/$FULLCHAIN_NAME \
--reloadcmd     "service nginx force-reload"
}

function create_acme_service(){
rm -rf /etc/systemd/system/${INPUT_DOMAIN}_acme.service
cat << EOF | sudo tee /etc/systemd/system/${INPUT_DOMAIN}_acme.service
[Unit]
Description=Run acme.sh to renew SSL certificates for ${INPUT_DOMAIN}
After=network.target

[Service]
Type=oneshot
ExecStart=$ACME_HOME/acme.sh --cron --home $ACME_HOME --domain ${INPUT_DOMAIN}

[Install]
WantedBy=multi-user.target
EOF
}

function create_acme_service_timer(){
rm -rf /etc/systemd/system/${INPUT_DOMAIN}_acme.timer
cat << EOF | sudo tee /etc/systemd/system/${INPUT_DOMAIN}_acme.timer
[Unit]
Description=Timer for acme.sh service for ${INPUT_DOMAIN}

[Timer]
OnCalendar=*-*-* $AUTO_REFRESH_TIME
Unit=${INPUT_DOMAIN}_acme.service
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

function enable_service(){
    sudo systemctl daemon-reload
    sudo systemctl enable --now ${INPUT_DOMAIN}_acme.timer
    sudo systemctl enable --now ${INPUT_DOMAIN}_acme.service
    sudo systemctl start --now ${INPUT_DOMAIN}_acme.service
}

function onkey_install(){
    if nginx_is_runing; then
        input_domain \
        && input_email \
        && create_nginx_vhost \
        && handleDefault \
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

function steps_install(){
    if nginx_is_runing; then
        create_nginx_vhost \
        && handleDefault \
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


function handle_input(){
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

        if [[ $1 == "-nginx_web_root" ]]; then
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