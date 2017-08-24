#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# This script decrypts the NES Classic Edition NAND image at /nand/nand.bin using the key file found in /nand/kernel.img
# and mounts the decrypted NAND at /mnt/nand

NAND_IMAGE_ENCRYPTED="/nand/nand.bin"
LOGICAL_VOLUME="/nand/logical.bin"

KERNEL_IMAGE="/nand/kernel.img"
KEY_FILE="/nand/key-file"

ROOTFS_ENCRYPTED="/nand/rootfs.bin"
ROOTFS_DECRYPTED="/nand/rootfs.hsqs"
ROOTFS_MOUNTPOINT="/mnt/rootfs"

DATA_PARTITION="/nand/data.bin"
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

        $SCRIPT_DIR/extractkeyfile.sh $KERNEL_IMAGE
    fi

    # Extract partitions and decrypt rootfs
    $SCRIPT_DIR/extractpartitions.sh $LOGICAL_VOLUME
    $SCRIPT_DIR/decryptrootfs.sh $ROOTFS_ENCRYPTED $KEY_FILE $ROOTFS_DECRYPTED
fi

if [ -f $ROOTFS_DECRYPTED ]
then
    # Mount the decrypted rootfs partition
    mkdir $ROOTFS_MOUNTPOINT
    mount -o loop,ro $ROOTFS_DECRYPTED $ROOTFS_MOUNTPOINT
    echo "rootfs mounted at $ROOTFS_MOUNTPOINT!"
fi

if [ -f $DATA_PARTITION ]
then
    # Mount the data partition
    mkdir $DATA_MOUNTPOINT
    mount $DATA_PARTITION $DATA_MOUNTPOINT
    echo "data mounted at $DATA_MOUNTPOINT!"
fi