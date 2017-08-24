# ninspect: NES Classic NAND Inspector

## What it is

ninspect is a dockerized application that mounts  a raw, encrypted NAND dump from your NES Classic Edition inside a
Debian container and gives you a shell to inspect it. It runs on all systems that support Docker, including Windows.

## How to use

- Use [hakchi](https://github.com/madmonkey1907/hakchi) to dump both your kernel and NAND
- Place kernel.img and nand.bin inside the nand folder of ninspect
- Install docker on your computer
- From the docker prompt, cd to the ninspect folder
- Run `docker-compose run ninspect`

## Available special commands

### copygames

After mounting the NAND using _mountnand_, use this command to copy all the games to the nand folder of ninspect.

### copydata

After mounting the NAND using _mountnand_, use this command to copy all the files from the data partition to the nand
folder of ninspect.

### mountnand

Extracts the rootfs and data partitions from the raw NAND dump, decrypts the rootfs partition and mounts these
partitions at /mnt/rootfs and /mnt/data, respectively. This is done by the default CMD of the container.

## FAQ

##### What are all the files in the nand folder?

- nand.bin: The raw NAND image. To be provided by you.
- logical.bin: The logical volume extracted from nand.bin.
- kernel.img: The raw kernel image. To be provided by you, or alternatively provide the key-file found within it.
- key-file: The decryption key for the rootfs partition.
- boot.bin: The boot partition extracted from logical.bin.
- data.bin: The data partition extracted from logical.bin.
- private.bin: The private partition extracted from logical.bin. Usually all 0xFF.
- rootfs.bin: The encrypted rootfs partition extracted from logical.bin.
- UDISK.bin: The UDISK partition extracted from logical.bin. Usually zero-size.
- rootfs.hsqs: The decrypted rootfs partition.

##### Why does the container run in privileged mode?

Because the decryption relies on loopback device functionality provided by the docker host.

##### What else is in the NAND?

- 0x100000 through 0x18BFFF: uboot
- 0x600000 through 0x8B2000: kernel

## Test setup

Tested on Windows 7 Professional x64 with Docker Toolbox, using Docker version 17.04.0-ce, build 4845c56

## Troubleshooting

When running on Windows, make sure you clone ninspect somewhere inside your user folder in order to enable mounting. 

## Credits

ftl by madmonkey1907, downloaded from <https://www.dropbox.com/s/v4pnemkkt0zz1ei/nand.7z?dl=0> and published at
<https://github.com/madmonkey1907/hakchi/commit/669a8ee56ba6d66a90126756cd84f52ae0a5bc83>, inspired by
<https://gist.github.com/shuffle2/7a9c2f049be1efc06eb778ce0afb9605>

split_bootimg by jberkel, downloaded from <https://gist.github.com/jberkel/1087743>

Thanks to zerotri for describing [how to extract files from the kernel image](https://www.reddit.com/r/nintendo/comments/5cgbkm/linux_on_nes_classic_mini_current_progress_and/)