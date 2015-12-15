# Lanti/DebianPHP
#
# VERSION               1.0.0

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHP-FPM 7 through FastCGI built from source" Vendor="Istvan Lantos" Version="1.0"

ENV PHP_VERSION 7.0.0
ENV PHP_FILENAME php-7.0.0.tar.xz
# Checksum
ENV PHP_SHA256 7dbdda74c502960febe0544b3e3a7c430389a7a4260e94c73fd8ca26c33b8540
# Adding GPG key
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763
RUN set -xe \
    && for key in $GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done
# Add PHP to $PATH
RUN echo 'export PATH="$PATH:/usr/local/php7/bin:/usr/local/php7/sbin"' >> /etc/bash.bashrc

# persistent / runtime deps
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        ca-certificates \
        curl \
        librecode0 \
        libsqlite3-0 \
        libxml2 --no-install-recommends \
    && rm -r /var/lib/apt/lists/*
# phpize deps
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c --no-install-recommends \
    && rm -r /var/lib/apt/lists/*
# PHP extra build dependencies
# --enable-mysqlnd is included below because it's harder to compile after the fact the extensions are (since it's a plugin for several extensions, not an extension in itself)
ENV buildDeps=" \
        $PHP_EXTRA_BUILD_DEPS \
        libcurl4-openssl-dev \
        libreadline6-dev \
        librecode-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
    "
#RUN set -x
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# Downloading source files
RUN curl -fSL "http://php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
    && echo "$PHP_SHA256 *$PHP_FILENAME" | sha256sum -c - \
    && curl -fSL "http://php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o "$PHP_FILENAME.asc" \
    && gpg --verify "$PHP_FILENAME.asc" \
    && mkdir -p /usr/src/php \
    && tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
    && rm "$PHP_FILENAME"* \
    && cd /usr/src/php
# Configure the build OPTIONS LIST
RUN ./configure --help
# Configuring the build
# http://wordpress.stackexchange.com/questions/42098/what-are-php-extensions-and-libraries-wp-needs-and-or-uses
# https://wordpress.org/support/topic/wowdpress-php-dependencies
RUN ./configure \
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
        --with-zlib=/usr \
        --with-zlib-dir=/usr \
        --enable-bcmath \
        --with-bz2=/usr \
        --enable-calendar \
        --with-curl \
        --enable-exif \
        --enable-ftp \
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
        --enable-pcntl \
        #--with-pdo-mysql=/usr \
        --with-pspell \
        --with-readline \
        --with-recode=/usr \
        --enable-soap \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-wddx \
        --enable-zip \
        --enable-mysqlnd \
        # PEAR \
        --without-pear \
        # Zend added \
        #--with-mysql=/usr \
        #--with-apxs2=/usr/bin/apxs2 \
        # Misc - Added by Docker installer \
        #--enable-mysqlnd \
        #--with-mysqli=/usr/bin/mysql_config \
        #--with-curl \
        #--with-openssl \
        #--with-readline \
        #--with-recode \
        #--with-zlib

RUN make -j"$(nproc)" \
    && make install \
    && { find /usr/local/php7/bin /usr/local/php7/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && make clean

#RUN echo -e \
#"deb http://repos.zend.com/zend-server/early-access/php7/repos ubuntu/" > /etc/apt/sources.list.d/php.list
#RUN apt-get -y update \
#    && time apt-get -y dist-upgrade \
#    && apt-get -y --force-yes install --fix-missing \
#        php7-nightly

### Start of PHP 7 setup
RUN mkdir -p /var/run/php-fpm && mkdir -p /var/log/php-fpm
### End of PHP 7 setup

CMD ["/usr/local/php7/sbin/php-fpm", "--nodaemonize", "--fpm-config", "/usr/local/php7/etc/php-fpm.conf"]
