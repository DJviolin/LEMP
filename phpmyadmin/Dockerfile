# Lanti/lempPHPMyAdmin
#
# VERSION               1.0.0

# https://github.com/phpmyadmin/docker/blob/master/Dockerfile
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-14-04-server

# Further config: http://stackoverflow.com/a/21389060/1442219

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHPMyAdmin" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        curl

RUN mkdir -p /var/www \
    && curl --location https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -o /var/www/phpMyAdmin-latest-all-languages.tar.gz \
    && tar -xzf /var/www/phpMyAdmin-latest-all-languages.tar.gz -C /var/www \
    && rm -rf /var/www/phpMyAdmin-latest-all-languages.tar.gz \
    && mv /var/www/phpMyAdmin* /var/www/phpmyadmin \
    && rm -rf /var/www/phpmyadmin/js/jquery/src/ /var/www/phpmyadmin/examples /var/www/phpmyadmin/po/ \
    && ls -al /var/www && ls -al /var/www/phpmyadmin

RUN rm -rf /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
