#!/bin/bash

# This script decrypts the NES Classic Edition NAND image at /nand/nand.bin using the key file found in /nand/kernel.img
# and mounts the decrypted NAND at /mnt/nand

NAND_IMAGE_ENCRYPTED="/nand/nand.bin"
KERNEL="/nand/kernel.img"
KEY_FILE="/nand/key-file"
NAND_IMAGE_DECRYPTED="/nand/nand.hsqs"


if [ ! -f $NAND_IMAGE_DECRYPTED ]
then
    if [ ! -f $NAND_IMAGE_ENCRYPTED ]
    then
        echo "Missing encrypted NAND image at $NAND_IMAGE_ENCRYPTED"
        exit
    fi


    if [ ! -f $KEY_FILE ];
    then
        if [ ! -f $KERNEL ]
        then
            echo "Missing kernel image at $KERNEL"
            exit
        fi

        # Split kernel.img into kernel.img-kernel and kernel.img-ramdisk.gz
        perl /root/split_bootimg/split_bootimg.pl $KERNEL

        # Extract initramfs.cpio from kernel.img-ramdisk.gz
        lzop -x kernel.img-ramdisk.gz

        # Extract the key file from initramfs
        cpio -imdv key-file <initramfs.cpio

        # Clean up
        rm kernel.img-kernel
        rm kernel.img-ramdisk.gz
        rm initramfs.cpio
     fi

    # Remapping with ftl
    /root/ftl/decn $NAND_IMAGE_ENCRYPTED # produces logical.bin in the same folder

    # Run sunxi-nand-part -f a20 logical.bin to find the partitions within the NAND dump, then use sed to locate the
    # rootfs partition and pass the start and partition size data to dd in order to extract the rootfs partition to
    # rootfs.bin. The dd command should look something like this:
    #
    # dd if=logical.bin of=rootfs.bin bs=512 skip=38912 count=38912
    $(sunxi-nand-part -f a20 logical.bin | grep rootfs | sed -r "s/partition\s+[[:digit:]]+:\s+class\s+=\s+[A-Za-z]+,\s+name\s+=\s+rootfs,\s+partition start\s+=\s+([[:digit:]]+),\s+partition size\s+=\s+([[:digit:]]+)\s+user_type=[[:digit:]]+/dd if=logical.bin of=rootfs.bin bs=512 skip=\1 count=\2/")

    # Set up a loopback device with rootfs.bin as a back-file
    losetup -f rootfs.bin

    # Find out which loopback device was used (e.g. /dev/loop0)
    ROOTFS_DEVICE=$(losetup -l -O NAME,BACK-FILE | grep /nand/rootfs.bin | awk '{print $1}')

    # Open encrypted NAND loopback device as a mapping
    cryptsetup open $ROOTFS_DEVICE nand --type plain --cipher aes-xts-plain --key-file $KEY_FILE

    # Dump the decrypted NAND to a file
    dd if=/dev/mapper/nand of=$NAND_IMAGE_DECRYPTED

    # Close the encrypted NAND loopback device
    cryptsetup close nand

    # Release the loopback device
    losetup -d $ROOTFS_DEVICE

    # Clean up
    rm logical.bin
    rm rootfs.bin
    rm $KEY_FILE
fi

# Mount the decrypted NAND image to /mnt/nand
mkdir /mnt/nand
mount -o loop,ro $NAND_IMAGE_DECRYPTED /mnt/nand/
echo "NAND mounted at /mnt/nand!"