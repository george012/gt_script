#!/bin/bash
set -e

#!/bin/bash

# 检查是否提供了必要的参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <ssh_public_key>"
    exit 1
fi

USERNAME=$1
SSH_PUBLIC_KEY=$2

# 添加用户并设置其主目录和 shell
useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME

# 将用户添加到必要的组
usermod -aG sudo $USERNAME
usermod -aG admin $USERNAME
usermod -aG adm $USERNAME

# # 创建新的 sudoers 文件并替换用户名
# SUDOERS_FILE="/etc/sudoers.d/90-cloud-init-users"
# NEW_SUDOERS_FILE="/etc/sudoers.d/$USERNAME"
# cp $SUDOERS_FILE $NEW_SUDOERS_FILE

# # 提取旧用户名并替换为新用户名
# OLD_USERNAME=$(awk '/User rules for/ {print $4}' $NEW_SUDOERS_FILE)
# sed -i "s/$OLD_USERNAME/$USERNAME/g" $NEW_SUDOERS_FILE

# # 设置新 sudoers 文件为只读
# chmod 440 $NEW_SUDOERS_FILE

# 切换到新用户并设置 SSH 公钥
sudo -u $USERNAME bash << EOF
# 创建 .ssh 目录
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh

# 将公钥添加到 authorized_keys 文件中
echo "$SSH_PUBLIC_KEY" > /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
EOF

# 确保新用户的主目录及其内容的所有权正确
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

echo "User $USERNAME has been created and configured with SSH access and sudo privileges."
