# Lanti/lempPHP
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHP-FPM 7 through FastCGI built from source" Vendor="Istvan Lantos" Version="1.0"

ENV PHP_VERSION 7.0.2
ENV PHP_FILENAME php-7.0.2.tar.gz
# Checksum
ENV PHP_SHA256 040198aef3dc5f17c253c1282160aabc6a05ca0b18b3d6fc9213970363083412
# Adding GPG key
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763
RUN set -xe \
    && for key in $GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done
# Add PHP to $PATH
RUN echo 'export PATH="$PATH:/usr/local/php7/bin:/usr/local/php7/sbin"' >> /etc/bash.bashrc

### Start of DEV environment deps
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        # persistent / runtime deps \
        ca-certificates \
        curl \
        librecode0 \
        libxml2 --no-install-recommends \
        # phpize deps \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c --no-install-recommends
### End of DEV environment deps

### Start of Downloading source files
RUN curl -fSL "http://php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
    && echo "$PHP_SHA256 *$PHP_FILENAME" | sha256sum -c - \
    && curl -fSL "http://php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o "$PHP_FILENAME.asc" \
    && gpg --verify "$PHP_FILENAME.asc" \
    && mkdir -p /usr/src/php \
    && tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
    && rm "$PHP_FILENAME"*
### End of Downloading source files

# PHP extra build dependencies
# --enable-mysqlnd is included below because it's harder to compile after the fact the extensions are (since it's a plugin for several extensions, not an extension in itself)
RUN apt-get -y install \
        libcurl4-openssl-dev --no-install-recommends \
        librecode-dev --no-install-recommends \
        libssl-dev --no-install-recommends \
        libxml2-dev --no-install-recommends \
        # Own dependencies \
        libbz2-dev --no-install-recommends \
        libjpeg-dev --no-install-recommends \
        libpng12-dev --no-install-recommends \
        libxpm-dev --no-install-recommends \
        libfreetype6-dev --no-install-recommends \
        libgmp-dev --no-install-recommends \
        libicu-dev --no-install-recommends \
        libmcrypt-dev --no-install-recommends \
        libmysqlclient-dev --no-install-recommends \
        libmysqld-dev --no-install-recommends
# Fixing "configure: error: Unable to locate gmp.h"
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 
# Configuring the build
RUN cd /usr/src/php \
    && ./configure \
        # Installation directories \
        --prefix=/usr/local/php7 \
        # Fine tuning of the installation directories \
        --with-libdir=/lib/x86_64-linux-gnu \
        # SAPI modules \
        --enable-fpm \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --disable-cgi \
        # General settings \
        --with-config-file-path=/usr/local/php7/etc \
        --with-config-file-scan-dir=/usr/local/php7/etc/conf.d \
        # Extensions \
        --with-openssl \
        --without-sqlite3 \
        --with-zlib=/usr \
        --with-zlib-dir=/usr \
        --enable-bcmath \
        --with-bz2=/usr \
        --enable-calendar \
        --with-curl \
        --enable-exif \
        --with-gd \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
        --with-xpm-dir=/usr \
        --with-freetype-dir=/usr \
        --enable-gd-native-ttf \
        --enable-gd-jis-conv \
        --with-gettext=/usr \
        --with-gmp=/usr \
        --with-iconv \
        --enable-intl \
        --enable-mbstring \
        --with-mcrypt \
        --with-mysqli=/usr/bin/mysql_config \
        --disable-pdo \
        --without-pdo-sqlite \
        --disable-phar \
        --with-recode=/usr \
        --enable-sockets \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-zip \
        # PEAR \
        --without-pear \
    && echo -e "Configuration done!"

RUN cd /usr/src/php \
    && make -j"$(nproc)" \
    && make install \
    && { find /usr/local/php7/bin /usr/local/php7/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && make clean

### Start of PHP 7 setup
RUN mkdir -p /var/run/php-fpm && mkdir -p /var/log/php-fpm
### End of PHP 7 setup

RUN apt-get -y install \
    supervisor \
    cron
RUN mkdir -p /var/log/supervisord

RUN mkdir -p /root/lemp_php

RUN rm -rf /usr/src/* /var/lib/apt/lists/*

#CMD ["/usr/local/php7/sbin/php-fpm", "--nodaemonize", "--fpm-config", "/usr/local/php7/etc/php-fpm.conf"]

#COPY etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
