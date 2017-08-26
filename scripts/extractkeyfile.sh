#!/bin/bash
set -e

# This script extracts the key-file from the given kernel image

if [ "$#" -ne 1 ]
then
    echo "Usage: extractkeyfile <kernel image>"
    exit 0
fi

KERNEL_IMAGE=$1

if [ ! -f $KERNEL_IMAGE ]
then
    echo "No kernel image found at $KERNEL_IMAGE"
    exit 1
fi

# Split kernel.img into kernel.img-kernel and kernel.img-ramdisk.gz
perl /root/split_bootimg/split_bootimg.pl $KERNEL_IMAGE

# Extract initramfs.cpio from kernel.img-ramdisk.gz
lzop -x $KERNEL_IMAGE-ramdisk.gz

# Extract the key file from initramfs
cpio -imdv key-file <initramfs.cpio

# Clean up
rm $KERNEL_IMAGE-kernel
rm $KERNEL_IMAGE-ramdisk.gz
rm initramfs.cpio