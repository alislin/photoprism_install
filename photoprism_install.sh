# #################################################################
# curl https://raw.githubusercontent.com/alislin/photoprism_install/main/photoprism_install.sh | sudo bash
# chmod a+x photoprism_install.sh

# 检查 / 创建 目录
create_directory(){
    if [ ! -d $1 ]; then
        echo "+ create directory: $1"
        mkdir $1
    else
        echo "$1 exist"
    fi
}
log(){
    echo "$1"
}

# 配置rclone
# 创建目录
create_directory /mnt/onedrive
create_directory /mnt/onedrive/import
create_directory /mnt/onedrive/originals

# apt install fuse
# apt install docker-compose
yum -y install fuse

# 下载 rclone
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64

# 安装
cp rclone /usr/bin/
chown root:root /usr/bin/rclone
chmod 755 /usr/bin/rclone

# 配置
# (echo n
# sleep 1
# echo od
# sleep 1
# echo 32
# sleep 1
# echo
# sleep 1
# echo
# sleep 1
# echo 1
# sleep 1
# echo n
# sleep 1
# echo n)|
rclone config

# 配置挂载
IMPORT_FILE=/etc/systemd/system/rclone-import.service
if [ ! -f $IMPORT_FILE ]; then
cat>$IMPORT_FILE<<EOF
[Unit]
Description=Rclone
After=network-online.target

[Service]
Type=simple
ExecStart=rclone --vfs-cache-mode full mount od:photos/Import /mnt/onedrive/import
Restart=on-abort
User=root

[Install]
WantedBy=default.target
EOF

fi
IMPORT_FILE=/etc/systemd/system/rclone-originals.service
if [ ! -f $IMPORT_FILE ]; then
cat>$IMPORT_FILE<<EOF
[Unit]
Description=Rclone
After=network-online.target

[Service]
Type=simple
ExecStart=rclone --vfs-cache-mode full mount od:photos/photoprism /mnt/onedrive/originals
Restart=on-abort
User=root

[Install]
WantedBy=default.target
EOF
fi

# 开机执行服务自动挂载
systemctl enable rclone-originals
systemctl enable rclone-import
# 启动服务
systemctl start rclone-originals
systemctl start rclone-import

# 安装 photoprism
DIR=/opt/photoprism
create_directory $DIR
cd $DIR
curl -O https://raw.githubusercontent.com/alislin/photoprism_install/main/docker-compose.od.yml
docker-compose -f docker-compose.od.yml up -d

echo ""
echo "****************************************"
echo "Install finish!"
echo "default user: admin"
echo "default password: 12345678"
echo "change default password at first !"
echo ""
echo "Check swap,at least 4G to run"
echo "# view swap"
echo "swapon --show"
echo ""
echo "# allocate swap"
echo "sudo -i"
echo "fallocate -l 4G /swapfile"
echo "chmod 600 /swapfile"
echo "mkswap /swapfile"
echo "swapon /swapfile"
echo "echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"
echo "****************************************"