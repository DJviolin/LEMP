# Lanti/DebianNginx
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Nginx built from source" Vendor="Istvan Lantos" Version="1.0"

ENV NGINX_VERSION 1.9.9

### Start of DEV environment deps
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        # persistent / runtime deps \
        #ca-certificates \
        curl \
        #librecode0 \
        #libsqlite3-0 \
        #libxml2 --no-install-recommends \
        # phpize deps \
        #autoconf \
        #file \
        g++ \
        gcc \
        #libc-dev \
        make \
        #pkg-config \
        #re2c --no-install-recommends
### End of DEV environment deps

### Start of Downloading source files
RUN curl -fSL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o "nginx-$NGINX_VERSION.tar.gz" \
    && curl -fSL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc" -o "nginx-$NGINX_VERSION.tar.gz.asc" \
    && gpg --verify "nginx-$NGINX_VERSION.tar.gz.asc" \
    && mkdir -p /usr/src/nginx \
    && tar -xf "nginx-$NGINX_VERSION.tar.gz" -C /usr/src/nginx --strip-components=1 \
    && rm "nginx-$NGINX_VERSION.tar.gz"*
### End of Downloading source files

# Configuring the build
#RUN set -x
RUN cd /usr/src/nginx \
    && ./configure --help
    && echo -e "Configuration done!"

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
