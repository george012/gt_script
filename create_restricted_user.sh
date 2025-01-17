#!/bin/bash
set -e

# 检查是否传入了参数
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <ssh-public-key>"
    exit 1
fi

# 获取传入的参数
USERNAME=$1
PUB_KEY=$2

# 创建新用户，但不创建默认的 /home/<username> 目录
# --no-create-home 确保不创建默认的 /home/<username> 目录
sudo useradd --no-create-home -d /usr/local/$USERNAME $USERNAME

# 设置用户的 shell
sudo usermod -s /bin/bash $USERNAME

# 创建用户目录并确保用户是该目录的所有者
sudo mkdir -p /usr/local/$USERNAME
sudo chown root:root /usr/local/$USERNAME  # root 拥有该目录

# 创建用户自己的文件夹，在 ChrootDirectory 下可以操作
sudo mkdir -p /usr/local/$USERNAME/home/$USERNAME
sudo chown $USERNAME:$USERNAME /usr/local/$USERNAME/home/$USERNAME  # 用户拥有自己的文件夹

# 配置 SSH 目录和权限
sudo mkdir -p /usr/local/$USERNAME/.ssh
echo "$PUB_KEY" | sudo tee /usr/local/$USERNAME/.ssh/authorized_keys > /dev/null
sudo chmod 700 /usr/local/$USERNAME/.ssh
sudo chmod 600 /usr/local/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /usr/local/$USERNAME/.ssh

# 配置 SSH 受限访问，只允许 SFTP 访问并锁定目录
# 限制用户只能访问自己的目录
sudo bash -c "echo 'Match User $USERNAME' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    ChrootDirectory /usr/local/$USERNAME' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    ForceCommand internal-sftp' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    AllowTcpForwarding no' >> /etc/ssh/sshd_config"

# 重新加载 SSH 配置
sudo systemctl restart sshd

echo "User $USERNAME created with restricted access to /usr/local/$USERNAME and SSH public key authentication."
