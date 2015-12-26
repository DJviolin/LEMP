# Lanti/DebianPHP
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHP-FPM 7 through FastCGI built from source" Vendor="Istvan Lantos" Version="1.0"

ENV PHP_VERSION 7.0.0
ENV PHP_FILENAME php-7.0.0.tar.gz
# Checksum
ENV PHP_SHA256 d6ae7b4a2e5c43a9945a97e83b6b3adfb7d0df0b91ef78b647a6dffefaa9c71b
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
    && apt-get -y --force-yes install \
        # persistent / runtime deps \
        ca-certificates \
        curl \
        librecode0 \
        #libsqlite3-0 \
        libxml2 --no-install-recommends \
        # phpize deps \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c --no-install-recommends \
        # Need for tar.xz \
        #xz-utils --no-install-recommends \
    && rm -r /var/lib/apt/lists/*
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
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        libcurl4-openssl-dev --no-install-recommends \
        #libreadline6-dev --no-install-recommends \
        librecode-dev --no-install-recommends \
        #libsqlite3-dev --no-install-recommends \
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
        libmysqld-dev --no-install-recommends \
        #libpspell-dev --no-install-recommends \
        # Own dependencies - WP SSH2 \
        libssh2-1 \
        libssh2-1-dev --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# Fixing "configure: error: Unable to locate gmp.h"
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 
# Configuring the build
# http://wordpress.stackexchange.com/questions/42098/what-are-php-extensions-and-libraries-wp-needs-and-or-uses
# https://wordpress.org/support/topic/wowdpress-php-dependencies
#RUN set -x
RUN cd /usr/src/php \
    && ./configure \
        # Installation directories \
        --prefix=/usr/local/php7 \
        # Fine tuning of the installation directories \
        --with-libdir=/lib/x86_64-linux-gnu \
        # SAPI modules \
        #--disable-cli \
        --enable-fpm \
        #--with-fpm-user=www-data \
        #--with-fpm-group=www-data \
        --with-fpm-user=core \
        --with-fpm-group=core \
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
        #--enable-ftp \
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
        #--enable-pcntl \
        --disable-pdo \
        #--with-pdo-mysql=/usr \
        --without-pdo-sqlite \
        --disable-phar \
        #--with-pspell \
        #--with-readline \
        --with-recode=/usr \
        #--enable-soap \
        --enable-sockets \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        #--enable-wddx \
        --enable-zip \
        #--enable-mysqlnd \
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
        #--with-zlib \
    && echo -e "Configuration done!"
    #http://php.net/manual/en/intro.phar.php - Turn off PHAR

RUN cd /usr/src/php \
    && make -j"$(nproc)" \
    && make install \
    && { find /usr/local/php7/bin /usr/local/php7/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && make clean

### Start of PECL SSH2 install
# https://github.com/php/pecl-networking-ssh2
RUN cd ~ \
    && mkdir -p /usr/src/ssh2 \
    && curl -fSL "https://github.com/php/pecl-networking-ssh2/archive/master.tar.gz" -o "pecl-networking-ssh2.tar.gz" \
    && tar -xzf "pecl-networking-ssh2.tar.gz" -C /usr/src/ssh2 --strip-components=1 \
    && rm -rf pecl-networking-ssh2.tar.gz \
    && cd /usr/src/ssh2 \
    && /usr/local/php7/bin/phpize \
    && ./configure \
        --with-ssh2 \
        --with-php-config=/usr/local/php7/bin/php-config \
    && make \
    && make install
### End of PECL SSH2 install

### Start of PHP 7 setup
RUN mkdir -p /var/run/php-fpm && mkdir -p /var/log/php-fpm
### End of PHP 7 setup

RUN rm -rf /usr/src/* /var/lib/apt/lists/*

CMD ["/usr/local/php7/sbin/php-fpm", "--nodaemonize", "--fpm-config", "/usr/local/php7/etc/php-fpm.conf"]
