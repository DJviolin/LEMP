# Lanti/DebianPHPMyAdmin
#
# VERSION               1.0.0

# https://github.com/phpmyadmin/docker/blob/master/Dockerfile
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-14-04-server

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHPMyAdmin" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y --force-yes install --fix-missing \
    curl

RUN mkdir -p /var/www/phpmyadmin \
    && curl --location https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -o /var/www/phpMyAdmin-latest-all-languages.tar.gz \
    && tar -xzf /var/www/phpMyAdmin-latest-all-languages.tar.gz \
    && ls -al /var/www && ls -al /var/www/phpmyadmin \
    && mv /var/www/phpMyAdmin* /var/www/phpmyadmin \
    && rm -rf /var/www/phpmyadmin/js/jquery/src/ /var/www/phpmyadmin/examples /var/www/phpmyadmin/po/ \
    && rm -rf /var/www/phpMyAdmin-latest-all-languages.tar.gz

COPY var/www/phpmyadmin/config.inc.php /var/www/phpmyadmin/config.inc.php

CMD ["tail", "-f", "/dev/null"]
