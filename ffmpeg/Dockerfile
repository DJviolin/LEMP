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

RUN curl -fSL "http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz" -o "ffmpeg-release-64bit-static.tar.xz" \
    && curl -fSL "http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz.md5" -o "ffmpeg-release-64bit-static.tar.xz.md5" \
    && cat ffmpeg-release-64bit-static.tar.xz.md5 | md5sum -c - \
    && mkdir -p /usr/ffmpeg \
    && tar -xf "ffmpeg-release-64bit-static.tar.xz" -C /usr/ffmpeg --strip-components=1 \
    && rm "ffmpeg-release-64bit-static.tar.xz"* \
    && echo 'export PATH="$PATH:/usr/ffmpeg"' >> /etc/bash.bashrc \

RUN rm -rf /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
