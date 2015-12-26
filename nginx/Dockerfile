# Lanti/DebianNginx
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
        # Enable "rewrite" option in our Nginx (allows us to do redirect) \
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
RUN curl -fSL "http://nginx.org/download/$NGINX_VERSION" -o "$NGINX_VERSION" \
    && curl -fSL "http://nginx.org/download/$NGINX_VERSION.asc" -o "$NGINX_VERSION.asc" \
    && gpg --verify "$NGINX_VERSION.asc" \
    && mkdir -p /usr/src/nginx \
    && tar -xf "$NGINX_VERSION" -C /usr/src/nginx --strip-components=1 \
    && rm "$NGINX_VERSION"*
### End of Downloading source files

# Configuring the build
#RUN set -x
RUN cd /usr/src/nginx \
    && ./configure --help
    && echo -e "Configuration done!"

#RUN cd /usr/src/nginx \
#    && make \
#    && make install

### Start of Nginx setup
#COPY usr/share/nginx/html/404.html /usr/share/nginx/html/
#RUN mkdir -p /usr/share/nginx/cache
# forward request and error logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log
# Allow Nginx to access /var/run/php-fpm/php-fpm.sock
#RUN usermod -aG www-data nginx
### End of Nginx setup

### Start of Nginx WEBSERVER setup
#RUN chown -R www-data:www-data /var/www \
#    && chmod g+s /var/www
### End of Nginx WEBSERVER setup

RUN rm -rf /var/lib/apt/lists/*

#CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
CMD ["tail", "-f", "/dev/null"]
