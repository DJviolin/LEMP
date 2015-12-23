# Lanti/DebianSSH
#
# VERSION               1.0.0

FROM debian:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="This image is the base of the other app images in this project" Vendor="Istvan Lantos" Version="1.0"

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
RUN ln -sf /bin/bash /bin/sh && ln -sf /bin/bash /bin/sh.distrib

RUN echo -e \
"deb http://httpredir.debian.org/debian stable main contrib non-free\n\
deb-src http://httpredir.debian.org/debian stable main contrib non-free\n\
deb http://security.debian.org stable/updates main contrib non-free\n\
deb-src http://security.debian.org stable/updates main contrib non-free\n\
deb http://httpredir.debian.org/debian stable-updates main contrib non-free\n\
deb-src http://httpredir.debian.org/debian stable-updates main contrib non-free" > /etc/apt/sources.list
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        dialog \
        apt-utils \
        openssh-server

### Start of OpenSSH setup
RUN mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile \
    && echo -e '\ncd /root' >> /root/.bashrc
### End of OpenSSH setup

### Start of Nginx WEBSERVER setup
RUN mkdir -p /var/www
### End of Nginx WEBSERVER setup

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

# Add the core's UID 500 to the container
RUN groupadd core -g 500 \
    && useradd -u 500 -g 500 core \
    && usermod -a -G core core
RUN mkdir -p /home/core \
    && chown -R core:core /home/core \
    && chmod go-w /home/core \
    && echo -e '\ncd /home/core' >> /home/core/.bashrc \
    && mkdir -p /home/core/.ssh \
    && ssh-keygen -b 4096 -t rsa -N '' -f /home/core/.ssh/wp_rsa \
    && cat /home/core/.ssh/wp_rsa.pub >> /home/core/.ssh/authorized_keys \
    && chmod 700 /home/core/.ssh \
    && chmod 600 /home/core/.ssh/authorized_keys
# Add permissions to shared volumes
RUN usermod -aG core root

RUN rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/sshd", "-D"]
