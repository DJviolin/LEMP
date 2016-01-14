# Lanti/lempApp
#
# VERSION               1.0.0

FROM lemp_nginx:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="App" Vendor="Istvan Lantos" Version="1.0"

#RUN mkdir -p /var/www
#WORKDIR /var/www

#RUN curl -fSL "https://wordpress.org/latest.tar.gz" -o "latest.tar.gz" \
#    && mkdir -p /var/www/app1 \
#    && tar -xf "latest.tar.gz" -C /var/www/app1 --strip-components=1 \
#    && rm "latest.tar.gz"*

#ONBUILD COPY . /var/www
ONBUILD RUN chmod -R 777 /var/www \
    && chown -R www-data:www-data /var/www

#CMD ["/usr/sbin/nginx"]

CMD ["tail", "-f", "/dev/null"]
