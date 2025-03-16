#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

TARGET="lite"

if [ "$1" == "riscv64" ]; then
    ARCH=riscv64
elif [ "$1" == "armhf" ]; then
    ARCH=armhf
elif [ "$1" == "arm64" ]; then
    ARCH=arm64
else
    echo "Usage:"
    echo "	$0 <ARCH>"
    exit
fi

echo -e "\033[47;36m Building for $ARCH \033[0m"

if [ ! $VERSION ]; then
    VERSION="release"
fi

DATE=$(date +%Y%m%d)

finish() {
    sudo umount $TARGET_ROOTFS_DIR/dev
    exit -1
}
trap finish ERR

echo -e "\033[47;36m Extract image \033[0m"
sudo rm -rf $TARGET_ROOTFS_DIR
sudo tar -xpf ubuntu-base-$TARGET-$ARCH-$DATE.tar.gz

if [ "$ARCH" == "riscv64" ]; then
    sudo cp -b /usr/bin/qemu-riscv64-static "$TARGET_ROOTFS_DIR/usr/bin/"
elif [ "$ARCH" == "armhf" ]; then
    sudo cp -b /usr/bin/qemu-arm-static "$TARGET_ROOTFS_DIR/usr/bin/"
elif [ "$ARCH" == "arm64" ]; then
    sudo cp -b /usr/bin/qemu-aarch64-static "$TARGET_ROOTFS_DIR/usr/bin/"
else
    echo "Unsupported framework"
    exit -1
fi

echo -e "\033[47;36m Change root.....................\033[0m"

sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev
sudo cp rcS $TARGET_ROOTFS_DIR/etc/init.d/rcS
sudo cp fstab $TARGET_ROOTFS_DIR/etc/fstab
# sudo cp motd $TARGET_ROOTFS_DIR/etc/motd
sudo cp busybox $TARGET_ROOTFS_DIR/bin/busybox

ID=$(stat --format %u $TARGET_ROOTFS_DIR)

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR /bin/bash

mount -t proc proc /proc
mount -t sysfs sys /sys

apt-get -y update
apt-get -f -y upgrade

apt-get install -fy neofetch vim iputils-ping

chmod +x /bin/busybox
chmod +x /etc/init.d/rcS

export LC_ALL=C.UTF-8

# create link
ln -sf /bin/busybox /sbin/init
# ln -sf /lib/systemd/systemd /sbin/init

umount /proc
umount /sys

EOF

sudo umount $TARGET_ROOTFS_DIR/dev

IMAGE_VERSION=$TARGET ./mk-image.sh 
