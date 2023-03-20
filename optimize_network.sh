#!/bin/bash

optimize_network() {
    # 优化系统配置以支持更高的并发连接
    # 提高文件描述符限制
    echo "fs.file-max = 1000000" | sudo tee -a /etc/sysctl.conf

    # 提高网络连接限制
    echo "net.core.somaxconn = 65535" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 65535" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.ip_local_port_range = 1024 65535" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_tw_reuse = 1" | sudo tee -a /etc/sysctl.conf

    # 启用 TCP Selective Acknowledgments（SACK）
    echo "net.ipv4.tcp_sack = 1" | sudo tee -a /etc/sysctl.conf

    # 启用 TCP 时间戳
    echo "net.ipv4.tcp_timestamps = 1" | sudo tee -a /etc/sysctl.conf

    # TCP keepalive 参数
    echo "net.ipv4.tcp_keepalive_time = 300" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_probes = 5" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_intvl = 15" | sudo tee -a /etc/sysctl.conf

    # 应用更改
    sudo sysctl -p
}

optimize_network && wait && history -c