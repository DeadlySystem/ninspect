#!/bin/bash
set -e

# This script decrypts the NES Classic Edition NAND image at /dump/nand.bin using the key file found in /dump/kernel.img
# and mounts the decrypted rootfs partition and the data partition at /mnt/rootfs and /mnt/data, respectively.

NAND_IMAGE_ENCRYPTED="/dump/nand.bin"
LOGICAL_VOLUME="/dump/logical.bin"

KERNEL_IMAGE="/dump/kernel.img"
KEY_FILE="/dump/key-file"

ROOTFS_ENCRYPTED="/dump/rootfs.bin"
ROOTFS_DECRYPTED="/dump/rootfs.hsqs"
ROOTFS_MOUNTPOINT="/mnt/rootfs"

DATA_PARTITION="/dump/data.bin"
DATA_MOUNTPOINT="/mnt/data"

if [ ! -f $ROOTFS_DECRYPTED ]
then
    if [ ! -f $NAND_IMAGE_ENCRYPTED ]
    then
        echo "Missing encrypted NAND image at $NAND_IMAGE_ENCRYPTED"
        exit 1
    fi

    if [ ! -f $LOGICAL_VOLUME ]
    then
        # Remapping with ftl
        /root/ftl/decn $NAND_IMAGE_ENCRYPTED # produces logical.bin in the same folder
    fi

    if [ ! -f $KEY_FILE ]
    then
        if [ ! -f $KERNEL_IMAGE ]
        then
            echo "Missing kernel image at $KERNEL_IMAGE and key-file not present"
            exit 1
        fi

        extractkeyfile $KERNEL_IMAGE
    fi

    # Extract partitions and decrypt rootfs
    extractpartitions $LOGICAL_VOLUME
    decryptrootfs $ROOTFS_ENCRYPTED $KEY_FILE $ROOTFS_DECRYPTED
fi


if [ -f $ROOTFS_DECRYPTED ]
then
    # Mount the decrypted rootfs partition
    mountpartition $ROOTFS_DECRYPTED $ROOTFS_MOUNTPOINT
    echo "rootfs mounted at $ROOTFS_MOUNTPOINT!"
fi

if [ -f $DATA_PARTITION ]
then
    # Mount the data partition
    mountpartition $DATA_PARTITION $DATA_MOUNTPOINT
    echo "data mounted at $DATA_MOUNTPOINT!"
fi