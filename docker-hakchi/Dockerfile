FROM debian:latest

# Clone and build hakchi
RUN apt-get update && \
apt-get install -y build-essential && \
apt-get install -y git && \
git clone https://github.com/madmonkey1907/hakchi.git && \
cd hakchi && \
git submodule init && \
git submodule update && \
apt-get install -y libusb-1.0-0-dev libqt4-dev upx-ucl cpio lzop wget && \
apt-get install -y pkg-config && \
make

# The following is an effort to download, extract, patch and build fes.bin and u-boot.bin
# RUN mkdir data && \
# cd /hakchi/r16-uboot && \
# wget http://data.nintendo.co.jp/oss/NintendoEntertainmentSystemNESClassicEdition_OSS.zip && \
# apt-get install -y unzip && \
# unzip -j NintendoEntertainmentSystemNESClassicEdition_OSS.zip NintendoEntertainmentSystemNESClassicEdition_OSS/r16-uboot-fc3061df4dbd4153819b2d2f141d82b88fea51cf.tar.gz && \
# tar -xf r16-uboot-fc3061df4dbd4153819b2d2f141d82b88fea51cf.tar.gz && \
# cd r16-uboot-fc3061df4dbd4153819b2d2f141d82b88fea51cf && \
# patch -p1 < ../r16-uboot.diff && \
# apt-get install -y gcc-arm-linux-gnueabihf && \
# ./build.sh && \
# cp fes.bin ../../data/fes1.bin && \
# cp u-boot.bin ../../data/uboot.bin

# sntool check -f fes1.bin
# sntool split u-boot.bin
# sntool join u-boot.bin script.bin

# Copy fes1.bin and uboot.bin
COPY ["data", "/hakchi/data"]

# Start hakchi-gui
WORKDIR /hakchi
SHELL ["/bin/bash", "-c"]
CMD . importpath && hakchi-gui