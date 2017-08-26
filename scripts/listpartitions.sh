#!/bin/bash
set -e

# This script lists the partition data from the given logical volume

if [ "$#" -ne 1 ]
then
    echo "Usage: listpartitions <logical volume image>"
    exit 0
fi

LOGICAL_VOLUME=$1

# Run sunxi-nand-part -f a20 logical.bin in combination with grep to find the partitions within the NAND dump, then use
# sed to extract the name, start and size of each partition.
sunxi-nand-part -f a20 $LOGICAL_VOLUME | grep --perl-regexp "partition\s+\d+:" | sed -r "s/partition\s+[[:digit:]]+:\s+class\s+=\s+[A-Za-z]+,\s+name\s+=\s+([A-Za-z]+),\s+partition start\s+=\s+([[:digit:]]+),\s+partition size\s+=\s+([[:digit:]]+)\s+user_type=[[:digit:]]+/\1 \2 \3/"