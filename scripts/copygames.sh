#!/bin/bash

# Copies all the games to the given destination folder, which is created if it does not exist

if [ "$#" -ne 1 ]
then
    echo "Usage: copygames <target directory>"
    exit 0
fi

TARGET_DIR=$1

mkdir --parents $TARGET_DIR
cp -r /mnt/rootfs/usr/share/games/nes/kachikachi/* $TARGET_DIR