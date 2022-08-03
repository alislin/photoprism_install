# chmod a+x photoprism_install.sh

# 检查 / 创建 目录
create_directory(){
    if [ ! -d $1 ]; then
        mkdir $1
    fi
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
rclone config

# 配置挂载
IMPORT_FILE=/etc/systemd/system/rclone-import.service
if [ ! -f $IMPORT_FILE ]; then
    echo "[Unit]" >> $IMPORT_FILE
    echo "Description=Rclone" >> $IMPORT_FILE
    echo "After=network-online.target" >> $IMPORT_FILE
    echo "" >> $IMPORT_FILE
    echo "[Service]" >> $IMPORT_FILE
    echo "Type=simple" >> $IMPORT_FILE
    echo "ExecStart=rclone --vfs-cache-mode full mount od:photos/Import /mnt/onedrive/import" >> $IMPORT_FILE
    echo "Restart=on-abort" >> $IMPORT_FILE
    echo "User=root" >> $IMPORT_FILE
    echo "" >> $IMPORT_FILE
    echo "[Install]" >> $IMPORT_FILE
    echo "WantedBy=default.target" >> $IMPORT_FILE
fi
IMPORT_FILE=/etc/systemd/system/rclone-originals.service
if [ ! -f $IMPORT_FILE ]; then
    echo "[Unit]" >> $IMPORT_FILE
    echo "Description=Rclone" >> $IMPORT_FILE
    echo "After=network-online.target" >> $IMPORT_FILE
    echo "" >> $IMPORT_FILE
    echo "[Service]" >> $IMPORT_FILE
    echo "Type=simple" >> $IMPORT_FILE
    echo "ExecStart=rclone --vfs-cache-mode full mount od:photos/photoprism /mnt/onedrive/originals" >> $IMPORT_FILE
    echo "Restart=on-abort" >> $IMPORT_FILE
    echo "User=root" >> $IMPORT_FILE
    echo "" >> $IMPORT_FILE
    echo "[Install]" >> $IMPORT_FILE
    echo "WantedBy=default.target" >> $IMPORT_FILE
fi
# curl -O https://dxxx.com/rclone-import.service

# 开机执行服务自动挂载
systemctl enable rclone-originals
systemctl enable rclone-import
# 启动服务
systemctl start rclone-originals
systemctl start rclone-import

# 安装 photoprism
DIR=/opt/photoprism
if [! -d $DIR]; then
    mkdir $DIR
fi
cd /opt/photoprism
curl -O https://raw.githubusercontent.com/alislin/photoprism_install/main/docker-compose.od.yml
docker-compose -f docker-compose.od.yml up -d

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