#!/bin/bash
set -e

CUSTOM_FILNAME=$(basename "$0")
echo "file name with "$CUSTOM_FILNAME

optimize_limits_conf() {
    local limits_conf_file="/etc/security/limits.conf"
    local limits_conf=(
        "root soft nproc 51200"
        "root hard nproc 51200"
        "root soft nofile 1024000"
        "root hard nofile 1024000"
    )

    if [ ! -f "$limits_conf_file" ]; then
        echo "File not found: $limits_conf_file"
        exit 1
    fi

    if [ ! -f "$limits_conf_file.bak" ]; then
        cp "$limits_conf_file" "$limits_conf_file.bak"
    fi

    for conf_item in "${limits_conf[@]}"; do
        if grep -q -E "^${conf_item}\$" "$limits_conf_file"; then
            # 如果存在相同的配置项，则删除整行
            sed -i -E "/^${conf_item}\$/d" "$limits_conf_file"
        fi

        # 添加新的配置项
        echo "$conf_item" >> "$limits_conf_file"
    done
}

optimize_sysctl_conf() {
    local sysctl_conf_file="/etc/sysctl.conf"
    local sysctl_conf=(
        "net.core.somaxconn = 65535"
        "net.ipv4.tcp_max_syn_backlog = 65535"
        "net.ipv4.ip_local_port_range = 1024 65535"
        "net.ipv4.tcp_sack = 1"
        "net.ipv4.tcp_timestamps = 1"
        "net.ipv4.tcp_keepalive_time = 600"
        "net.ipv4.tcp_keepalive_probes = 9"
        "net.ipv4.tcp_keepalive_intvl = 10"
        "net.ipv4.tcp_fin_timeout = 30"
        "net.ipv6.conf.all.disable_ipv6 = 1"
        "net.ipv6.conf.default.disable_ipv6 = 1"
    )

    if [ ! -f "$sysctl_conf_file" ]; then
        echo "File not found: $sysctl_conf_file"
        exit 1
    fi

    if [ ! -f "$sysctl_conf_file.bak" ]; then
        cp "$sysctl_conf_file" "$sysctl_conf_file.bak"
    fi

    for conf_item in "${sysctl_conf[@]}"; do
        local item_name=$(echo "$conf_item" | awk -F'=' '{print $1}')
        local item_value=$(echo "$conf_item" | awk -F'=' '{print $2}')

        if grep -q -E "^${item_name}\s*=" "$sysctl_conf_file"; then
            sed -i -E "s/^${item_name}\s*=.*/${conf_item}/" "$sysctl_conf_file"
        else
            echo "$conf_item" >> "$sysctl_conf_file"
        fi
    done

    sysctl -p >/dev/null
}

optimize_limits_conf && wait && optimize_sysctl_conf && wait && rm -rf $CUSTOM_FILNAME && wait && echo "Optimization complete"
