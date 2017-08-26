FROM debian:latest
COPY ["ftl", "/root/ftl/"]
RUN apt-get update && \
apt-get install -y build-essential && \
apt-get install -y lzop && \
apt-get install -y git && \
cd /root && \
git clone https://github.com/linux-sunxi/sunxi-tools && \
apt-get install -y libusb-1.0-0-dev && \
apt-get install -y pkg-config && \
cd /root/sunxi-tools && \
make && \
make install && \
cd /root/ftl && \
make && \
DEBIAN_FRONTEND=noninteractive apt-get install -y cryptsetup
COPY ["split_bootimg/", "/root/split_bootimg/"]
COPY ["scripts/", "/root/scripts/"]
RUN ln /root/scripts/copydata.sh /usr/bin/copydata && \
ln /root/scripts/copygames.sh /usr/bin/copygames && \
ln /root/scripts/decryptrootfs.sh /usr/bin/decryptrootfs && \
ln /root/scripts/extractkeyfile.sh /usr/bin/extractkeyfile && \
ln /root/scripts/extractpartitions.sh /usr/bin/extractpartitions && \
ln /root/scripts/listpartitions.sh /usr/bin/listpartitions && \
ln /root/scripts/mountnand.sh /usr/bin/mountnand && \
ln /root/scripts/mountpartition.sh /usr/bin/mountpartition
WORKDIR /nand
CMD ["/bin/bash", "-i", "-c", "mountnand; /bin/bash"]