#!/bin/bash
set -e

CUSTOM_FILNAME=$(basename "$0")
echo "file name with "$CUSTOM_FILNAME

LIMITNOFILE=1024000

optimize_limits_conf() {
    local limits_conf_file="/etc/security/limits.conf"
    local limits_conf=(
        "* soft nofile ${LIMITNOFILE}"
        "* hard nofile ${LIMITNOFILE}"
        "root soft nofile ${LIMITNOFILE}"
        "root hard nofile ${LIMITNOFILE}"
    )

    if [ ! -f "$limits_conf_file" ]; then
        echo "File not found: $limits_conf_file"
        exit 1
    fi

    if [ ! -f "$limits_conf_file.bak" ]; then
        cp "$limits_conf_file" "$limits_conf_file.bak"
    fi

    for conf_item in "${limits_conf[@]}"; do
        # 使用sed对特殊字符进行转义，尤其是`*` 
        local escaped_conf_item=$(echo "$conf_item" | sed -e 's/\*/\\*/g' -e 's/\./\\./g')
        
        if grep -q -E "^${escaped_conf_item}\$" "$limits_conf_file"; then
            # 如果存在相同的配置项，则删除整行
            sed -i -E "/^${escaped_conf_item}\$/d" "$limits_conf_file"
        fi

        # 添加新的配置项
        echo "$conf_item" >> "$limits_conf_file"
    done
}

optimize_sysctl_conf() {
    local sysctl_conf_file="/etc/sysctl.conf"
    local sysctl_conf=(
        "net.core.somaxconn = 65000"
        "net.core.netdev_max_backlog = 51200"
        "net.core.default_qdisc=cake"
        "net.ipv4.tcp_max_syn_backlog = 32768"
        "net.ipv4.ip_local_port_range = 1024 65000"
        "net.ipv4.tcp_sack = 1"
        "net.ipv4.tcp_timestamps = 1"
        "net.ipv4.tcp_keepalive_time = 20"
        "net.ipv4.tcp_keepalive_probes = 3"
        "net.ipv4.tcp_keepalive_intvl = 5"
        "net.ipv4.tcp_fin_timeout = 30"
        "net.ipv6.conf.all.disable_ipv6 = 1"
        "net.ipv6.conf.default.disable_ipv6 = 1"
        "net.ipv4.tcp_tw_reuse = 1"
        "net.ipv4.tcp_max_orphans = 32768"
        "net.ipv4.route.gc_timeout = 100"
        "net.ipv4.tcp_syn_retries = 1"
        "net.ipv4.tcp_synack_retries = 1"
        "net.ipv4.tcp_syncookies = 1"
        "net.ipv4.tcp_congestion_control=bbr"
        "net.ipv4.tcp_ecn=2"
        "fs.file-max = ${LIMITNOFILE}"
        "fs.inotify.max_user_instances = 8192"
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

optimize_limits_conf && wait && optimize_sysctl_conf && wait && echo "Optimization NetWork Complete" && wait && rm -rf $CUSTOM_FILNAME
