# Lanti/lempFFMPeg
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="FFMPeg" Vendor="Istvan Lantos" Version="1.0"

RUN echo -e "\
deb http://httpredir.debian.org/debian jessie-backports main contrib non-free" > /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y -t jessie-backports install \
        libav-tools \
        ffmpeg

RUN rm -rf /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
