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

### mountnand

Mounts a decrypted NAND at /mnt/nand. This is done by the default CMD of the container.

## FAQ

##### After running mountnand, there is a file called nand.hsqs in the nand directory that stays there. What is it?

This is an image of your decrypted NAND. It's the file that gets mounted to /mnt/nand when you run the mountnand
command. You can delete it if you want to.

#### Why does the container run in privileged mode?

Because the decryption relies on loopback device functionality provided by the docker host.

## Credits

ftl by madmonkey1907, downloaded from <https://www.dropbox.com/s/v4pnemkkt0zz1ei/nand.7z?dl=0> and published at
<https://github.com/madmonkey1907/hakchi/commit/669a8ee56ba6d66a90126756cd84f52ae0a5bc83>, inspired by
<https://gist.github.com/shuffle2/7a9c2f049be1efc06eb778ce0afb9605>

split_bootimg by jberkel, downloaded from <https://gist.github.com/jberkel/1087743>

Thanks to zerotri for describing [how to extract files from the kernel image](https://www.reddit.com/r/nintendo/comments/5cgbkm/linux_on_nes_classic_mini_current_progress_and/)