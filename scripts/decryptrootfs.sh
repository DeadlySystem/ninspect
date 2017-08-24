#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# This script extracts the rootfs partition from the given NAND image and decrypts it using the given key-file

ROOTFS_ENCRYPTED=$1
KEY_FILE=$2
ROOTFS_DECRYPTED=$3

# Set up a loopback device with rootfs.bin as a back-file
losetup -f $ROOTFS_ENCRYPTED

# Find out which loopback device was used (e.g. /dev/loop0)
ROOTFS_DEVICE=$(losetup -l -O NAME,BACK-FILE | grep $ROOTFS_ENCRYPTED | awk '{print $1}')

# Open encrypted rootfs loopback device as a mapping
cryptsetup open $ROOTFS_DEVICE rootfs --type plain --cipher aes-xts-plain --key-file $KEY_FILE

# Dump the decrypted rootfs to a file
dd if=/dev/mapper/rootfs of=$ROOTFS_DECRYPTED

# Close the encrypted NAND loopback device
cryptsetup close rootfs

# Release the loopback device
losetup -d $ROOTFS_DEVICE