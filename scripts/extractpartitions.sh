#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# This script extracts the partitions from the given logical volume

LOGICAL_VOLUME=$1

# Read the partitions from the NAND image and use awk to construct dd commands to extract them, then execute these commands
$SCRIPT_DIR/listpartitions.sh $LOGICAL_VOLUME |  awk '{system("dd if='$LOGICAL_VOLUME' of="$1".bin bs=512 skip="$2" count="$3)}'