# Lanti/lempBase
#
# VERSION               1.0.0

FROM debian:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="This image is the base of the other app images in this project" Vendor="Istvan Lantos" Version="1.0"

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
RUN ln -sf /bin/bash /bin/sh && ln -sf /bin/bash /bin/sh.distrib

RUN echo -e "\
deb http://httpredir.debian.org/debian stable main contrib non-free\n\
deb-src http://httpredir.debian.org/debian stable main contrib non-free\n\
deb http://security.debian.org stable/updates main contrib non-free\n\
deb-src http://security.debian.org stable/updates main contrib non-free\n\
deb http://httpredir.debian.org/debian stable-updates main contrib non-free\n\
deb-src http://httpredir.debian.org/debian stable-updates main contrib non-free" > /etc/apt/sources.list
RUN apt-get -y update && apt-get -y dist-upgrade

### Start of optimizations
# https://easyengine.io/tutorials/linux/increase-open-files-limit/
RUN echo -e "\n\
*               hard    nofile            500000\n\
*               soft    nofile            500000\n\
root            hard    nofile            500000\n\
root            soft    nofile            500000" >> /etc/security/limits.conf \
    && echo -e "session required pam_limits.so" >> /etc/pam.d/common-session \
    && echo -e "fs.file-max = 2097152" >> /etc/sysctl.conf
### End of optimizations

### Start of Nginx WEBSERVER setup
RUN mkdir -p /var/www
# Modify www-data user and set UID, GID to 500
#RUN groupmod -g 500 www-data \
    #&& usermod -u 500 www-data \
    #&& "find / -user <OLDUID> -exec chown -h <NEWUID> {} \;" \
    #&& "find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;" \
    #&& chown -R www-data:www-data /var/www \
    #&& chmod g+s /var/www
### End of Nginx WEBSERVER setup

RUN rm -rf /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
