#!/bin/bash
set -e

# This script creates the given mount point and mounts the given partition image at that mount point as read-only.
# It uses the norecovery option to enable read-only mounting of the data partition.

if [ "$#" -ne 2 ]
then
    echo "Usage: mountpartition <partition image> <mount point>"
    exit 0
fi

PARTITION_IMAGE=$1
MOUNTPOINT=$2

if [ ! -f $PARTITION_IMAGE ]
then
    echo "No partition image found at $PARTITION_IMAGE!"
    exit 1
fi

mkdir $MOUNTPOINT
mount --options loop,ro,norecovery $PARTITION_IMAGE $MOUNTPOINT