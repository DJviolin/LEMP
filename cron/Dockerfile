# Lanti/lempCron
#
# VERSION               1.0.0

FROM debian:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Cron" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        cron \
        rsyslog \
        vim

RUN rm -rf /var/lib/apt/lists/*

#cron fixes
RUN touch /etc/crontab /etc/cron.d/* /var/spool/cron/crontabs/*
#COPY etc/cron.d /etc/cron.d
COPY etc/crontab /etc/crontab
#COPY var/spool/cron/crontabs /var/spool/cron/crontabs
RUN chmod 600 /etc/crontab /etc/cron.d/* /var/spool/cron/crontabs/*
RUN touch /etc/crontab /etc/cron.d/* /var/spool/cron/crontabs/*

RUN rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
