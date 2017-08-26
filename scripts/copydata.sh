#!/bin/bash

# Copies all the files from the data partition to the given destination folder, which is created if it does not exist

if [ "$#" -ne 1 ]
then
    echo "Usage: copydata <target directory>"
    exit 0
fi

TARGET_DIR=$1

mkdir --parents $TARGET_DIR
cp -r /mnt/data/* $TARGET_DIR