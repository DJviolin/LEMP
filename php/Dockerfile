# Lanti/DebianPHP
#
# VERSION               1.0.0

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHP-FPM 7 through FastCGI" Vendor="Istvan Lantos" Version="1.0"

RUN echo 'export PATH="$PATH:/usr/local/php7/bin:/usr/local/php7/sbin"' >> /etc/bash.bashrc

RUN echo -e \
"deb http://repos.zend.com/zend-server/early-access/php7/repos ubuntu/" > /etc/apt/sources.list.d/php.list
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        php7-nightly

### Start of PHP 7 setup
COPY usr/local/php7/etc/php.ini /usr/local/php7/etc/
COPY usr/local/php7/etc/php-fpm.conf /usr/local/php7/etc/
COPY usr/local/php7/etc/php-fpm.d/www.conf /usr/local/php7/etc/php-fpm.d/
RUN mkdir -p /var/run/php-fpm && mkdir -p /var/log/php-fpm
### End of PHP 7 setup

CMD ["/usr/local/php7/sbin/php-fpm", "--nodaemonize", "--fpm-config", "/usr/local/php7/etc/php-fpm.conf"]
