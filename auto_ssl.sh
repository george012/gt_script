#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

INPUT_DOMAIN=""
INPUT_EMAIL=""
AUTO_REFRESH_TIME="10:10:10"
ACME_HOME="$HOME/.acme.sh"

pre_config(){
    sudo apt update && wait && sudo apt install -y unzip zip wget curl gnupg lsb-release
}

nginx_is_runing(){
    if pgrep nginx >/dev/null 2>&1; then
        exit 0
    else
        exit 1
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

input_web_dir(){
    echo "====Please Input cert dir===="
    echo "====default with /root/===="
    read -p "Please Input(请输入): " input_cert_dir
    if [[ -z "${input_string// }" ]]; then
        INPUT_EMAIL="$input_string"
    else
        echo "Invalid Email"
    fi
}

install_acme(){
    curl https://get.acme.sh | sh -s $INPUT_EMAIL
}
request_cert(){
    $ACME_HOME/acme.sh --issue --standalone -d $DOMAIN
    $ACME_HOME/acme.sh --issue -d mydomain.com -d www.mydomain.com --webroot /home/wwwroot/mydomain.com/
}



# 创建 acme.sh 的 systemd service 文件
cat << EOF | sudo tee /etc/systemd/system/acme.sh-$DOMAIN.service
[Unit]
Description=Run acme.sh to renew SSL certificates for $DOMAIN
After=network.target

[Service]
Type=oneshot
ExecStart=$ACME_HOME/acme.sh --cron --home $ACME_HOME --domain $DOMAIN

[Install]
WantedBy=multi-user.target
EOF

# 创建 acme.sh 的 systemd timer 文件
cat << EOF | sudo tee /etc/systemd/system/acme.sh-$DOMAIN.timer
[Unit]
Description=Timer for acme.sh service for $DOMAIN

[Timer]
OnCalendar=*-*-* $TIME
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 重新加载 systemd 配置并启用 timer
sudo systemctl daemon-reload
sudo systemctl enable --now acme.sh-$DOMAIN.timer

# 输出 timer 状态
sudo systemctl status acme.sh-$DOMAIN.timer

# 创建证书和私钥的符号链接
ln -s $ACME_HOME/$DOMAIN/fullchain.cer $HOME/$DOMAIN-fullchain.cer
ln -s $ACME_HOME/$DOMAIN/$DOMAIN.key $HOME/$DOMAIN.key

echo "证书和私钥的符号链接已创建在 $HOME 目录下。"

install(){
    if nginx_is_runing; then
        
    else
        echo "nginx not runing"
    fi
}

pre_config && wait && install_redis && wait && rm -rf $SCRIPT_NAME && wait && echo "redis is installed"

