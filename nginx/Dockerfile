# Lanti/DebianNginx
#
# VERSION               1.0.0

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Nginx" Vendor="Istvan Lantos" Version="1.0"

RUN echo -e \
"deb http://nginx.org/packages/mainline/debian/ jessie nginx\n\
deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" > /etc/apt/sources.list.d/nginx.list
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        nginx

### Start of Nginx setup
COPY usr/share/nginx/html/404.html /usr/share/nginx/html/
RUN mkdir -p /usr/share/nginx/cache
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
# Allow Nginx to access /var/run/php-fpm/php-fpm.sock
RUN usermod -aG www-data nginx
### End of Nginx setup

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
