# Lanti/DebianWeb
#
# VERSION               1.0.0

FROM lemp_lanti-debian-base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Nginx + PHP-FPM 7 through FastCGI" Vendor="Istvan Lantos" Version="1.0"

RUN echo 'export PATH="$PATH:/usr/local/php7/bin:/usr/local/php7/sbin"' >> /etc/bash.bashrc

RUN echo -e \
"deb http://nginx.org/packages/mainline/debian/ jessie nginx\n\
deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" > /etc/apt/sources.list.d/nginx.list
RUN echo -e \
"deb http://repos.zend.com/zend-server/early-access/php7/repos ubuntu/" > /etc/apt/sources.list.d/php.list
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        nginx \
        php7-nightly

### Start of Nginx setup
COPY etc/nginx/conf.d/default.conf /etc/nginx/conf.d/
COPY etc/nginx/conf.d/php.conf /etc/nginx/conf.d/
# NGINX WEBSERVER FILES
RUN mkdir -p /var/www
COPY usr/share/nginx/html/404.html /usr/share/nginx/html/
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
# Allow Nginx to access /var/run/php-fpm.sock
RUN usermod -aG www-data nginx
### End of Nginx setup

### Start of PHP 7 setup
COPY usr/local/php7/etc/php.ini /usr/local/php7/etc/
COPY usr/local/php7/etc/php-fpm.conf /usr/local/php7/etc/
COPY usr/local/php7/etc/php-fpm.d/www.conf /usr/local/php7/etc/php-fpm.d/
RUN mkdir -p /var/log/php-fpm
### End of PHP 7 setup

COPY etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
