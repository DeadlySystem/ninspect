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
COPY ["split_bootimg", "/root/split_bootimg/"]
COPY ["scripts/*.sh", "/root/"]
COPY ["scripts/.bashrc", "/root/"]
WORKDIR /nand
CMD ["/bin/bash", "-i", "-c", "mountnand && /bin/bash"]