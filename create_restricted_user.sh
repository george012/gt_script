#!/bin/bash

# 检查是否传入了两个参数
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <ssh-public-key>"
    exit 1
fi

# 参数
USERNAME=$1
PUB_KEY=$2
USER_DIR="/usr/local/$USERNAME"

# 创建新用户，不生成默认主目录
sudo adduser --disabled-password --gecos "" --no-create-home "$USERNAME"

# 设置用户的 shell 为受限的 rbash
sudo usermod -s /bin/rbash "$USERNAME"

# 创建用户目录并设置权限
sudo mkdir -p "$USER_DIR"
sudo chown root:root "$USER_DIR"
sudo chmod 755 "$USER_DIR"

# 在用户目录下创建可写的子目录（可选）
sudo mkdir -p "$USER_DIR/upload"
sudo chown "$USERNAME:$USERNAME" "$USER_DIR/upload"

# 配置用户的 SSH 目录和权限
SSH_DIR="/home/$USERNAME/.ssh"
sudo mkdir -p "$SSH_DIR"
echo "$PUB_KEY" | sudo tee "$SSH_DIR/authorized_keys" > /dev/null
sudo chmod 700 "$SSH_DIR"
sudo chmod 600 "$SSH_DIR/authorized_keys"
sudo chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

# 配置 SSH ChrootDirectory
sudo bash -c "echo 'Match User $USERNAME' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    ChrootDirectory $USER_DIR' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    ForceCommand internal-sftp' >> /etc/ssh/sshd_config"
sudo bash -c "echo '    AllowTcpForwarding no' >> /etc/ssh/sshd_config"

# 重新加载 SSH 配置
sudo systemctl restart sshd

echo "User $USERNAME created with restricted access to $USER_DIR and SSH public key authentication."
