# Lanti/lempCron
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Cron" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        cron

RUN rm -rf /var/lib/apt/lists/*

CMD ["cron", "-f"]
