# Lanti/lempFFmpeg
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="FFmpeg" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        curl \
        xz-utils \
        libav-tools 

RUN curl -fSL "http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz" -o "ffmpeg.tar.gz" \
    && mkdir -p /usr/ffmpeg \
    && tar -xf "ffmpeg.tar.gz" -C /usr/ffmpeg --strip-components=1 \
    && rm "ffmpeg.tar.gz"* \
    && echo 'export PATH="$PATH:/usr/ffmpeg"' >> /etc/bash.bashrc

RUN rm -rf /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
