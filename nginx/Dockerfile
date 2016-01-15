# Lanti/lempNginx
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Nginx built from source" Vendor="Istvan Lantos" Version="1.0"

ENV NGINX_VERSION nginx-1.9.9.tar.gz

### Start of DEV environment deps
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        curl \
        make \
        gcc \
        g++ \
        # Nginx packages
        openssl \
        libc6-dev \
        libexpat1-dev \
        libgd3 \
        libgeoip-dev \
        libpam0g-dev \
        libpcre3-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev
### End of DEV environment deps

### Start of Downloading source files
# Nginx
RUN curl -fSL "http://nginx.org/download/$NGINX_VERSION" -o "$NGINX_VERSION" \
    && curl -fSL "http://nginx.org/download/$NGINX_VERSION.asc" -o "$NGINX_VERSION.asc" \
    #&& gpg --verify "$NGINX_VERSION.asc" \
    && mkdir -p /usr/src/nginx \
    && tar -xf "$NGINX_VERSION" -C /usr/src/nginx --strip-components=1 \
    && rm "$NGINX_VERSION"*
# Nginx 3rd party modules
RUN curl -fSL "https://github.com/FRiCKLE/ngx_cache_purge/archive/master.tar.gz" -o "ngx_cache_purge.tar.gz" \
    && mkdir -p /usr/src/nginx-modules/ngx_cache_purge \
    && tar -xf "ngx_cache_purge.tar.gz" -C /usr/src/nginx-modules/ngx_cache_purge --strip-components=1 \
    && rm "ngx_cache_purge.tar.gz"*
RUN curl -fSL "https://github.com/openresty/srcache-nginx-module/archive/master.tar.gz" -o "ngx_srcache.tar.gz" \
    && mkdir -p /usr/src/nginx-modules/ngx_srcache \
    && tar -xf "ngx_srcache.tar.gz" -C /usr/src/nginx-modules/ngx_srcache --strip-components=1 \
    && rm "ngx_srcache.tar.gz"*
### End of Downloading source files

# Configuring the build
RUN cd /usr/src/nginx \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
        --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
        --with-ipv6 \
        # Added 3rd party modules \
        --add-module=/usr/src/nginx-modules/ngx_cache_purge \
        --add-module=/usr/src/nginx-modules/ngx_srcache \
    && echo -e "Configuration done!"

RUN cd /usr/src/nginx \
    && make \
    && make install

### Start of Nginx setup
COPY etc/nginx/html/404.html /etc/nginx/html/
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
# This will create the user and set their shell to /bin/false so no one can start an interactive login as this user
RUN groupadd nginx \
    && useradd nginx -g nginx --system --no-create-home -s /bin/false
#RUN groupadd nginx -g 550 \
#    && useradd nginx -g nginx -u 550 --system --no-create-home -s /bin/false \
# Allow Nginx to access /var/run/php-fpm/php-fpm.sock
RUN usermod -aG www-data nginx
### End of Nginx setup

RUN rm -rf /usr/src/* /var/lib/apt/lists/*

WORKDIR /var/www

CMD ["/usr/sbin/nginx"]
