# Lanti/lempCron
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Cron" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        #supervisor \
        cron

#RUN mkdir -p /var/log/supervisord

RUN rm -rf /var/lib/apt/lists/*

#COPY etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

CMD ["cron", "-f"]
