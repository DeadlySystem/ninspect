#!/bin/bash
set -e

# This script extracts the rootfs partition from the given NAND image and decrypts it using the given key-file

if [ "$#" -ne 3 ]
then
    echo "Usage: decryptrootfs <encrypted rootfs image> <key file> <decrypted rootfs image>"
    exit 0
fi

ROOTFS_ENCRYPTED=$1
KEY_FILE=$2
ROOTFS_DECRYPTED=$3

# Set up a loopback device with rootfs.bin as a back-file
ROOTFS_LOOP_DEVICE=$(losetup --find --read-only --show $ROOTFS_ENCRYPTED)

# Open encrypted rootfs loopback device as a mapping
cryptsetup open $ROOTFS_LOOP_DEVICE rootfs --type plain --cipher aes-xts-plain --key-file $KEY_FILE

# Dump the decrypted rootfs to a file
dd if=/dev/mapper/rootfs of=$ROOTFS_DECRYPTED

# Close the encrypted NAND loopback device
cryptsetup close rootfs

# Release the loopback device
losetup -d $ROOTFS_LOOP_DEVICE