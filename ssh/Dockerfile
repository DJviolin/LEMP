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
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        openssh-server

### Start of OpenSSH setup
RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh
COPY root/.ssh/authorized_keys /root/.ssh/
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo -e '\ncd /root' >> /root/.bashrc
### End of OpenSSH setup

### Start of Nginx WEBSERVER FILES
RUN mkdir -p /var/www
### End of Nginx WEBSERVER FILES

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
