#!/bin/bash
set -e

# This script extracts the key-file from the given kernel image

KERNEL=$1

if [ ! -f $KERNEL ]
then
    echo "No kernel image found at $KERNEL"
    exit 1
fi

# Split kernel.img into kernel.img-kernel and kernel.img-ramdisk.gz
perl /root/split_bootimg/split_bootimg.pl $KERNEL

# Extract initramfs.cpio from kernel.img-ramdisk.gz
lzop -x $KERNEL-ramdisk.gz

# Extract the key file from initramfs
cpio -imdv key-file <initramfs.cpio

# Clean up
rm $KERNEL-kernel
rm $KERNEL-ramdisk.gz
rm initramfs.cpio