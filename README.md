# autobuild

Auto build rootfs(ubuntu-base), especially for riscv64.

The init proc (here is the ./busybox) is from busybox rootfs.

The init proc will run rcS, in which I place some simple commands, include:
- mount proc & sysfs
- exec neofetch to print some system information
- change to bash by executing /bin/bash


### Usage:

```bash
sudo ./mk-base-ubuntu.sh riscv64
sudo ./mk-ubuntu-rootfs.sh riscv64
```

You can get the ubuntu-rootfs.ext4. It is a simple rootfs, mainly used for experiments.

Note: Please don't use in production environment.

### Reference:

This is not completely original, and based on:

- https://github.com/LubanCat/sophon-image-build

- https://github.com/kvm-riscv/howto
