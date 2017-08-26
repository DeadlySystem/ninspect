#!/bin/bash
set -e

# This script extracts the partitions from the given logical volume

if [ "$#" -ne 1 ]
then
    echo "Usage: extractpartitions <logical volume image>"
    exit 0
fi

LOGICAL_VOLUME=$1

# Read the partitions from the NAND image and use awk to construct dd commands to extract them, then execute these commands
listpartitions $LOGICAL_VOLUME |  awk '{system("dd if='$LOGICAL_VOLUME' of="$1".bin bs=512 skip="$2" count="$3)}'