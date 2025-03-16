#!/bin/bash -e

TARGET="lite"

TARGET_ROOTFS_DIR="binary"

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

sudo rm -rf $TARGET_ROOTFS_DIR/

if [ ! -d $TARGET_ROOTFS_DIR ] ; then
    sudo mkdir -p $TARGET_ROOTFS_DIR

    if [ ! -e ubuntu-base-22.04.4-base-$ARCH.tar.gz ]; then
        echo "\033[36m wget ubuntu-base-22.04.4-base-"$ARCH".tar.gz \033[0m"
        wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.4-base-$ARCH.tar.gz
    fi
    sudo tar -xzf ubuntu-base-22.04.4-base-$ARCH.tar.gz -C $TARGET_ROOTFS_DIR/
    sudo cp -b /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/resolv.conf
    sudo cp sources.list $TARGET_ROOTFS_DIR/etc/apt/sources.list

    if [ $ARCH==riscv64 ];then
	    sudo cp -b /usr/bin/qemu-riscv64-static $TARGET_ROOTFS_DIR/usr/bin/
    elif [ $ARCH==armhf ];then
        sudo cp -b /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
    elif [ $ARCH==arm64 ];then
        sudo cp -b /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
    else
        echo "Unsupported framework"
        exit -1
    fi
fi

finish() {
    ./ch-mount.sh -u $TARGET_ROOTFS_DIR
    echo -e "error exit"
    exit -1
}
trap finish ERR

echo -e "\033[47;36m Change root.................... \033[0m"

./ch-mount.sh -m $TARGET_ROOTFS_DIR

cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR/ /bin/bash

export LC_ALL=C.UTF-8

# Add passwd
passwd root <<IEOF
root
root
IEOF

# set localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sync

EOF


./ch-mount.sh -u $TARGET_ROOTFS_DIR

DATE=$(date +%Y%m%d)
echo -e "\033[47;36m Run tar pack ubuntu-base-$TARGET-$ARCH-$DATE.tar.gz \033[0m"
sudo tar zcf ubuntu-base-$TARGET-$ARCH-$DATE.tar.gz $TARGET_ROOTFS_DIR

# sudo rm $TARGET_ROOTFS_DIR -r

echo -e "\033[47;36m normal exit \033[0m"
